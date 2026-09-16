import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
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
      height: w == null ? 120.h : null,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
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
                // ─ TOP ROW: Temp | (H&L + Icon) / Type ─
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // current temp
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: w.tempNowValue,
                            style: TextStyle(
                              fontSize: 56.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.heading,
                            ),
                          ),
                          TextSpan(
                            text: '°',
                            style: TextStyle(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.heading,
                            ),
                          ),
                          TextSpan(
                            text: w.tempNowUnit,
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.heading,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16..w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // high & low
                                Padding(
                                  padding: EdgeInsets.only(top: 16.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('H: ${w.tempHighText}', style: _labelStyle),
                                      SizedBox(height: 4.h),
                                      Text('L: ${w.tempLowText}', style: _labelStyle),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // icon
                                _conditionImage(w),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          // condition / type
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              w.condition.isNotEmpty
                                  ? w.condition.replaceAll('\n', ' ')
                                  : w.conditionShort.replaceAll('\n', ' '),
                              style: _labelStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 1, color: AppColors.dividerLight),
                SizedBox(height: 12.h),

                // ─ BOTTOM ROW: Feels / Rain / Pressure / Wind ─
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _Stat(label: 'home.feels_like'.tr, value: w.feelsLikeText),
                            SizedBox(width: 32.w),
                            _Stat(label: 'home.precipitation'.tr, value: w.precipText),
                            SizedBox(width: 32.w),
                            _Stat(label: 'home.pressure'.tr, value: w.pressureText),
                            SizedBox(width: 32.w),
                            _Stat(
                              label: 'home.wind'.tr,
                              value: w.windText,
                              trailing: Transform.rotate(
                                angle: w.windDirDeg * 3.1415926535 / 180,
                                child: Icon(
                                  Icons.navigation,
                                  size: 14.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
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
      TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight);

  /// BMD's own condition icon when available, falling back to the local
  /// Material-icon mapping if the API sent no icon or the image fails to load.
  Widget _conditionImage(CurrentWeatherModel w) {
    final fallback = Icon(_conditionIcon(w.condition), color: AppColors.primary, size: 26.sp);
    if (w.icon.isEmpty) return fallback;

    return Image.network(
      '${ApiEndpoints.baseUrlWeatherIcon}/${w.icon}',
      width: 48.sp,
      height: 48.sp,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            if (trailing != null) ...[SizedBox(width: 2.w), trailing!],
          ],
        ),
      ],
    );
  }
}