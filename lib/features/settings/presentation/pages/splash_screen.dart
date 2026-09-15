import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/update_service.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/app_logo.dart';
import '../../../../core/utils/force_update_dialog.dart';
import '../../../location/models/location_gate_destination.dart';
import '../../../location/presentation/pages/location_gate_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _updateCheckDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runUpdateCheckThenInit();
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 1 — Update check
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _runUpdateCheckThenInit() async {
    if (_updateCheckDone) return;
    _updateCheckDone = true;

    // Fire both concurrently — Firebase init no longer waits for the
    // update-check network round-trip (and vice versa).
    final updateFuture = UpdateService().checkForUpdate().timeout(
      const Duration(seconds: 8),
      onTimeout: () => UpdateResult.none(),
    ).catchError((_) => UpdateResult.none());

    final firebaseFuture = FirebaseService().init();

    final result = await updateFuture;

    if (!mounted) return;

    if (result.isUpdateRequired) {
      // Don't leave the Firebase init dangling — still let it finish.
      await firebaseFuture;
      await _handleUpdateRequired(result);
      return;
    }

    await firebaseFuture;
    _proceed();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleUpdateRequired(UpdateResult result) async {
    if (Platform.isAndroid) {
      await _triggerAndroidUpdate();
    } else if (Platform.isIOS) {
      await _showIOSUpdateDialog(result.storeVersion);
    }
  }

  Future<void> _triggerAndroidUpdate() async {
    final info = await PackageInfo.fromPlatform();
    await UpdateService().performUpdate(packageName: info.packageName);
    _updateCheckDone = false;
  }

  Future<void> _showIOSUpdateDialog(String? storeVersion) async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    await ForceUpdateDialog.show(
      context,
      storeVersion: storeVersion,
      onUpdatePressed: () {
        UpdateService().performUpdate(packageName: info.packageName);
      },
    );
    if (mounted) {
      _updateCheckDone = false;
      await _runUpdateCheckThenInit();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 2 — Onboarding / login / location gate
  // ─────────────────────────────────────────────────────────────────────────

  void _proceed() {
    if (!mounted) return;
    final prefs = UserPrefService();
    if (!prefs.hasOnboarded) {
      Get.off(() => const OnboardingPage());
    } else if (!prefs.isLoggedIn) {
      // Not logged in yet — resolve location (if not already known) before
      // Login/Signup, so the signup form can auto-fill district/upazila.
      Get.off(() => const LocationGatePage(
          destination: LocationGateDestination.login));
    } else {
      Get.off(() => const LocationGatePage());
    }
  }

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
              AppLogo(height: 96.h),
              SizedBox(height: 20.h),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Localized weather forecasts and expert farming advice — right in your hands.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16, color: AppColors.textSecondaryLight, height: 1.4),
                ),
              ),
              SizedBox(height: 38.h),
              Text(
                'Technical Partner: RIMES',
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
