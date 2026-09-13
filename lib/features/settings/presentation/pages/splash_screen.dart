import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/app_logo.dart';
import '../../../auth/auth/presentation/pages/login_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final prefs = UserPrefService();
    if (!prefs.hasOnboarded) {
      Get.off(() => const OnboardingPage());
    } else if (!prefs.isLoggedIn) {
      Get.off(() => const LoginPage());
    } else {
      Get.off(() => const HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2F4F1), Color(0xFFDDE6D6)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(height: 96),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Localized weather forecasts and expert farming advice — right in your hands.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16, color: AppColors.textSecondaryLight, height: 1.4),
                ),
              ),
              const SizedBox(height: 28),
             Text(
                'Technical Partner: RIMES',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
