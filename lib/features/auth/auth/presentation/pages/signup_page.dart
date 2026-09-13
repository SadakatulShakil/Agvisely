import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Center(child: AppLogo(height: 84)),
                const SizedBox(height: 28),
                Text(
                  'To create a quick and easy one-time sign-up, you only need some pieces of information',
                  style: TextStyle(fontSize: 20, color: AppColors.navy, height: 1.3),
                ),

                const FieldLabel('Your Name'),
                TextField(
                  controller: c.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: agFieldDecoration('Write your name here'),
                ),

                const FieldLabel('Your Profession'),
                Obx(() => DropdownButtonFormField<String>(
                      value: c.profession.value,
                      isExpanded: true,
                      decoration: agFieldDecoration(''),
                      items: BdLocations.professions
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) => c.profession.value = v!,
                    )),

                const FieldLabel('District'),
                Obx(() => DropdownButtonFormField<String>(
                      value: c.district.value,
                      isExpanded: true,
                      decoration: agFieldDecoration('Select district'),
                      items: BdLocations.districts
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: c.onDistrictChanged,
                    )),

                const FieldLabel('Upazila'),
                Obx(() => DropdownButtonFormField<String>(
                      value: c.upazila.value,
                      isExpanded: true,
                      decoration: agFieldDecoration('Select upazila'),
                      items: c.upazilaOptions
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: c.upazilaOptions.isEmpty
                          ? null
                          : (v) => c.upazila.value = v,
                    )),

                const FieldLabel('Contact No'),
                TextField(
                  controller: c.signupPhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  decoration: agFieldDecoration('+8801646923894'),
                ),

                const SizedBox(height: 32),
                Obx(() => AgButton(
                      label: 'Request OTP',
                      loading: c.isSubmitting.value,
                      onPressed: c.requestOtpForSignup,
                    )),
                const SizedBox(height: 16),
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
