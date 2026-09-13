import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../auth/auth/presentation/pages/login_page.dart';
import '../../models/onboarding_slide.dart';

class OnboardingController extends GetxController {
  final page = PageController();
  final index = 0.obs;

  final slides = const <OnboardingSlide>[
    OnboardingSlide(
      icon: Icons.wb_sunny_outlined,
      title: 'Localized weather forecasts',
      subtitle:
          'Accurate, area-specific forecasts for your district and upazila — every day.',
    ),
    OnboardingSlide(
      icon: Icons.eco_outlined,
      title: 'Expert farming advice',
      subtitle:
          'Crop, pest, disease and livestock guidance tailored to your season and location.',
    ),
    OnboardingSlide(
      icon: Icons.notifications_active_outlined,
      title: 'Timely alerts, even offline',
      subtitle:
          'Get warnings before bad weather hits and browse advice without a connection.',
    ),
  ];

  bool get isLast => index.value == slides.length - 1;

  void onPageChanged(int i) => index.value = i;

  void next() {
    if (isLast) {
      finish();
    } else {
      page.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> finish() async {
    await UserPrefService().setOnboarded(true);
    Get.off(() => const LoginPage());
  }

  @override
  void onClose() {
    page.dispose();
    super.onClose();
  }
}
