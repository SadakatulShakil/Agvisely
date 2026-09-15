import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/auth/presentation/widgets/auth_widgets.dart';
import '../../domen/controllers/onboarding_controller.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());
    return Scaffold(
      body: SageBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Obx(() => c.isLast
                    ? const SizedBox(height: 48)
                    : TextButton(
                        onPressed: c.finish,
                        child: const Text('Skip',
                            style: TextStyle(color: AppColors.primaryDark)),
                      )),
              ),
              Expanded(
                child: PageView.builder(
                  controller: c.page,
                  onPageChanged: c.onPageChanged,
                  itemCount: c.slides.length,
                  itemBuilder: (_, i) {
                    final s = c.slides[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: const BoxDecoration(
                              color: AppColors.cardMint,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(s.icon, size: 76, color: AppColors.primaryDark),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            s.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navy),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            s.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18.sp,
                                height: 1.4,
                                color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      c.slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: c.index.value == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: c.index.value == i
                              ? AppColors.primary
                              : AppColors.heading,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Obx(() => AgButton(
                      label: c.isLast ? 'Get Started' : 'Next',
                      onPressed: c.next,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
