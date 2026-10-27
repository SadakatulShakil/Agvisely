import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/weather_icon_assets.dart';
import '../../../../models/current_weather_model.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.weather,
    required this.isLoading,
    this.liveType = '',
    this.liveIcon = '',
    this.topRight,
    this.onRetry,
  });

  final CurrentWeatherModel? weather;
  final bool isLoading;
  final String liveType;
  final String liveIcon;
  final Widget? topRight;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final w = weather;
    return Container(
      width: double.infinity,
      height: w == null ? 160.h : 180.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: FigmaColors.neutralWhite,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          if (w == null)
            SizedBox(
              height: 160.h,
              child: Center(
                child: isLoading
                    ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: FigmaColors.primaryDefault,
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
                              fontWeight: FontWeight.w600,
                              color: FigmaColors.primaryDark,
                            ),
                          ),
                          TextSpan(
                            text: '°',
                            style: TextStyle(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.w600,
                              color: FigmaColors.primaryDark,
                            ),
                          ),
                          TextSpan(
                            text: w.tempNowUnit,
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w600,
                              color: FigmaColors.primaryDark,
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
                            padding: EdgeInsets.only(left: 8.w),
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
                                      Text('${'home.high'.tr} ${w.tempHighText}', style: _labelStyle),
                                      SizedBox(height: 2.h),
                                      Text('${'home.low'.tr} ${w.tempLowText}', style: _labelStyle),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // icon — live overrides forecast, forecast overrides placeholder
                                _conditionImage(w),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                          // condition / type — live overrides forecast
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              liveType.isNotEmpty
                                  ? liveType
                                  : (w.condition.isNotEmpty
                                      ? w.condition.replaceAll('\n', ' ')
                                      : w.conditionShort.replaceAll('\n', ' ')),
                              style: _labelStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 1, color: FigmaColors.neutralBackground),
                SizedBox(height: 12.h),

                // ─ BOTTOM ROW: Feels / Rain / Pressure / Wind ─
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            _Stat(label: 'weather.sunshine'.tr, value: w.sunshineText),
                            SizedBox(width: 32.w),
                            _Stat(
                              label: 'home.wind'.tr,
                              value: w.windText,
                              trailing: Transform.rotate(
                                angle: w.windDirDeg * 3.1415926535 / 180,
                                child: SvgPicture.asset(
                                  'assets/icons/svg/navigation.svg',
                                  width: 12.w,
                                  height: 12.h,
                                )
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
      TextStyle(fontSize: 14.sp, color: FigmaColors.neutralBody, fontWeight: FontWeight.w500);

  /// Live icon overrides the forecast's; BMD's own condition icon when

  Widget _conditionImage(CurrentWeatherModel w) {
    final resolvedCondition = liveType.isNotEmpty ? liveType : w.condition;
    final fallback = Icon(_conditionIcon(resolvedCondition), color: AppColors.primary, size: 48.sp);

    final key = liveIcon.isNotEmpty ? liveIcon : w.icon;
    if (key.isEmpty) return fallback;

    final assetPath = WeatherIconAssets.assetPath(key);
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: 48.w,
        height: 48.w,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return Image.network(
      '${ApiEndpoints.baseUrlWeatherIcon}/$key',
      width: 56.w,
      height: 56.w,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: 56.w,
          height: 56.w,
          child: Center(
            child: SizedBox(
              width: 18.w,
              height: 18.w,
              child: CircularProgressIndicator(strokeWidth: 2, color: FigmaColors.primaryDark),
            ),
          ),
        );
      },
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
            color: FigmaColors.primaryDark,
          ),
        ),
        SizedBox(height: 3.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: FigmaColors.neutralBody,
              ),
            ),
            if (trailing != null) ...[SizedBox(width: 2.w), trailing!],
          ],
        ),
      ],
    );
  }
}