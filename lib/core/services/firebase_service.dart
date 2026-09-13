// lib/core/services/firebase_service.dart

import 'dart:io';
import 'package:agvisely/core/services/user_pref_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'notification_service.dart';

// ✅ MUST be top-level — runs in separate isolate when app is killed
// No Get.to, no BuildContext, no UI operations allowed here
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔥 BG FCM received: ${message.notification?.title}');
  // System shows the notification automatically from FCM payload.
  // Only add showNotification() here if you send data-only messages.
}

class FirebaseService {
  // ✅ Singleton so _pendingFcmPayload survives across calls
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final _fcm = FirebaseMessaging.instance;
  final _notif = NotificationService();

  // ✅ Stores FCM payload from terminated-state tap.
  // Consumed by handlePendingFcmNavigation() in HomeController.onReady()
  String? _pendingFcmPayload;

  Future<void> init() async {
    // ── Step 1: Register BG handler FIRST ───────────────────────
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // ── Step 2: Request permission ───────────────────────────────
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('🔔 FCM auth: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('⚠️ Notification permission denied');
      return;
    }

    // ── Step 3: iOS foreground display ──────────────────────────
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── Step 4: Token ────────────────────────────────────────────
    await _refreshToken();

    // ── Step 5: Token refresh listener ──────────────────────────
    _fcm.onTokenRefresh.listen((newToken) async {
      debugPrint('🔄 FCM token refreshed');
      await UserPrefService().saveFireBaseData(newToken);
    });

    // ── Step 6: FOREGROUND messages ──────────────────────────────
    // App is open — FCM is silent on Android, must show locally
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = message.notification?.title ?? '';
      final body  = message.notification?.body  ?? '';
      final type  = message.data['type']         ?? 'general';

      debugPrint('📬 Foreground FCM — type: $type');

      await _notif.showNotification(
        id:      DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title:   title,
        body:    body,
        payload: type,
      );
    });

    // ── Step 7: BACKGROUND tap ───────────────────────────────────
    // App was minimised. Navigator IS ready here — navigate directly.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('👆 FCM background tap: ${message.data}');
      final type = message.data['type'] ?? 'general';
      // ✅ Direct navigation — navigator is guaranteed ready in this state
      Get.toNamed('/notification', arguments: {'type': type});
    });

    // ── Step 8: TERMINATED tap ───────────────────────────────────
    // App was killed. getInitialMessage() fires during cold start.
    // Navigator is NOT ready yet — store payload, navigate in onReady().
    // ✅ NO Future.delayed here — that was the bug
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      debugPrint('🚀 FCM terminated tap — stored for later');
      _pendingFcmPayload = initial.data['type'] ?? 'general';
      // Do NOT call Get.toNamed here — app is still building
    }
  }

  // ✅ Called by HomeController.onReady() — safe to navigate here
  void handlePendingFcmNavigation() {
    if (_pendingFcmPayload != null) {
      final payload = _pendingFcmPayload;
      _pendingFcmPayload = null;
      debugPrint('🧭 FCM pending nav → /notification type: $payload');
      Get.toNamed('/notification', arguments: {'type': payload});
    }
  }

  // ✅ Called from HomeController's background refresh — catches the case
  // where init()'s getToken() call timed out on the splash screen (e.g.
  // slow network on first run) and no token was ever saved. No-ops
  // instantly if a token already exists, so it's safe to call every time.
  Future<void> retryTokenIfMissing() async {
    final existing = UserPrefService().fcmToken;
    if (existing != null && existing.isNotEmpty) return;
    debugPrint('🔄 FCM token missing — retrying (previous attempt may have timed out)');
    await _refreshToken();
  }

  Future<void> _refreshToken() async {
    try {
      if (Platform.isIOS) {
        String? apns = await _fcm.getAPNSToken();
        if (apns == null) {
          await Future.delayed(const Duration(seconds: 2));
          apns = await _fcm.getAPNSToken();
        }
        if (apns == null) {
          debugPrint('⚠️ APNs token null — skipping');
          return;
        }
      }

      final token = await _fcm.getToken().timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          debugPrint('⚠️ FCM getToken timed out — continuing without token');
          return null;
        },
      );
      if (token != null) {
        debugPrint('📱 FCM Token: $token');
        await UserPrefService().saveFireBaseData(token);
      }
    } catch (e) {
      debugPrint('🔥 FCM token error: $e');
    }
  }

}