import 'package:firebase_messaging/firebase_messaging.dart';

import 'user_pref_service.dart';

/// Pushes the device's FCM token to the backend via the profile-update
/// endpoint (`PUT /users/me` with just `{"fcmToken": "..."}`). Tokens rotate,
/// so this is driven by the FCM/auth lifecycle rather than a one-off call —
/// see call sites in AuthController.verifyOtp (login), HomeController.onInit
/// (app start while authenticated), and FirebaseService's onTokenRefresh
/// listener (rotation).
class FcmSyncService {
  FcmSyncService._internal();
  static final FcmSyncService _instance = FcmSyncService._internal();
  factory FcmSyncService() => _instance;

  /// Syncs [token] (or the last-known/freshly-fetched token when omitted) to
  /// the backend, but only when it differs from the last successful sync —
  /// so calling this on every app start/login is cheap and a no-op when
  /// nothing changed. Fails silently; [UserPrefService.lastSyncedFcmToken]
  /// is left unchanged on failure so the next trigger retries.
  Future<void> syncFcmToken({String? token}) async {
    if (!UserPrefService().isLoggedIn) return;

    final t = token ?? UserPrefService().fcmToken ?? await FirebaseMessaging.instance.getToken();
    if (t == null || t.isEmpty) return;
    if (t == UserPrefService().lastSyncedFcmToken) return;

    try {
      await UserPrefService().updateProfile(fcmToken: t);
    } catch (_) {
      // Leave lastSyncedFcmToken unchanged so the next trigger retries.
    }
  }

  /// Called on explicit user-initiated logout so the next login (possibly a
  /// different user, on a shared/reset device) starts with a clean token
  /// instead of one still tied to the previous account. Not called on forced
  /// session-expiry logout — that's not an account switch, so regenerating
  /// the token there would just be a wasted round-trip.
  Future<void> deleteToken() => FirebaseMessaging.instance.deleteToken();
}
