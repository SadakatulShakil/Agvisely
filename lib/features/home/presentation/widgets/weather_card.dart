import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../models/current_weather_model.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.weather,
    required this.isLoading,
    this.topRight,
    this.onRetry,
  });

  final CurrentWeatherModel? weather;
  final bool isLoading;
  final Widget? topRight;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final w = weather;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          if (w == null)
            SizedBox(
              height: 120.h,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 28.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'home.weather_unavailable'.tr,
                            style: TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13.sp,
                            ),
                          ),
                          if (onRetry != null) ...[
                            SizedBox(height: 6.h),
                            GestureDetector(
                              onTap: onRetry,
                              child: Text(
                                'common.retry'.tr,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${w.tempNow.round()}${w.tempUnit}',
                      style: TextStyle(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('H: ${w.tempHigh.round()}${w.tempUnit}', style: _labelStyle),
                          SizedBox(height: 6.h),
                          Text('L: ${w.tempLow.round()}${w.tempUnit}', style: _labelStyle),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(_conditionIcon(w.condition), color: AppColors.primary, size: 26.sp),
                        SizedBox(height: 4.h),
                        Text(
                          w.conditionShort.isNotEmpty ? w.conditionShort : w.condition,
                          textAlign: TextAlign.right,
                          style: _labelStyle,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Divider(height: 1, color: AppColors.dividerLight),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: 'home.feels_like'.tr,
                        value: '${w.feelsLike.round()}${w.tempUnit}',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'home.precipitation'.tr,
                        value: '${w.precipitationMm.round().toString().padLeft(2, '0')} ${w.rfUnit}',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'home.pressure'.tr,
                        value: '${w.pressureHpa.round()}hPa',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'home.wind'.tr,
                        value: '${w.windSpeedKmh.round()} ${w.windspdUnit}',
                        trailing: Transform.rotate(
                          angle: w.windDirDeg * 3.1415926535 / 180,
                          child: Icon(Icons.navigation, size: 14.sp, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (topRight != null) Positioned(top: 0, right: 0, child: topRight!),
        ],
      ),
    );
  }

  static TextStyle get _labelStyle =>
      TextStyle(fontSize: 11.sp, color: AppColors.textSecondaryLight);

  IconData _conditionIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('storm') || c.contains('thunder')) return Icons.flash_on;
    if (c.contains('rain') || c.contains('shower') || c.contains('drizzle')) return Icons.grain;
    if (c.contains('cloud')) return Icons.cloud;
    if (c.contains('clear') || c.contains('sunny')) return Icons.wb_sunny;
    if (c.contains('fog') || c.contains('mist') || c.contains('haze')) return Icons.blur_on;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondaryLight)),
        SizedBox(height: 4.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.navy),
            ),
            if (trailing != null) ...[SizedBox(width: 2.w), trailing!],
          ],
        ),
      ],
    );
  }
}
