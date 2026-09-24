import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../domen/controllers/weather_controller.dart';
import '../widgets/daily_forecast_card.dart';

/// 7 Days Weather Forecast — one expandable card per day; tapping a card's
/// "View graph" row shows the rainfall/temperature/humidity chart.
class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WeatherController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'weather.title'.tr,
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: EdgeInsets.all(16.r),
                itemCount: controller.days.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final day = controller.days[index];
                  // Own Obx per card — reading expandedIndex.value inside
                  // ListView's itemBuilder happens outside the outer Obx's
                  // build call, so it wouldn't be tracked there.
                  return Obx(
                    () => DailyForecastCard(
                      day: day,
                      expanded: controller.expandedIndex.value == index,
                      onToggleGraph: () => controller.toggleExpanded(index),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
