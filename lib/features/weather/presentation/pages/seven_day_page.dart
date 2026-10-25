import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../domen/controllers/seven_day_controller.dart';
import '../widgets/seven_day_card.dart';

/// 7-Day Weather Forecast — one expandable card per day; tapping a card's
/// "View graph" row shows its rainfall/temperature/humidity chart.
class SevenDayPage extends StatelessWidget {
  const SevenDayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SevenDayController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: SvgPicture.asset('assets/icons/svg/arrow_back.svg', width: 24.w, height: 24.h),
                ),
                Text(
                  'weather.title'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        padding: EdgeInsets.all(16.r),
                        itemCount: controller.days.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final day = controller.days[index];
                          return Obx(
                            () => SevenDayCard(
                              day: day,
                              expanded: controller.isExpanded(day.dayStart),
                              onToggleGraph: () => controller.toggleExpanded(day.dayStart),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
