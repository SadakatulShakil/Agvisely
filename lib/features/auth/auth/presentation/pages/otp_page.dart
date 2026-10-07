import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/utils/app_logo.dart';
import '../../domen/controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/otp_boxes.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  final String purpose; // 'signup' | 'login'

  const OtpPage({
    super.key,
    required this.phone,
    required this.purpose,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final c = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController(), permanent: true);

  String _code = '';

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      extendBodyBehindAppBar: true,

      body: SageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: keyboardHeight + 24,
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),

                const AppLogo(height: 72),

                SizedBox(height: 35.h),

                Text(
                  'otp.title'.tr,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryDark,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  '${'otp.sent_to'.tr}\n${widget.phone}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppColors.heading,
                  ),
                ),

                SizedBox(height: 24.h),

                OtpBoxes(
                  length: AuthController.otpLength,
                  onChanged: (v) {
                    setState(() => _code = v);
                  },
                  onCompleted: (v) {
                    c.verifyOtp(
                      v,
                      phone: widget.phone,
                      purpose: widget.purpose,
                    );
                  },
                ),

                SizedBox(height: 30.h),

                Obx(
                      () => AgButton(
                    label: 'otp.verify'.tr,
                    loading: c.isSubmitting.value,
                    onPressed: () {
                      c.verifyOtp(
                        _code,
                        phone: widget.phone,
                        purpose: widget.purpose,
                      );
                    },
                  ),
                ),

                Obx(
                  () => TextButton(
                    onPressed: c.isSubmitting.value
                        ? null
                        : () => c.resendOtp(
                              phone: widget.phone,
                              purpose: widget.purpose,
                            ),
                    child: Text(
                      'otp.resend'.tr,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
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