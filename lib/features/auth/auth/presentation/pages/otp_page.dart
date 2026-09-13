import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/utils/app_logo.dart';
import '../../domen/controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/otp_boxes.dart';

class OtpPage extends StatefulWidget {
  final String phone; // canonical 01XXXXXXXXX
  final bool isSignup;
  const OtpPage({super.key, required this.phone, required this.isSignup});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final c = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : Get.put(AuthController(), permanent: true);
  String _code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: SageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const AppLogo(height: 72),
                const SizedBox(height: 48),
                Text(
                  'OTP Verification Code',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark),
                ),
                const SizedBox(height: 12),
                Text(
                  'We have sent the verification code to\n${widget.phone}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 32),
                OtpBoxes(
                  length: AuthController.otpLength,
                  onChanged: (v) => setState(() => _code = v),
                  onCompleted: (v) => c.verifyOtp(v, phone: widget.phone),
                ),
                const SizedBox(height: 32),
                Obx(() => AgButton(
                      label: 'Verify OTP',
                      loading: c.isSubmitting.value,
                      onPressed: () => c.verifyOtp(_code, phone: widget.phone),
                    )),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.snackbar('Agvisely', 'Demo code: 1234',
                      snackPosition: SnackPosition.BOTTOM),
                  child: const Text('Resend code',
                      style: TextStyle(color: AppColors.primaryDark)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
