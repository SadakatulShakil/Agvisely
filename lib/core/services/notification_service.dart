// lib/core/services/notification_service.dart
//
// ─────────────────────────────────────────────────────────────────
// SEVERE ALERT — required FCM v1 payload (backend must send):
// {
//   "message": {
//     "token": "<device_token>",
//     "notification": { "title": "...", "body": "..." },
//     "android": {
//       "priority": "high",
//       "notification": {
//         "channel_id": "alert_channel_id_v2",
//         "notification_priority": "PRIORITY_MAX",
//         "visibility": "PUBLIC",
//         "default_vibrate_timings": false,
//         "vibrate_timings": ["0s","0.4s","0.2s","0.8s"]
//         // NO "sound" field — channel provides the alarm tone
//       }
//     },
//     "data": { "type": "alert" }
//   }
// }
// Full-screen behavior in background/killed is driven by the channel
// (importance MAX + category alarm already set at channel creation)
// plus the app's data-message handling. For guaranteed full-screen
// takeover in killed state, send as a DATA-ONLY message (no
// "notification" block) so the app's background handler builds the
// notification via showNotification() — which applies full-screen
// intent + the volume boost. Tradeoff: data-only requires the
// background isolate to run. Decide per alert severity; document
// both.
//
// NOTE: firebaseMessagingBackgroundHandler (firebase_service.dart)
// currently does NOT call showNotification() for data-only messages —
// it only logs and relies on the FCM SDK auto-rendering the
// "notification" block. That auto-render path cannot apply full-screen
// intent or the alarm-volume boost. Wiring data-only alert messages
// through showNotification() in the background handler is a required
// follow-up for full belt-and-suspenders coverage in the killed state.
// ─────────────────────────────────────────────────────────────────

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../features/notifications/presentation/pages/notification_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'notification_pref.dart';
import 'user_pref_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();
  final _prefs = NotificationPrefs();

  static const _alertAudioChannel =
      MethodChannel('bd.gov.dae.agvisely/alert_audio');

  // Stores payload when navigator is not yet ready
  String? _pendingPayload;

  Future<void>? _initFuture;

  // ─────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────

  Future<void> init() {
    return _initFuture ??= _doInit();
  }

  Future<void> _doInit() async {
    const androidInit =
    AndroidInitializationSettings('@drawable/ic_launcher');

    const iOSInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    await _plugin.initialize(
      InitializationSettings(android: androidInit, iOS: iOSInit),

      // FOREGROUND tap — app is open, user taps notification
      onDidReceiveNotificationResponse: (NotificationResponse r) {
        debugPrint('🔔 TAP RECEIVED — payload: ${r.payload}, route: ${Get.currentRoute}');
        _pendingPayload = r.payload;
        _tryNavigateNow();
      },

      // BACKGROUND tap — app is minimised, user taps notification
      onDidReceiveBackgroundNotificationResponse: _staticBgTapHandler,
    );

    await _createChannels();

    //TERMINATED tap — app was killed, launched by tapping notification
    await _checkTerminatedTap();
  }

  Future<void> _ensureInitialized() => init();

  //MUST be static — runs in a separate isolate
  @pragma('vm:entry-point')
  static void _staticBgTapHandler(NotificationResponse r) {
    debugPrint('🔔 BG local tap: ${r.payload}');
    // Store on singleton — HomeController.onReady() consumes it
    NotificationService()._pendingPayload = r.payload;
  }

  // ─────────────────────────────────────────────────────────
  // CHANNEL CREATION
  // ─────────────────────────────────────────────────────────

  Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    //_v2 — bumped from 'alert_channel_id'. Channel sound is

    final alertChannel = AndroidNotificationChannel(
      'alert_channel_id_v2',
      'Weather Alerts',
      description: 'Severe weather alerts — always audible',
      importance: Importance.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_alert'),
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      showBadge: true,
      enableLights: true,
      ledColor: const Color(0xFFFF3D00),
    );

    // General channel — respects ringer/silent mode
    const generalChannel = AndroidNotificationChannel(
      'general_channel_id',
      'General Notifications',
      description: 'Weather updates and general info',
      importance: Importance.high,
      playSound: true,
      enableVibration: false,
      showBadge: true,
    );

    // Scheduled forecast channel — gentle daily digest, distinct from
    // the alarm-stream alert channel above.
    const scheduledChannel = AndroidNotificationChannel(
      'scheduled_forecast_id',
      'Daily Forecast',
      description: 'Scheduled daily weather updates',
      importance: Importance.max,
      playSound: true,
    );

    await android.createNotificationChannel(alertChannel);
    await android.createNotificationChannel(generalChannel);
    await android.createNotificationChannel(scheduledChannel);
    await android.requestNotificationsPermission();
  }

  // ─────────────────────────────────────────────────────────
  // SHOW NOTIFICATION
  // ─────────────────────────────────────────────────────────

  Future<void> showNotification({
    required int id,
    required String? title,
    required String? body,
    String? payload,
  }) async {
    final isAlert = payload == 'alert';

    if (isAlert && !_prefs.alertsEnabled) {
      debugPrint('⚠️ Alert notifications disabled by user');
      return;
    }
    if (!isAlert && !_prefs.generalEnabled) {
      debugPrint('⚠️ General notifications disabled by user');
      return;
    }

    final details = Platform.isAndroid
        ? _androidDetails(isAlert: isAlert)
        : _iOSDetails(isAlert: isAlert);

    if (isAlert && Platform.isAndroid) {
      await _boostAlarmVolumeForAlert();
    }
    await _plugin.show(id, title, body, details, payload: payload);
  }

  // ✅ Belt-and-suspenders: raise the alarm stream so the alert tone
  // is audible even if the user has muted alarm volume. Only raises,
  // never lowers — never overrides a user who already has it loud.
  Future<void> _boostAlarmVolumeForAlert() async {
    if (!Platform.isAndroid) return;
    try {
      await _alertAudioChannel.invokeMethod('boostAlarmVolume');
    } catch (e) {
      debugPrint('alarm volume boost failed: $e');
    }
  }

  NotificationDetails _androidDetails({required bool isAlert}) {
    final Int64List alertPattern =
    Int64List.fromList([0, 400, 200, 800, 200, 400]);
    final Int64List generalPattern = Int64List.fromList([0, 300]);

    final bool vibrate = isAlert ? true : _prefs.generalVibration;

    final String ringtone =
    isAlert ? _prefs.alertRingtone : _prefs.generalRingtone;
    final RawResourceAndroidNotificationSound? customSound =
    ringtone != 'default'
        ? RawResourceAndroidNotificationSound(ringtone)
        : null;

    if (isAlert) {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          'alert_channel_id_v2',
          'Weather Alerts',
          icon: 'ic_launcher',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: customSound,
          enableVibration: true,
          vibrationPattern: alertPattern,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          fullScreenIntent: _prefs.fullScreenAlert,
          category: AndroidNotificationCategory.alarm,
          enableLights: true,
          ledColor: const Color(0xFFFF3D00),
          ledOnMs: 300,
          ledOffMs: 500,
          styleInformation: const BigTextStyleInformation(''),
          showWhen: true,
          // ✅ MUST be true — false prevents tap intent from firing
          autoCancel: true,
          tag: 'alert',
        ),
      );
    } else {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          'general_channel_id',
          'General Notifications',
          icon: 'ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: customSound,
          enableVibration: vibrate,
          vibrationPattern: vibrate ? generalPattern : null,
          category: AndroidNotificationCategory.message,
          styleInformation: const BigTextStyleInformation(''),
          showWhen: true,
          autoCancel: true,
          tag: 'general',
        ),
      );
    }
  }

  NotificationDetails _iOSDetails({required bool isAlert}) {
    return NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: isAlert
            ? InterruptionLevel.critical
            : InterruptionLevel.active,
        threadIdentifier:
        isAlert ? 'weather_alerts' : 'weather_general',
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TERMINATED STATE CHECK
  // ─────────────────────────────────────────────────────────

  Future<void> _checkTerminatedTap() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      _pendingPayload = details?.notificationResponse?.payload;
      debugPrint('🚀 App launched from local notif: $_pendingPayload');
    }
  }

  // ─────────────────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────────────────

  void _tryNavigateNow() {
    if (_pendingPayload == null) return;
    final payload = _pendingPayload;
    try {
      _pendingPayload = null;
      _navigate(payload);
    } catch (e) {
      debugPrint('🧭 Foreground navigate failed — retrying via onReady: $e');
      _pendingPayload = payload; // restore so HomeController.onReady() retries
    }
  }

  void handlePendingNavigation() {
    if (_pendingPayload != null) {
      final payload = _pendingPayload;
      _pendingPayload = null;
      _navigate(payload);
    }
  }

  void _navigate(String? payload) {
    debugPrint('🧭 Navigating — type: $payload');

    // Scheduled daily forecast taps go to the home page, not the
    // notification inbox — offAll so it lands on Home regardless of
    // whatever page/stack the app happened to be on when tapped.
    if (payload == 'scheduled_forecast') {
      Get.offAll(() => const HomePage());
      return;
    }

    Get.to(
          () => const NotificationPage(),
      arguments: {'type': payload ?? 'general'},
    );
  }

  // ─────────────────────────────────────────────────────────
  // SCHEDULED DAILY FORECAST NOTIFICATIONS
  // ─────────────────────────────────────────────────────────

  static const List<int> _dailyForecastHours = [9, 17, 18, 0]; // 9AM, 3PM, 9PM, 12AM
  static const int _dailyForecastBaseId = 8100; // stable slot IDs
  static const String _keyExactAlarmAsked = 'EXACT_ALARM_ASKED';

  Future<void> scheduleDailyForecasts({
    required String locationName,
    required String temp,      // whole number, e.g. "32"
    required String tempUnit,  // "°সে" / "°C"
    required bool isBangla,
    // false when called from the headless WorkManager isolate — there is
    // no live Activity there, and requestExactAlarmsPermission() calls
    // mainActivity.startActivityForResult() internally, which crashes
    // without one. The foreground call site (HomeController) always has
    // an Activity, so it keeps the default of true.
    bool allowExactAlarmPrompt = true,
  }) async {
    if (locationName.isEmpty || temp.isEmpty || temp == '--') return;

    await _ensureInitialized();
    final canExact =
        await _ensureExactAlarmPermission(allowPrompt: allowExactAlarmPrompt);
    final isBn = isBangla;

    for (int i = 0; i < _dailyForecastHours.length; i++) {
      final id = _dailyForecastBaseId + i;
      await _plugin.cancel(id);

      final scheduled = _nextInstanceOf(_dailyForecastHours[i], 30);
      final title = locationName; // location only
      final body = isBn
          ? 'বর্তমান তাপমাত্রা $temp$tempUnit'
          : 'Current temperature $temp$tempUnit';

      // keep body construction isolated here.

      await _plugin.zonedSchedule(
        id, title, body, scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'scheduled_forecast_id', 'Daily Forecast',
            channelDescription: 'Scheduled daily weather updates',
            icon: 'ic_launcher',
            importance: Importance.max,
            priority: Priority.max,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // daily repeat
        payload: 'scheduled_forecast',
      );
    }
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<bool> _ensureExactAlarmPermission({bool allowPrompt = true}) async {
    if (!Platform.isAndroid) return true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;

    final granted = await android.canScheduleExactNotifications() ?? false;
    if (granted) return true;
    if (!allowPrompt) return false;

    final alreadyAsked =
        UserPrefService().getBool(_keyExactAlarmAsked) == true;
    if (alreadyAsked) return false;

    await android.requestExactAlarmsPermission();
    await UserPrefService().setBool(_keyExactAlarmAsked, true);
    return await android.canScheduleExactNotifications() ?? false;
  }
}