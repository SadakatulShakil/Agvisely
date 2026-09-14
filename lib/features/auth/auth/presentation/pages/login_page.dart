import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/utils/app_logo.dart';
import '../../domen/controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';
import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : Get.put(AuthController(), permanent: true);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Center(child: AppLogo(height: 84)),
                const SizedBox(height: 40),
                Text(
                  'Welcome back',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your mobile number to receive a one-time code',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondaryLight),
                ),
                const FieldLabel('Contact No'),
                TextField(
                  controller: c.loginPhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  decoration: agFieldDecoration('+8801XXXXXXXXX'),
                ),
                const SizedBox(height: 32),
                Obx(() => AgButton(
                      label: 'Request OTP',
                      loading: c.isSubmitting.value,
                      onPressed: c.requestOtpForLogin,
                    )),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Get.to(() => const SignupPage()),
                    child: const Text.rich(
                      TextSpan(
                        text: "New here?  ",
                        style: TextStyle(color: AppColors.textSecondaryLight),
                        children: [
                          TextSpan(
                            text: 'Create an account',
                            style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
