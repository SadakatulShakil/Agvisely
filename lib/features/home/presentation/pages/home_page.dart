import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/app_drawer.dart';
import '../../../../core/utils/user_avatar.dart';
import '../../../advisory_items/domen/binding/advisory_items_binding.dart';
import '../../../advisory_items/presentation/pages/advisory_items_page.dart';
import '../../../menu/presentation/pages/menu_page.dart';
import '../../../pest_advisory/presentation/pages/pest_advisory_page.dart';
import '../../../profile/domen/controllers/profile_controller.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../weather/domen/binding/seven_day_binding.dart';
import '../../../weather/presentation/pages/seven_day_page.dart';
import '../../../weather/presentation/widgets/today_forecast_chart.dart';
import '../../../../models/advisory_category_model.dart';
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
    final profileC = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    return RefreshIndicator(
      onRefresh: c.refreshAll,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          //Top bar: profile icon + greeting + location + notification icon
          Row(
            children: [
              Obx(
                () => UserAvatar(
                  profileUrl: profileC.user.value?.profileUrl,
                  size: 42.w,
                  iconSize: 34.sp,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: c.openSavedLocationsSheet,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          '${'home.greeting'.tr}, ${profileC.user.value?.name ?? ''}',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
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
              liveType: c.liveType.value,
              liveIcon: c.liveIcon.value,
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
          Obx(() {
            final categories = c.advisoryCategories;
            if (categories.isEmpty) return const SizedBox.shrink();

            final isBn = Get.locale?.languageCode == 'bn';
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, i) {
                final category = categories[i];
                return AdvisoryCard(
                  iconUrl: category.icon,
                  iconColor: AppColors.primary,
                  title: category.label(isBn),
                  subtitle: category.subtitle(isBn),
                  onTap: () => _openAdvisoryCategory(category, isBn),
                );
              },
            );
          }),
          SizedBox(height: 12.h),
          // Today's 3-hourly forecast preview; tap through to the full 7-day page.
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardLight,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
                  child: GestureDetector(
                    onTap: () => Get.to(() => const SevenDayPage(), binding: SevenDayBinding()),
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'home.weather_forecast'.tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primaryDark),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'home.view7days'.tr,
                                  style: TextStyle(fontSize: 12.sp, color: AppColors.primaryDark),
                                ),
                                SizedBox(width: 4.w),
                                Icon(Icons.double_arrow, size: 14.sp, color: AppColors.primaryDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 4.w, 16.h),
                  child: Obx(
                    () => TodayForecastChart(
                      points: c.todayChart.toList(),
                      rainfallUnit: c.todayChartRainUnit.value,
                      height: 280.h,
                      tempUnit: c.todayChartTempUnit.value,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
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


void _openAdvisoryCategory(AdvisoryCategoryModel category, bool isBn) {
  Get.to(
    () => const AdvisoryItemsPage(),
    binding: AdvisoryItemsBinding(
      categoryId: category.id,
      categoryLabel: category.label(isBn),
    ),
  );
}
