import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../location/models/location_gate_destination.dart';
import '../../../location/presentation/pages/location_gate_page.dart';
import '../../models/onboarding_slide.dart';

class OnboardingController extends GetxController {
  final page = PageController();
  final index = 0.obs;

  final slides = const <OnboardingSlide>[
    OnboardingSlide(
      icon: Icons.wb_sunny_outlined,
      title: 'onboarding.slide1_title',
      subtitle: 'onboarding.slide1_subtitle',
    ),
    OnboardingSlide(
      icon: Icons.eco_outlined,
      title: 'onboarding.slide2_title',
      subtitle: 'onboarding.slide2_subtitle',
    ),
    OnboardingSlide(
      icon: Icons.notifications_active_outlined,
      title: 'onboarding.slide3_title',
      subtitle: 'onboarding.slide3_subtitle',
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
    // Resolve location (GPS permission, falling back to manual search)
    // right after onboarding — before Login/Signup — so district/upazila
    // are already known by the time the user signs up.
    Get.off(() =>
        const LocationGatePage(destination: LocationGateDestination.login));
  }

  @override
  void onClose() {
    page.dispose();
    super.onClose();
  }
}
