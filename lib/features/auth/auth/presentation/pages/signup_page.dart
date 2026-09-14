import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/utils/app_logo.dart';
import '../../../../../core/utils/bd_locations.dart';
import '../../../../location/data/location_repository.dart';
import '../../domen/controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : Get.put(AuthController(), permanent: true);
    final isBn = Get.locale?.languageCode == 'bn';
    String areaName(NamedArea a) => isBn ? a.nameBn : a.name;
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

                const FieldLabel('Your Name'),
                TextField(
                  controller: c.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: agFieldDecoration('Write your name here').copyWith(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    hintStyle: TextStyle(fontSize: 16.sp,
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
                        hintStyle: TextStyle(fontSize: 16.sp,
                            color: AppColors.textSecondaryLight),
                      ),
                      items: BdLocations.professions
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) => c.profession.value = v!,
                    )),

                const FieldLabel('District'),
                Obx(() => DropdownButtonFormField<String>(
                      value: c.selectedDistrict.value?.code,
                      isExpanded: true,
                      decoration: agFieldDecoration('Select district').copyWith(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        hintStyle: TextStyle(fontSize: 16.sp,
                            color: AppColors.textSecondaryLight),
                      ),
                      items: c.districtOptions
                          .map((d) => DropdownMenuItem(value: d.code, child: Text(areaName(d))))
                          .toList(),
                      onChanged: c.districtOptions.isEmpty ? null : c.onDistrictChanged,
                    )),

                const FieldLabel('Upazila'),
                Obx(() => DropdownButtonFormField<String>(
                      value: c.selectedUpazila.value?.code,
                      isExpanded: true,
                      decoration: agFieldDecoration('Select upazila').copyWith(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        hintStyle: TextStyle(fontSize: 16.sp,
                            color: AppColors.textSecondaryLight),
                      ),
                      items: c.upazilaOptions
                          .map((u) => DropdownMenuItem(value: u.code, child: Text(areaName(u))))
                          .toList(),
                      onChanged: c.upazilaOptions.isEmpty ? null : c.onUpazilaChanged,
                    )),

                const FieldLabel('Contact No'),
                TextField(
                  controller: c.signupPhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  decoration: agFieldDecoration('+8801646923894').copyWith(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    hintStyle: TextStyle(fontSize: 16.sp,
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
