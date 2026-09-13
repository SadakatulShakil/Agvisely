import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/app_logo.dart';
import '../../../../main.dart' show dbServiceReady;
import '../../../home/presentation/pages/home_page.dart';
import '../../domen/binding/select_location_binding.dart';
import 'select_location_page.dart';

/// Reusable location gate — decides whether the user lands straight on
/// Home (already has a saved location) or has to go through the GPS
/// permission flow first, falling back to manual search on any dead end.
///
/// Entry points: SplashScreen (app launch, once onboarded + logged in) and
/// AuthController.verifyOtp() (fresh login).
class LocationGatePage extends StatefulWidget {
  const LocationGatePage({super.key});

  @override
  State<LocationGatePage> createState() => _LocationGatePageState();
}

class _LocationGatePageState extends State<LocationGatePage>
    with WidgetsBindingObserver {
  bool _initialized = false;
  bool _shouldNavigate = false;

  // Tracks why we are waiting for the user to return from settings
  bool _waitingForLocationService = false; // user went to enable GPS
  bool _waitingForPermission = false; // user went to app settings for permission

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    if (_waitingForLocationService) {
      debugPrint('DEBUG: Returned from location settings — retrying...');
      _waitingForLocationService = false;
      _initialized = false; // allow _resolve to run again
      _resolve();
      return;
    }

    if (_waitingForPermission) {
      debugPrint('DEBUG: Returned from app settings — retrying...');
      _waitingForPermission = false;
      _initialized = false;
      _resolve();
      return;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GATE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _resolve() async {
    if (_initialized || _shouldNavigate) return;
    _initialized = true;

    // Already has a saved location — go straight to home
    if (UserPrefService().getLat() != null &&
        UserPrefService().getLat()!.isNotEmpty) {
      _navigateToHome();
      return;
    }

    // No saved location — try to get GPS
    await _tryGetLocationAndNavigate();
  }

  Future<void> _tryGetLocationAndNavigate() async {
    final isBangla = Get.locale?.languageCode == 'bn';

    // ── STEP A: Check if location service (GPS) is enabled ──
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final wantsToEnable = await _showServiceDisabledDialog(isBangla);
      if (wantsToEnable == true) {
        _waitingForLocationService = true;
        _initialized = false; // allow retry on resume
        await Geolocator.openLocationSettings();
        return;
      } else {
        _goToLocationSearch();
        return;
      }
    }

    // ── STEP B: Check permission ──
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      final wantsToOpenSettings = await _showPermanentlyDeniedDialog(isBangla);
      if (wantsToOpenSettings == true) {
        _waitingForPermission = true;
        _initialized = false;
        await Geolocator.openAppSettings();
        return;
      } else {
        _goToLocationSearch();
        return;
      }
    }

    if (permission == LocationPermission.denied) {
      final shouldRequest = await _showRationaleDialog(isBangla);
      if (shouldRequest != true) {
        _goToLocationSearch();
        return;
      }
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        if (permission == LocationPermission.deniedForever) {
          final wantsToOpenSettings =
              await _showPermanentlyDeniedDialog(isBangla);
          if (wantsToOpenSettings == true) {
            _waitingForPermission = true;
            _initialized = false;
            await Geolocator.openAppSettings();
            return;
          }
        }
        _goToLocationSearch();
        return;
      }
    }

    // ── STEP C: Permission granted — fetch GPS location ──
    final success = await LocationService()
        .getLocation(onSettingsOpened: () {}, isSilent: false)
        .timeout(const Duration(seconds: 15), onTimeout: () => false);

    if (success) {
      _navigateToHome();
    } else {
      _goToLocationSearch();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DIALOGS — all have "Search Manually" as the secondary option
  // so the user is never stuck
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool?> _showServiceDisabledDialog(bool isBangla) async {
    return await Get.dialog<bool>(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBangla ? 'লোকেশন বন্ধ আছে' : 'Location is Off',
                  style: AppFonts.style(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            isBangla
                ? 'আপনার সঠিক আবহাওয়া দেখতে ডিভাইসের লোকেশন চালু করুন। অথবা নিজে এলাকা খুঁজে নিন।'
                : 'Turn on your device location to get accurate local weather, or search for your area manually.',
            style: AppFonts.style(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                isBangla ? 'এলাকা খুঁজুন' : 'Search Manually',
                style: AppFonts.style(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Get.back(result: true),
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

  Future<bool?> _showRationaleDialog(bool isBangla) async {
    return await Get.dialog<bool>(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade700, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBangla ? 'অবস্থান অনুমতি' : 'Location Permission',
                  style: AppFonts.style(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            isBangla
                ? 'আপনার এলাকার সঠিক আবহাওয়া দেখতে আমাদের আপনার বর্তমান অবস্থান জানা দরকার। অথবা নিজে এলাকা খুঁজে নিন।'
                : 'We need your location to show accurate weather for your area. Or you can search your area manually.',
            style: AppFonts.style(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                isBangla ? 'এলাকা খুঁজুন' : 'Search Manually',
                style: AppFonts.style(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Future<bool?> _showPermanentlyDeniedDialog(bool isBangla) async {
    return await Get.dialog<bool>(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.location_disabled, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBangla ? 'অনুমতি প্রত্যাখ্যাত' : 'Permission Denied',
                  style: AppFonts.style(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            isBangla
                ? 'লোকেশন অনুমতি বন্ধ করা আছে। অ্যাপ সেটিংসে গিয়ে অনুমতি চালু করুন। অথবা নিজে এলাকা খুঁজে নিন।'
                : 'Location permission is disabled. Go to app settings to enable it, or search your area manually.',
            style: AppFonts.style(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                isBangla ? 'এলাকা খুঁজুন' : 'Search Manually',
                style: AppFonts.style(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Get.back(result: true),
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

  // ─────────────────────────────────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _navigateToHome() async {
    if (_shouldNavigate) return;
    _shouldNavigate = true;
    // DBService is registered post-first-frame (see main.dart's
    // _deferredInit) — wait for registration so HomePage/HomeController
    // can't race a cold start.
    await dbServiceReady.future;
    Get.offAll(
      () => const HomePage(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _goToLocationSearch() {
    if (_shouldNavigate) return;
    _shouldNavigate = true;
    Get.offAll(
      () => SelectLocationPage(isFirstInstall: true),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 400),
      binding: SelectLocationBinding(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2F4F1), Color(0xFFDDE6D6)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(height: 96),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
