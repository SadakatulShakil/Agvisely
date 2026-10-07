import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/services/user_pref_service.dart';
import '../../../../../core/utils/phone_util.dart';
import '../../../../../models/profession_model.dart';
import '../../../../location/presentation/pages/location_gate_page.dart';
import '../../models/signup_request.dart';
import '../../presentation/pages/otp_page.dart';

class AuthController extends GetxController {
  static const int otpLength = 4; // NOTE: Figma shows 6 boxes; spec says 4.

  static const _secureStorage = FlutterSecureStorage();
  static const _tokenKey = 'ACCESS_TOKEN';

  // Used only when the professions API is unreachable, so signup never
  // dead-ends on a broken dropdown.
  static const _fallbackProfessions = <ProfessionModel>[
    ProfessionModel(id: 1, name: 'Farmer', nameBn: 'কৃষক', isDefault: true),
    ProfessionModel(id: 2, name: 'Agri Officer', nameBn: 'কৃষি কর্মকর্তা'),
    ProfessionModel(id: 3, name: 'Trader', nameBn: 'ব্যবসায়ী'),
    ProfessionModel(id: 4, name: 'Student', nameBn: 'শিক্ষার্থী'),
    ProfessionModel(id: 5, name: 'Other', nameBn: 'অন্যান্য'),
  ];

  final isSubmitting = false.obs;

  // ── Professions (sign-up dropdown) ──────────────────────────────────────
  final professions = <ProfessionModel>[].obs;
  final selectedProfession = Rxn<ProfessionModel>();
  final professionsLoading = false.obs;
  final professionsLoadFailed = false.obs;

  // ── Login ────────────────────────────────────────────────────────────────
  final loginPhone = TextEditingController();

  // ── Sign-up form ───────────────────────────────────────────────────────────
  final name = TextEditingController();
  final signupPhone = TextEditingController();

  // District/Upazila are no longer picked on this form — the location gate
  // (right after onboarding) already resolved them via GPS or the manual
  // picker before the user ever reaches signup, and the signup API itself
  // doesn't take them.

  @override
  void onInit() {
    super.onInit();
    loadProfessions();
  }

  // ── Professions ──────────────────────────────────────────────────────────

  Future<void> loadProfessions() async {
    professionsLoading.value = true;
    professionsLoadFailed.value = false;
    try {
      final resp = await ApiClient().get(ApiEndpoints.professions);
      final data = resp is Map ? resp['data'] : null;
      final list = data is List
          ? data
              .whereType<Map>()
              .map((e) => ProfessionModel.fromJson(e.cast<String, dynamic>()))
              .toList()
          : <ProfessionModel>[];

      if (list.isEmpty) throw Exception('No professions returned');

      // No pre-selection — the user must explicitly pick one.
      professions.assignAll(list);
    } catch (_) {
      professionsLoadFailed.value = true;
      professions.assignAll(_fallbackProfessions);
    } finally {
      professionsLoading.value = false;
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Login flow: validate the phone, POST it, then go to OTP.
  Future<void> submitLogin() async {
    final err = PhoneUtil.validate(loginPhone.text);
    if (err != null) return _toast(err);

    final phone = PhoneUtil.normalize(loginPhone.text)!;
    isSubmitting.value = true;
    try {
      await _postLogin(phone);
      Get.to(() => OtpPage(phone: phone, purpose: 'login'));
    } catch (e) {
      _toast(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Sign-up flow: validate every field, POST it, then go to OTP.
  Future<void> submitSignup() async {
    if (name.text.trim().isEmpty) return _toast('Please enter your name');

    final err = PhoneUtil.validate(signupPhone.text);
    if (err != null) return _toast(err);

    final profession = selectedProfession.value;
    if (profession == null) return _toast('signup.select_profession_error'.tr);

    final phone = PhoneUtil.normalize(signupPhone.text)!;
    final req = SignupRequest(
      name: name.text.trim(),
      professionId: profession.id,
      phone: phone,
    );

    isSubmitting.value = true;
    try {
      await _postSignup(req);
      Get.to(() => OtpPage(phone: phone, purpose: 'signup'));
    } catch (e) {
      _toast(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Verify the entered code against the real backend. On success, store
  /// the token (if returned) and mark the user logged in, then run the
  /// location gate to Home — same as before.
  Future<void> verifyOtp(
    String code, {
    required String phone,
    required String purpose,
  }) async {
    if (code.length != otpLength) return _toast('Enter the $otpLength-digit code');

    isSubmitting.value = true;
    try {
      final resp = await ApiClient().post(
        ApiEndpoints.verifyOtpUrl,
        body: {'phone': phone, 'otp': code, 'purpose': purpose},
      );

      final data = resp is Map ? resp['data'] : null;
      final token = data is Map ? (data['token'] ?? data['accessToken']) : null;
      if (token is String && token.isNotEmpty) {
        await _secureStorage.write(key: _tokenKey, value: token);
      }

      await UserPrefService().setLoggedIn(true);
      Get.offAll(() => const LocationGatePage());
    } catch (e) {
      _toast(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Re-sends the OTP for the given phone/purpose. There's no dedicated
  /// resend endpoint — this just re-fires the same signup/login request
  /// without navigating again (the user is already on the OTP page).
  Future<void> resendOtp({required String phone, required String purpose}) async {
    isSubmitting.value = true;
    try {
      if (purpose == 'signup') {
        final profession = selectedProfession.value;
        if (profession == null) return _toast('signup.select_profession_error'.tr);
        await _postSignup(SignupRequest(
          name: name.text.trim(),
          professionId: profession.id,
          phone: phone,
        ));
      } else {
        await _postLogin(phone);
      }
      _toast('A new OTP has been sent');
    } catch (e) {
      _toast(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _postLogin(String phone) {
    return ApiClient().post(ApiEndpoints.loginUrl, body: {'phone': phone});
  }

  Future<void> _postSignup(SignupRequest req) {
    return ApiClient().post(ApiEndpoints.signupUrl, body: req.toJson());
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
