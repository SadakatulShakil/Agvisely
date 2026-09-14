import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../theme/app_fonts.dart';
import 'user_pref_service.dart';

class LocationService {
  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC: Check current permission + service status without requesting
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<bool> isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC: Full location fetch with proper permission dialogs
  // ─────────────────────────────────────────────────────────────────────────

  /// Main entry point — handles all permission states with proper UX dialogs.
  /// [isSilent] = true → no dialogs, just try silently (used for background sync).
  /// [isSilent] = false → show rationale/settings dialogs (used for user-triggered).
  Future<bool> getLocation({
    required VoidCallback onSettingsOpened,
    int timeoutSeconds = 10,
    bool isSilent = false,
  }) async {
    try {
      final position = await _getCurrentLocation(
        onSettingsOpened: onSettingsOpened,
        isSilent: isSilent,
      );

      if (position == null) return false;

      debugPrint(
          '🛰 Got position → Lat:${position.latitude}, Lon:${position.longitude}');

      final fetched = await UserPrefService()
          .fetchLocationDetailsFromApi(lat: position.latitude, lon: position.longitude)
          .timeout(Duration(seconds: timeoutSeconds), onTimeout: () => null);

      if (fetched != null) {
        await UserPrefService()
            .upsertGpsLocation(fetched, makeCurrent: UserPrefService().isFollowingGPS);
      } else if (UserPrefService().isFollowingGPS) {
        // API failed — BMD's fallback: keep the raw coordinates only, so the
        // splash gate treats this as "location known" going forward.
        await UserPrefService().saveLatLonData(
          position.latitude.toStringAsFixed(5),
          position.longitude.toStringAsFixed(5),
        );
      }
      return true;
    } catch (e) {
      debugPrint('❌ Location fetch failed: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC: Request permission with rationale dialog
  // Returns true if permission was granted after the request.
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> requestPermissionWithRationale() async {
    final isBangla = Get.locale?.languageCode == 'bn';

    // Step 1: Check if service is enabled first
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showServiceDisabledDialog(isBangla);
      return false;
    }

    // Step 2: Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    // Already granted
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    }

    // Permanently denied — send to settings
    if (permission == LocationPermission.deniedForever) {
      await _showPermanentlyDeniedDialog(isBangla);
      return false;
    }

    // Denied (not permanently) — show rationale first, then request
    if (permission == LocationPermission.denied) {
      final shouldRequest = await _showRationaleDialog(isBangla);
      if (shouldRequest != true) return false;

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return true;
      }

      // User denied again after rationale
      if (permission == LocationPermission.deniedForever) {
        await _showPermanentlyDeniedDialog(isBangla);
      }
      return false;
    }

    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRIVATE: Get position — handles all permission/service states
  // ─────────────────────────────────────────────────────────────────────────

  Future<Position?> _getCurrentLocation({
    required VoidCallback onSettingsOpened,
    bool isSilent = false,
  }) async {
    final isBangla = Get.locale?.languageCode == 'bn';

    // 1. Check location service
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!isSilent) {
        await _showServiceDisabledDialog(isBangla);
      }
      return null;
    }

    // 2. Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      if (!isSilent) {
        await _showPermanentlyDeniedDialog(isBangla);
      }
      return null;
    }

    if (permission == LocationPermission.denied) {
      if (isSilent) return null; // Don't ask in silent mode

      // Show rationale dialog before requesting
      final shouldRequest = await _showRationaleDialog(isBangla);
      if (shouldRequest != true) return null;

      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        if (permission == LocationPermission.deniedForever) {
          await _showPermanentlyDeniedDialog(isBangla);
        }
        return null;
      }
    }

    // 3. Get position — try the OS's cached last-known fix first (near-instant),
    // then a fresh high-accuracy fix, falling back to a faster/lower-accuracy
    // fix if the high-accuracy request stalls (common on a cold GPS start).
    try {
      final lastKnown = await Geolocator.getLastKnownPosition()
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
      if (lastKnown != null) {
        debugPrint('📍 Using last-known position (fast path)');
        return lastKnown;
      }
    } catch (e) {
      debugPrint('⚠️ getLastKnownPosition failed: $e');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw TimeoutException('GPS Timeout (high accuracy)'),
      );
    } catch (e) {
      debugPrint('⚠️ High-accuracy GPS failed: $e — retrying at medium accuracy');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('GPS Timeout (medium accuracy)'),
      );
    } catch (e) {
      debugPrint('❌ GPS position error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRIVATE: Dialogs
  // ─────────────────────────────────────────────────────────────────────────

  /// Shows WHY we need location — before requesting permission for the first time
  Future<bool?> _showRationaleDialog(bool isBangla) async {
    return await Get.dialog<bool>(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade700, size: 28.sp),
              SizedBox(width: 8.w),
              Text(
                isBangla ? 'অবস্থান অনুমতি' : 'Location Permission',
                style: AppFonts.style(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            isBangla
                ? 'আপনার সঠিক আবহাওয়ার তথ্য পেতে আমাদের আপনার বর্তমান অবস্থান জানা দরকার। অনুগ্রহ করে অবস্থান অনুমতি প্রদান করুন।'
                : 'We need your location to show accurate local weather forecasts for your area. Please allow location access.',
            style: AppFonts.style(fontSize: 14.sp, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                isBangla ? 'এখন না' : 'Not Now',
                style: AppFonts.style(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () => Get.back(result: true),
              child: Text(
                isBangla ? 'অনুমতি দিন' : 'Allow',
                style: AppFonts.style(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Shows when location service (GPS) is turned OFF in system settings
  Future<void> _showServiceDisabledDialog(bool isBangla) async {
    await Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange.shade700, size: 28.sp),
              SizedBox(width: 8.w),
              Text(
                isBangla ? 'লোকেশন বন্ধ' : 'Location Disabled',
                style: AppFonts.style(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            isBangla
                ? 'আপনার ডিভাইসের লোকেশন সার্ভিস বন্ধ আছে। সঠিক আবহাওয়া দেখতে লোকেশন চালু করুন।'
                : 'Your device location service is turned off. Please enable location to get accurate weather for your area.',
            style: AppFonts.style(fontSize: 14.sp, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                isBangla ? 'পরে করব' : 'Later',
                style: AppFonts.style(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () async {
                Get.back();
                await Geolocator.openLocationSettings();
              },
              child: Text(
                isBangla ? 'সেটিংস খুলুন' : 'Open Settings',
                style: AppFonts.style(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Shows when permission is permanently denied — must go to app settings
  Future<void> _showPermanentlyDeniedDialog(bool isBangla) async {
    await Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(Icons.location_disabled,
                  color: Colors.red.shade700, size: 28.sp),
              SizedBox(width: 8.w),
              Text(
                isBangla ? 'অনুমতি প্রত্যাখ্যাত' : 'Permission Denied',
                style: AppFonts.style(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            isBangla
                ? 'লোকেশন অনুমতি স্থায়ীভাবে বন্ধ করা হয়েছে। সেটিংসে গিয়ে অবস্থান অনুমতি চালু করুন।'
                : 'Location permission has been permanently denied. Please go to app settings and enable location permission.',
            style: AppFonts.style(fontSize: 14.sp, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                isBangla ? 'পরে করব' : 'Later',
                style: AppFonts.style(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () async {
                Get.back();
                await Geolocator.openAppSettings();
              },
              child: Text(
                isBangla ? 'অ্যাপ সেটিংস' : 'App Settings',
                style: AppFonts.style(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
