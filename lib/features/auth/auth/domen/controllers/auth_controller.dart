import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/user_pref_service.dart';
import '../../../../../core/utils/bd_locations.dart';
import '../../../../../core/utils/phone_util.dart';
import '../../../../home/presentation/pages/home_page.dart';
import '../../models/signup_request.dart';
import '../../presentation/pages/otp_page.dart';

class AuthController extends GetxController {
  // ── Demo OTP ───────────────────────────────────────────────────────────────
  /// Every user passes with this code until the real SMS backend is wired.
  static const String demoOtp = '1234';
  static const int otpLength = 4; // NOTE: Figma shows 6 boxes; spec says 4.

  final isSubmitting = false.obs;

  // ── Login ────────────────────────────────────────────────────────────────
  final loginPhone = TextEditingController();

  // ── Sign-up form ───────────────────────────────────────────────────────────
  final name = TextEditingController();
  final signupPhone = TextEditingController();
  final profession = BdLocations.professions.first.obs; // Farmer
  final Rxn<String> district = Rxn<String>();
  final Rxn<String> upazila = Rxn<String>();

  List<String> get upazilaOptions => BdLocations.upazilasOf(district.value);

  void onDistrictChanged(String? d) {
    district.value = d;
    upazila.value = null; // reset dependent dropdown
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Login flow: validate the phone, then go to OTP.
  void requestOtpForLogin() {
    final err = PhoneUtil.validate(loginPhone.text);
    if (err != null) {
      _toast(err);
      return;
    }
    final phone = PhoneUtil.normalize(loginPhone.text)!;
    Get.to(() => OtpPage(phone: phone, isSignup: false));
  }

  /// Sign-up flow: validate every field, then go to OTP.
  void requestOtpForSignup() {
    if (name.text.trim().isEmpty) return _toast('Please enter your name');
    if (district.value == null) return _toast('Please select your district');
    if (upazila.value == null) return _toast('Please select your upazila');

    final err = PhoneUtil.validate(signupPhone.text);
    if (err != null) return _toast(err);

    final req = SignupRequest(
      name: name.text.trim(),
      profession: profession.value,
      district: district.value!,
      upazila: upazila.value!,
      phone: PhoneUtil.normalize(signupPhone.text)!,
    );
    // TODO: POST req.toJson() to ApiEndpoints.sendOtp when backend is ready.
    Get.to(() => OtpPage(phone: req.phone, isSignup: true));
  }

  /// Verify the entered code. Demo: matches [demoOtp]. On success, mark the
  /// user logged in and land on Home.
  Future<void> verifyOtp(String code, {required String phone}) async {
    if (code.length != otpLength) return _toast('Enter the $otpLength-digit code');
    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 400)); // fake network
    isSubmitting.value = false;

    if (code != demoOtp) {
      _toast('Incorrect OTP. Try $demoOtp for the demo.');
      return;
    }

    // TODO: exchange OTP for a real token via ApiEndpoints.verifyOtp,
    // then persist it in flutter_secure_storage.
    await UserPrefService().setLoggedIn(true);
    await UserPrefService().setLocationName(district.value ?? '');
    Get.offAll(() => const HomePage());
  }

  void _toast(String msg) => Get.snackbar(
        'Agvisely',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );

  @override
  void onClose() {
    loginPhone.dispose();
    name.dispose();
    signupPhone.dispose();
    super.onClose();
  }
}
