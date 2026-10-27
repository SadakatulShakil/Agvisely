import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/weather_icon_assets.dart';
import '../../../../models/seven_day_model.dart';
import 'today_forecast_chart.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: FigmaColors.neutralBorder,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: FigmaColors.neutralBlack.withValues(alpha: 0.08),
            offset: Offset(0, 2.h),
            blurRadius: 8.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _Header(day: day),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FigmaColors.neutralWhite,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
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
                        child: SvgPicture.asset(
                          'assets/icons/svg/navigation.svg',
                          width: 12.w,
                          height: 12.h,
                        )
                      ),
                    ),
                    _Stat(label: 'weather.thi'.tr, value: day.thiText),
                  ],
                ),
                SizedBox(height: 14.h),
                Padding(
                  padding: EdgeInsets.only(left: 10.w, right: 10.w),
                  child: GestureDetector(
                    onTap: onToggleGraph,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: FigmaColors.neutralBackground,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              expanded ? 'weather.hide_graph'.tr : 'weather.view_graph'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: FigmaColors.neutralBody,
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            expanded
                                ? 'assets/icons/svg/arrow_up.svg'
                                : 'assets/icons/svg/arrow_down.svg',
                            width: 20.w,
                            height: 20.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: expanded
                      ? Padding(
                          padding: EdgeInsets.only(top: 10.h, left: 8.w),
                          child: TodayForecastChart(
                            points: day.chart,
                            rainfallUnit: day.units.rf,
                            tempUnit: day.units.temp,
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ],
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
                    color: FigmaColors.primaryDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  day.date,
                  style: TextStyle(fontSize: 12.sp, color: FigmaColors.neutralBody, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${'home.high'.tr} ${day.tempHighText}', style: _labelStyle),
                SizedBox(height: 4.h),
                Text('${'home.low'.tr} ${day.tempLowText}', style: _labelStyle),
              ],
            ),
          ),
          Expanded(
            flex: 4,
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
      TextStyle(fontSize: 13.sp, color: FigmaColors.neutralBody, fontWeight: FontWeight.w500);
}

class _ConditionIcon extends StatelessWidget {
  const _ConditionIcon({required this.iconFile});

  final String iconFile;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.cloud, size: 28.sp, color: AppColors.primary);
    if (iconFile.isEmpty) return fallback;

    final assetPath = WeatherIconAssets.assetPath(iconFile);
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: 35.w,
        height: 35.w,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }
    return Image.network(
      '${ApiEndpoints.baseUrlWeatherIcon}/$key',
      width: 35.w,
      height: 35.w,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: 35.w,
          height: 56.w,
          child: Center(
            child: SizedBox(
              width: 35.w,
              height: 35.w,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        );
      },
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.sp, color: FigmaColors.primaryDark),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: FigmaColors.neutralBody,
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
