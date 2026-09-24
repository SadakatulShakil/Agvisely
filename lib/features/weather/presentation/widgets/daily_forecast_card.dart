import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../domen/controllers/weather_controller.dart';

/// One day of the 7-day list — header stats always visible, the
/// rainfall/temperature/humidity graph expands below on tap.
///
/// The graph reuses the same demo chart image as the Home "Next 7 days"
/// card; only the top title/button strip is cropped off since this card
/// already renders its own date header and toggle.
class DailyForecastCard extends StatelessWidget {
  const DailyForecastCard({
    super.key,
    required this.day,
    required this.expanded,
    required this.onToggleGraph,
  });

  final DailyForecastDemo day;
  final bool expanded;
  final VoidCallback onToggleGraph;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        color: AppColors.cardMint,
        child: Column(
          children: [
            _Header(day: day),
            Container(
              width: double.infinity,
              color: AppColors.cardLight,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Stat(label: 'home.feels_like'.tr, value: day.feelsLike),
                      _Stat(label: 'weather.rainfall'.tr, value: day.rainfall),
                      _Stat(label: 'weather.cloud_coverage'.tr, value: day.cloudCoverage),
                      _Stat(label: 'weather.humidity'.tr, value: day.humidity),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      _Stat(label: 'weather.soil_moisture'.tr, value: day.soilMoisture),
                      _Stat(label: 'weather.sunshine'.tr, value: day.sunshine),
                      _Stat(
                        label: 'home.wind'.tr,
                        value: day.wind,
                        trailing: Transform.rotate(
                          angle: day.windDeg * 3.1415926535 / 180,
                          child: Icon(
                            Icons.navigation,
                            size: 12.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      _Stat(label: 'weather.thi'.tr, value: day.thi),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onTap: onToggleGraph,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.cardMint,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              expanded ? 'weather.hide_graph'.tr : 'weather.view_graph'.tr,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          Icon(
                            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColors.textSecondaryLight,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: expanded ? _Graph() : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.day});

  final DailyForecastDemo day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.dayLabel,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  day.dateLabel,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('H: ${day.highC}°c', style: _labelStyle),
                SizedBox(height: 4.h),
                Text('L: ${day.lowC}°c', style: _labelStyle),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(_conditionIcon(day.condition), color: AppColors.primary, size: 22.sp),
                SizedBox(height: 4.h),
                Text(
                  day.condition,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _labelStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static TextStyle get _labelStyle =>
      TextStyle(fontSize: 13.sp, color: AppColors.textPrimaryLight);

  IconData _conditionIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('storm') || c.contains('thunder')) return Icons.flash_on;
    if (c.contains('rain') || c.contains('shower') || c.contains('drizzle')) {
      return Icons.grain;
    }
    if (c.contains('cloud')) return Icons.cloud;
    if (c.contains('clear') || c.contains('sunny')) return Icons.wb_sunny;
    if (c.contains('fog') || c.contains('mist') || c.contains('haze')) {
      return Icons.blur_on;
    }
    return Icons.cloud;
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondaryLight),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              if (trailing != null) ...[SizedBox(width: 2.w), trailing!],
            ],
          ),
        ],
      ),
    );
  }
}

/// Rainfall/temperature/humidity chart — same demo asset used on Home,
/// cropped to drop its baked-in title/button strip (top ~20%).
class _Graph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: ClipRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 225 / 283,
          child: Image.asset(
            'assets/images/weather_forecast_chart_demo.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
