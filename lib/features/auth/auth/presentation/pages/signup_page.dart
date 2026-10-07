import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/utils/app_logo.dart';
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
                  'signup.intro'.tr,
                  style: TextStyle(fontSize: 18.sp, color: AppColors.primaryDark, height: 1.3),
                ),
                const SizedBox(height: 32),
                FieldLabel('signup.your_name'.tr),
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

                FieldLabel('signup.your_profession'.tr),
                Obx(() {
                  if (c.professionsLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final isBn = Get.locale?.languageCode == 'bn';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        value: c.selectedProfession.value?.id,
                        isExpanded: true,
                        decoration: agFieldDecoration('').copyWith(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        ),
                        items: c.professions
                            .map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.label(isBn),
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          color: AppColors.textSecondaryLight)),
                                ))
                            .toList(),
                        onChanged: (id) => c.selectedProfession.value =
                            c.professions.firstWhereOrNull((p) => p.id == id),
                      ),
                      if (c.professionsLoadFailed.value)
                        TextButton(
                          onPressed: c.loadProfessions,
                          child: const Text('Retry'),
                        ),
                    ],
                  );
                }),

                FieldLabel('auth.contact_no'.tr),
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
                      label: 'auth.request_otp'.tr,
                      loading: c.isSubmitting.value,
                      onPressed: c.submitSignup,
                    )),
                SizedBox(height: 8.h),
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text.rich(
                      TextSpan(
                        text: '${'signup.already_have_account'.tr}  ',
                        style: const TextStyle(color: AppColors.textSecondaryLight),
                        children: [
                          TextSpan(
                            text: 'auth.login'.tr,
                            style: const TextStyle(
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
