import 'package:agvisely/core/services/user_pref_service.dart';

class NotificationPrefs {
  static const String _alertsEnabledKey = 'notif_alerts_enabled';
  static const String _generalEnabledKey = 'notif_general_enabled';
  static const String _alertVibrationKey = 'notif_alert_vibration';
  static const String _generalVibrationKey = 'notif_general_vibration';
  static const String _fullScreenAlertKey = 'notif_fullscreen_alert';
  static const String _emergencyBypassKey = 'notif_emergency_bypass';

  static const String _alertRingtoneKey   = 'notif_alert_ringtone';
  static const String _generalRingtoneKey = 'notif_general_ringtone';

// Alert ringtone — defaults to 'notification_alert'
  String get alertRingtone => _prefs.getString(_alertRingtoneKey) ?? 'notification_alert';
  Future<bool>? setAlertRingtone(String v) => _prefs.setString(_alertRingtoneKey, v);

// General ringtone — defaults to 'default'
  String get generalRingtone => _prefs.getString(_generalRingtoneKey) ?? 'default';
  Future<void>? setGeneralRingtone(String v) => _prefs.setString(_generalRingtoneKey, v);

  final _prefs = UserPrefService();

  // ── Alerts enabled (master switch for alert-type notifications)
  bool get alertsEnabled => _prefs.getBool(_alertsEnabledKey) ?? true;

  Future<void>? setAlertsEnabled(bool v) => _prefs.setBool(_alertsEnabledKey, v);

  // ── General notifications enabled
  bool get generalEnabled => _prefs.getBool(_generalEnabledKey) ?? true;

  Future<void>? setGeneralEnabled(bool v) =>
      _prefs.setBool(_generalEnabledKey, v);

  // ── Alert vibration (ALWAYS true by default — user can read-only see it locked)
  bool get alertVibration => _prefs.getBool(_alertVibrationKey) ?? true;

  Future<void>? setAlertVibration(bool v) =>
      _prefs.setBool(_alertVibrationKey, v);

  // ── General notification vibration (off by default)
  bool get generalVibration => _prefs.getBool(_generalVibrationKey) ?? false;

  Future<void>? setGeneralVibration(bool v) =>
      _prefs.setBool(_generalVibrationKey, v);

  // ── Full screen intent for alerts (shows on lock screen)
  bool get fullScreenAlert => _prefs.getBool(_fullScreenAlertKey) ?? true;

  Future<void>? setFullScreenAlert(bool v) =>
      _prefs.setBool(_fullScreenAlertKey, v);

  // ── Emergency bypass: uses alarm stream to bypass silent/DND
  bool get emergencyBypass => _prefs.getBool(_emergencyBypassKey) ?? true;

  Future<void>? setEmergencyBypass(bool v) =>
      _prefs.setBool(_emergencyBypassKey, v);

}
