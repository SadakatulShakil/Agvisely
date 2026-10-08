import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../models/seven_day_model.dart';
import 'today_forecast_chart.dart';

/// One day of the 7-day list — header stats always visible, the
/// rainfall/temperature/humidity graph ([TodayForecastChart]) expands
/// below on tap.
class SevenDayCard extends StatelessWidget {
  const SevenDayCard({
    super.key,
    required this.day,
    required this.expanded,
    required this.onToggleGraph,
  });

  final DayForecast day;
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Stat(label: 'home.feels_like'.tr, value: day.feelsLikeText),
                      _Stat(label: 'weather.rainfall'.tr, value: day.rainfallText),
                      _Stat(label: 'weather.cloud_coverage'.tr, value: day.cloudCoverText),
                      _Stat(label: 'weather.humidity'.tr, value: day.humidityText),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Stat(label: 'weather.soil_moisture'.tr, value: day.soilMoistureText),
                      _Stat(label: 'weather.sunshine'.tr, value: day.sunshineText),
                      _Stat(
                        label: 'home.wind'.tr,
                        value: day.windText,
                        trailing: Transform.rotate(
                          angle: day.windDirDeg * 3.1415926535 / 180,
                          child: Icon(Icons.navigation, size: 12.sp, color: AppColors.primary),
                        ),
                      ),
                      _Stat(label: 'weather.thi'.tr, value: day.thiText),
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
                    child: expanded
                        ? Padding(
                            padding: EdgeInsets.only(top: 12.h),
                            child: TodayForecastChart(
                              points: day.chart,
                              rainfallUnit: day.units.rf,
                            ),
                          )
                        : const SizedBox(width: double.infinity),
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

  final DayForecast day;

  @override
  Widget build(BuildContext context) {
    final dayName = day.isToday ? 'weather.today'.tr : day.weekday;
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
                  dayName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  day.date,
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
                Text('H: ${day.tempHighText}°', style: _labelStyle),
                SizedBox(height: 4.h),
                Text('L: ${day.tempLowText}°', style: _labelStyle),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ConditionIcon(iconFile: day.displayIcon),
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
}

class _ConditionIcon extends StatelessWidget {
  const _ConditionIcon({required this.iconFile});

  final String iconFile;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.cloud, size: 28.sp, color: AppColors.primary);
    if (iconFile.isEmpty) return fallback;

    return Image.network(
      '${ApiEndpoints.baseUrlWeatherIcon}/$iconFile',
      width: 32.w,
      height: 32.w,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondaryLight),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
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
