import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/app_drawer.dart';
import '../../../pest_advisory/presentation/pages/pest_advisory_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domen/controllers/home_controller.dart';
import '../widgets/weather_card.dart';

/// Root shell after splash. Bottom nav mirrors the Figma home frame:
/// Home · Pest Advisory · Profile · Menu (Menu opens the drawer).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(HomeController(), permanent: true);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    final tabs = <Widget>[
      const _HomeDashboard(),
      const PestAdvisoryPage(),
      const ProfilePage(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android icons
        statusBarBrightness: Brightness.light,    // iOS text
      ),
      child: Obx(
        () => Scaffold(
          key: scaffoldKey,
          drawer: const AppDrawer(),
          body: SafeArea(child: tabs[c.navIndex.value.clamp(0, tabs.length - 1)]),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: c.navIndex.value == 3 ? 0 : c.navIndex.value,
            onTap: (i) {
              if (i == 3) {
                scaffoldKey.currentState?.openDrawer();
              } else {
                c.changeTab(i);
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'nav.home'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bug_report_outlined),
                label: 'nav.pest'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                label: 'nav.profile'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu),
                label: 'nav.menu'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashboard body — top bar + weather card + advisory grid + chart + my choice.
/// Placeholder blocks; build each out from the Figma "home" frame.
class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 22, child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: c.openSavedLocationsSheet,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${'home.greeting'.tr}, Sadakatul'),
                    Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              c.locationName.value,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16.sp,
                            color: AppColors.primaryDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.notifications_none, color: AppColors.navy),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => WeatherCard(
            weather: c.currentWeather.value,
            isLoading: c.isLoadingWeather.value,
            onRetry: c.loadWeather,
            topRight: (c.isResolvingLocation.value || c.isLoadingWeather.value)
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _placeholderCard('advisory.crop'.tr, 120)),
            const SizedBox(width: 12),
            Expanded(child: _placeholderCard('advisory.livestock'.tr, 120)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _placeholderCard('advisory.aquaculture'.tr, 120)),
            const SizedBox(width: 12),
            Expanded(child: _placeholderCard('advisory.disease'.tr, 120)),
          ],
        ),
        const SizedBox(height: 16),
        _placeholderCard('${'home.next_7_days'.tr} (chart)', 220),
        const SizedBox(height: 16),
        _placeholderCard('${'home.my_choice'.tr} (carousel)', 150),
      ],
    );
  }

  Widget _placeholderCard(String label, double height, {Widget? topRight}) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Center(child: Text(label, style: const TextStyle(color: AppColors.navy))),
            if (topRight != null)
              Positioned(top: 8.h, right: 8.w, child: topRight),
          ],
        ),
      );
}
