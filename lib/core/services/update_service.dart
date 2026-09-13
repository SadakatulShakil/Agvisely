import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC API — called from SplashScreen
  // ─────────────────────────────────────────────────────────────────────────

  /// Checks whether an update is required.
  /// Never throws — always fail-safe so the user is never blocked by a bug.
  Future<UpdateResult> checkForUpdate() async {
    try {
      if (Platform.isAndroid) return await _checkAndroid();
      if (Platform.isIOS) return await _checkIOS();
      return UpdateResult.none();
    } catch (e) {
      debugPrint('⚠️ UpdateService.checkForUpdate error: $e');
      return UpdateResult.none(); // fail-safe: never block user on error
    }
  }

  /// Triggers the actual update.
  /// Android → starts Play Core immediate update UI (download inside app).
  /// iOS     → opens App Store listing in the store app.
  Future<void> performUpdate({required String packageName}) async {
    try {
      if (Platform.isAndroid) {
        await _performAndroidUpdate(packageName);
      } else if (Platform.isIOS) {
        await _openAppStore(packageName);
      }
    } catch (e) {
      debugPrint('⚠️ UpdateService.performUpdate error: $e');
    }
  }

  Future<void> _performAndroidUpdate(String packageName) async {
    AppUpdateInfo info;
    try {
      info = await InAppUpdate.checkForUpdate()
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      // Can't query Play — last resort: open the store page.
      debugPrint('⚠️ checkForUpdate failed in perform: $e');
      await _openPlayStore(packageName);
      return;
    }

    // 1. Prefer immediate (blocking, download-in-app, auto-relaunch)
    if (info.immediateUpdateAllowed) {
      try {
        await InAppUpdate.performImmediateUpdate();
        return; // app restarts after install
      } catch (e) {
        debugPrint('⚠️ immediate update failed: $e');
        // fall through to flexible / store
      }
    }

    // 2. Fall back to flexible (background download, then install)
    if (info.flexibleUpdateAllowed) {
      try {
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result == AppUpdateResult.success) {
          await InAppUpdate.completeFlexibleUpdate();
          return;
        }
      } catch (e) {
        debugPrint('⚠️ flexible update failed: $e');
        // fall through to store
      }
    }

    // 3. Last resort — open the Play Store listing so the user
    //    can update manually. Guarantees NO device is left with
    //    a silent no-op (this is what the S24 was hitting).
    await _openPlayStore(packageName);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ANDROID — Play Core In-App Update API
  // ─────────────────────────────────────────────────────────────────────────

  Future<UpdateResult> _checkAndroid() async {
    final info = await InAppUpdate.checkForUpdate()
        .timeout(const Duration(seconds: 8));

    // An update is "required" whenever Play says one is
    // available — REGARDLESS of immediate/flexible. Which
    // mechanism we use is decided in performUpdate(). This is
    // the S24 fix: that device reports updateAvailable but
    // immediateUpdateAllowed=false, so the old
    // (available && immediateAllowed) gate silently skipped it.
    if (info.updateAvailability ==
        UpdateAvailability.updateAvailable) {
      return UpdateResult.required();
    }
    return UpdateResult.none();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // iOS — iTunes Lookup API (public, no auth needed)
  // ─────────────────────────────────────────────────────────────────────────

  Future<UpdateResult> _checkIOS() async {
    final info = await PackageInfo.fromPlatform();
    final storeVersion = await _fetchAppStoreVersion(info.packageName);

    if (storeVersion == null) return UpdateResult.none();

    if (_isNewer(storeVersion, info.version)) {
      return UpdateResult.required(storeVersion: storeVersion);
    }

    return UpdateResult.none();
  }

  Future<String?> _fetchAppStoreVersion(String bundleId) async {
    final uri =
    Uri.parse('https://itunes.apple.com/lookup?bundleId=$bundleId');

    final response = await http
        .get(uri, headers: {'User-Agent': 'Mozilla/5.0'})
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) return null;

    // Targeted string search — avoids importing dart:convert for one field.
    const key = '"version":"';
    final body = response.body;
    final start = body.indexOf(key);
    if (start == -1) return null;

    final valueStart = start + key.length;
    final end = body.indexOf('"', valueStart);
    return end == -1 ? null : body.substring(valueStart, end);
  }

  Future<void> _openAppStore(String packageName) async {
    // Use your numeric Apple ID: 'https://apps.apple.com/app/id123456789'
    // Or bundle ID redirect (works but slower):
    final uri = Uri.parse('https://apps.apple.com/app/$packageName');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPlayStore(String packageName) async {
    final marketUri = Uri.parse('market://details?id=$packageName');
    final webUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageName');
    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri,
            mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri,
            mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('⚠️ openPlayStore failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic version comparison — "1.10.0" > "1.9.3" ✓  (string compare fails)
  // ─────────────────────────────────────────────────────────────────────────

  bool _isNewer(String storeVer, String currentVer) {
    List<int> parse(String v) =>
        v.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final store = parse(storeVer);
    final current = parse(currentVer);

    while (store.length < 3) {
      store.add(0);
    }
    while (current.length < 3) {
      current.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (store[i] > current[i]) return true;
      if (store[i] < current[i]) return false;
    }
    return false; // versions are equal → no update needed
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result model — typed, no raw booleans flying across files
// ─────────────────────────────────────────────────────────────────────────────

class UpdateResult {
  final bool isUpdateRequired;

  /// Populated on iOS to show version number in the dialog (optional display).
  final String? storeVersion;

  const UpdateResult._({
    required this.isUpdateRequired,
    this.storeVersion,
  });

  factory UpdateResult.none() =>
      const UpdateResult._(isUpdateRequired: false);

  factory UpdateResult.required({String? storeVersion}) =>
      UpdateResult._(isUpdateRequired: true, storeVersion: storeVersion);
}
