import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                  'login.welcome_back'.tr,
                  style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy),
                ),
                const SizedBox(height: 8),
                Text(
                  'login.subtitle'.tr,
                  style: TextStyle(fontSize: 18.sp, color: AppColors.textSecondaryLight),
                ),
                FieldLabel('auth.contact_no'.tr),
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
                      label: 'auth.request_otp'.tr,
                      loading: c.isSubmitting.value,
                      onPressed: c.submitLogin,
                    )),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Get.to(() => const SignupPage()),
                    child: Text.rich(
                      TextSpan(
                        text: '${'login.new_here'.tr}  ',
                        style: const TextStyle(color: AppColors.textSecondaryLight),
                        children: [
                          TextSpan(
                            text: 'login.create_account'.tr,
                            style: const TextStyle(
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
