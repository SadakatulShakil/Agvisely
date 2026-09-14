import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/user_pref_service.dart';
import '../../../../../core/utils/bd_locations.dart';
import '../../../../../core/utils/phone_util.dart';
import '../../../../location/data/location_repository.dart';
import '../../../../location/presentation/pages/location_gate_page.dart';
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

  // District/Upazila — sourced from the real dataset via LocationRepository,
  // the same source the location picker uses (assets/json/location_list.json).
  final LocationRepository _locationRepo = LocationRepository();
  final districtOptions = <NamedArea>[].obs;
  final upazilaOptions = <NamedArea>[].obs;
  final Rxn<NamedArea> selectedDistrict = Rxn<NamedArea>();
  final Rxn<NamedArea> selectedUpazila = Rxn<NamedArea>();
  final areasLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    areasLoading.value = true;
    districtOptions.value = await _locationRepo.districts();
    areasLoading.value = false;
  }

  Future<void> onDistrictChanged(String? code) async {
    selectedDistrict.value = districtOptions.firstWhereOrNull((d) => d.code == code);
    selectedUpazila.value = null;
    upazilaOptions.clear();
    if (code != null) upazilaOptions.value = await _locationRepo.upazilasOf(code);
  }

  void onUpazilaChanged(String? code) {
    selectedUpazila.value = upazilaOptions.firstWhereOrNull((u) => u.code == code);
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
    if (selectedDistrict.value == null) return _toast('Please select your district');
    if (selectedUpazila.value == null) return _toast('Please select your upazila');

    final err = PhoneUtil.validate(signupPhone.text);
    if (err != null) return _toast(err);

    final req = SignupRequest(
      name: name.text.trim(),
      profession: profession.value,
      district: selectedDistrict.value!.name,
      upazila: selectedUpazila.value!.name,
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
    await UserPrefService().setLocationName(selectedDistrict.value?.name ?? '');
    Get.offAll(() => const LocationGatePage());
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
