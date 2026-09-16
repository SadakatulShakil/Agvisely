import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/app_drawer.dart';
import '../../../aquaculture_advisory/domen/binding/aquaculture_advisory_binding.dart';
import '../../../aquaculture_advisory/presentation/pages/aquaculture_advisory_page.dart';
import '../../../crop_advisory/domen/binding/crop_advisory_binding.dart';
import '../../../crop_advisory/presentation/pages/crop_advisory_page.dart';
import '../../../disease_advisory/domen/binding/disease_advisory_binding.dart';
import '../../../disease_advisory/presentation/pages/disease_advisory_page.dart';
import '../../../livestock_advisory/domen/binding/livestock_advisory_binding.dart';
import '../../../livestock_advisory/presentation/pages/livestock_advisory_page.dart';
import '../../../menu/presentation/pages/menu_page.dart';
import '../../../pest_advisory/presentation/pages/pest_advisory_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domen/controllers/home_controller.dart';
import '../widgets/advisory_card.dart';
import '../widgets/my_choice_carousel.dart';
import '../widgets/weather_card.dart';

/// Root shell after splash. Bottom nav mirrors the Figma home frame:
/// Home · Pest Advisory · Profile · Menu.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(HomeController(), permanent: true);

    final tabs = <Widget>[
      const _HomeDashboard(),
      const PestAdvisoryPage(),
      const ProfilePage(),
      const MenuPage(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android icons
        statusBarBrightness: Brightness.light, // iOS text
      ),
      child: Obx(
        () => Scaffold(
          drawer: const AppDrawer(),
          body: SafeArea(
            child: tabs[c.navIndex.value.clamp(0, tabs.length - 1)],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: c.navIndex.value,
            onTap: c.changeTab,
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
    return RefreshIndicator(
      onRefresh: c.refreshAll,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          //Top bar: profile icon + greeting + location + notification icon
          Row(
            children: [
              Container(
                height: 38.h,
                width: 38.w,
                decoration: BoxDecoration(
                  color: AppColors.cardLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                  child: Icon(Icons.person, size: 34.sp, color: AppColors.primaryDark),),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: c.openSavedLocationsSheet,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'home.greeting'.tr}, Sadakatul', style: TextStyle(fontSize: 14.sp),),
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
                                  fontSize: 16.sp,
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
              SvgPicture.asset(
                'assets/icons/notification.svg',
                width: 38.w,
                height: 38.h,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Weather card: current conditions + temp + feels like + type + icon
          Obx(
            () => WeatherCard(
              weather: c.currentWeather.value,
              isLoading: c.isLoadingWeather.value,
              onRetry: c.loadWeather,
              topRight:
                  (c.isResolvingLocation.value || c.isLoadingWeather.value)
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
          SizedBox(height: 12.h),
          // Advisory grid: 2x2 of crop, livestock, aquaculture, disease
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AdvisoryCard(
                    svg: 'assets/icons/advisory/crop.svg',
                    iconColor: AppColors.primary,
                    title: 'advisory.crop'.tr,
                    subtitle: 'advisory.crop_subtitle'.tr,
                    onTap: () => Get.to(
                      () => const CropAdvisoryPage(),
                      binding: CropAdvisoryBinding(),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: AdvisoryCard(
                    svg: 'assets/icons/advisory/livestock.svg',
                    iconColor: AppColors.primary,
                    title: 'advisory.livestock'.tr,
                    subtitle: 'advisory.livestock_subtitle'.tr,
                    onTap: () => Get.to(
                      () => const LivestockAdvisoryPage(),
                      binding: LivestockAdvisoryBinding(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AdvisoryCard(
                    svg: 'assets/icons/advisory/aquaculture.svg',
                    iconColor: AppColors.primary,
                    title: 'advisory.aquaculture'.tr,
                    subtitle: 'advisory.aquaculture_subtitle'.tr,
                    onTap: () => Get.to(
                      () => const AquacultureAdvisoryPage(),
                      binding: AquacultureAdvisoryBinding(),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: AdvisoryCard(
                    svg: 'assets/icons/advisory/disease.svg',
                    iconColor: AppColors.primary,
                    title: 'advisory.disease'.tr,
                    subtitle: 'advisory.disease_subtitle'.tr,
                    onTap: () => Get.to(
                      () => const DiseaseAdvisoryPage(),
                      binding: DiseaseAdvisoryBinding(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Next 7 days chart — demo image for now; swap for a real chart
          // once the forecast series is wired up.
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.asset(
              'assets/images/weather_forecast_chart_demo.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
          SizedBox(height: 12.h),
          // My Choice carousel — demo items for now; swap for the real
          // "My Choice" payload once that endpoint exists.
          MyChoiceCarousel(
            items: [
              MyChoiceItem(icon: 'assets/icons/my_choice/boro_rice.png', label: 'my_choice.boro_rice'.tr),
              MyChoiceItem(icon: 'assets/icons/my_choice/chicken.png', label: 'my_choice.chicken'.tr),
              MyChoiceItem(icon: 'assets/icons/my_choice/wheat.png', label: 'my_choice.wheat'.tr),
            ],
          ),
        ],
      ),
    );
  }
}
