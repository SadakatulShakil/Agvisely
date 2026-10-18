import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../features/notifications/presentation/pages/notification_page.dart';
import 'notification_pref.dart';

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
    AndroidInitializationSettings('ic_launcher');

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
      'agvisely_alert_channel',
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
      'agvisely_general_channel',
      'General Notifications',
      description: 'Weather updates and general info',
      importance: Importance.high,
      playSound: true,
      enableVibration: false,
      showBadge: true,
    );

    await android.createNotificationChannel(alertChannel);
    await android.createNotificationChannel(generalChannel);
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
          'agvisely_alert_channel',
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
          'agvisely_general_channel',
          'General Notifications',
          icon: 'ic_launcher',
          importance: Importance.max,
          priority: Priority.max,
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

    Get.to(
          () => const NotificationPage(),
      arguments: {'type': payload ?? 'general'},
    );
  }
}