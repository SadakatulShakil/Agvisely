import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/utils/app_logo.dart';
import '../../../../../core/utils/bd_locations.dart';
import '../../domen/controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : Get.put(AuthController(), permanent: true);
    return Scaffold(
      body: SageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Center(child: AppLogo(height: 84)),
                SizedBox(height: 28.h),
                Text(
                  'To create a quick and easy one-time sign-up, you only need some pieces of information',
                  style: TextStyle(fontSize: 18.sp, color: AppColors.primaryDark, height: 1.3),
                ),
                const SizedBox(height: 32),
                const FieldLabel('Your Name'),
                TextField(
                  controller: c.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: agFieldDecoration('Write your name here').copyWith(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    hintStyle: TextStyle(fontSize: 18.sp,
                        color: AppColors.textSecondaryLight),
                  ),
                ),

                const FieldLabel('Your Profession'),
                Obx(() => DropdownButtonFormField<String>(
                      value: c.profession.value,
                      isExpanded: true,
                      decoration: agFieldDecoration('').copyWith(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                      items: BdLocations.professions
                          .map((p) => DropdownMenuItem(value: p, child: Text(p, style: TextStyle(fontSize: 18.sp,
                          color: AppColors.textSecondaryLight)
                        )
                          )
                            )
                          .toList(),
                      onChanged: (v) => c.profession.value = v!,
                    )),

                const FieldLabel('Contact No'),
                TextField(
                  controller: c.signupPhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  decoration: agFieldDecoration('+8801751330394').copyWith(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    hintStyle: TextStyle(fontSize: 18.sp,
                        color: AppColors.textSecondaryLight),
                  ),
                ),

                const SizedBox(height: 32),
                Obx(() => AgButton(
                      label: 'Request OTP',
                      loading: c.isSubmitting.value,
                      onPressed: c.requestOtpForSignup,
                    )),
                SizedBox(height: 8.h),
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account?  ',
                        style: TextStyle(color: AppColors.textSecondaryLight),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
