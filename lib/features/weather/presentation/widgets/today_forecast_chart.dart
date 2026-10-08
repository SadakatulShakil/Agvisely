import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/bengali_numerals.dart';
import '../../../../models/seven_day_model.dart';

/// Rainfall bars (green, value labeled on top) + temperature line (navy,
/// solid) + humidity line (orange, dashed) over 3-hourly [points]. Both
/// lines carry tappable dots showing their real value. Reused for every day
/// card on the 7-day forecast page and the Home dashboard preview — fed a
/// different day's points each time, never duplicated per-card.
class TodayForecastChart extends StatelessWidget {
  const TodayForecastChart({
    super.key,
    required this.points,
    this.height = 250,
    this.rainfallUnit = 'mm',
    this.tempUnit = '°C',
  });

  final List<ForecastChartPoint> points;
  final double height;

  /// Appended to each bar's value label, e.g. "5 mm".
  final String rainfallUnit;
  final String tempUnit;

  static const _leftReserved = 30.0;
  static const _rightReserved = 34.0;
  static const _bottomReserved = 22.0;
  // Blank strip at the very top of both charts' plot areas, reserved so the
  // gray track (which otherwise fills the full 0..barMaxY height) never
  // reaches the top edge — leaving genuine empty space for the rainfall
  // value label to sit in, outside/above the pill rather than overlapping it.
  static const _topReserved = 30.0;

  // Fixed 0-50°C left axis — matches the design and comfortably spans the
  // realistic range for this app's climate, so ticks land on round numbers.
  static const _tempAxisMin = 0.0;
  static const _tempAxisMax = 50.0;
  static const _tempAxisInterval = 10.0;

  static Widget _blank(double value, TitleMeta meta) => const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(height: height.h);
    }

    final isBn = Get.locale?.languageCode == 'bn';
    String fmtNum(num v, {int dp = 0}) {
      final ascii = v.toStringAsFixed(dp);
      return isBn ? toBanglaDigits(ascii) : ascii;
    }

    String rainLabel(double rain) {
      final dp = rain == rain.roundToDouble() ? 0 : 1;
      return fmtNum(rain, dp: dp);
    }

    String timeLabel(DateTime t) {
      final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
      final period = t.hour < 12 ? 'AM' : 'PM';
      return '${fmtNum(h12)}$period';
    }

    final n = points.length;
    final axisStyle = TextStyle(fontSize: 10.sp, color: AppColors.textSecondaryLight);

    final rains = points.map((p) => p.rain).toList();
    final maxRain = rains.reduce((a, b) => a > b ? a : b);

    final barMaxY = maxRain <= 0 ? 5.0 : maxRain * 1.5;

    final barStub = barMaxY * 0.03;

    final humidities = points.map((p) => p.humidity).toList();
    final humMinRaw = humidities.reduce((a, b) => a < b ? a : b);
    final humMaxRaw = humidities.reduce((a, b) => a > b ? a : b);
    final humMin = (humMinRaw - 3).clamp(0, 100).toDouble();
    final humMax = (humMaxRaw + 3).clamp(0, 100).toDouble();
    final humSpan = (humMax - humMin) <= 0 ? 1.0 : (humMax - humMin);

    double humidityToTempScale(double humidity) =>
        _tempAxisMin +
        ((humidity.clamp(humMin, humMax) - humMin) / humSpan) *
            (_tempAxisMax - _tempAxisMin);

    double tempScaleToHumidity(double tempScaleValue) =>
        humMin +
        ((tempScaleValue - _tempAxisMin) / (_tempAxisMax - _tempAxisMin)) * humSpan;

    return SizedBox(
      height: height.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final plotWidth =
                    (constraints.maxWidth - _leftReserved - _rightReserved)
                        .clamp(0.0, double.infinity);
                final slot = n == 0 ? 0.0 : plotWidth / n;
                final barWidth = (slot * 0.85).clamp(10.0, 56.0);

                return Stack(
                  children: [
                    BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: barMaxY,
                        alignment: BarChartAlignment.spaceEvenly,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: _topReserved,
                              getTitlesWidget: _blank,
                            ),
                          ),
                          // showTitles must be true for reservedSize to
                          // actually be allocated during layout — these two
                          // sides mirror the LineChart's visible left/right
                          // reservedSize exactly (via _blank) purely so both
                          // charts' plot areas end up the same pixel size
                          // and stay aligned.
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: _rightReserved,
                              getTitlesWidget: _blank,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: _bottomReserved,
                              getTitlesWidget: _blank,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: _leftReserved,
                              getTitlesWidget: _blank,
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < n; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: points[i].rain <= 0 ? barStub : points[i].rain,
                                  color: AppColors.barChart,
                                  width: barWidth,
                                  // Fully-rounded "pill" ends — fl_chart
                                  // reuses this same borderRadius for the
                                  // gray track behind it, so both draw as
                                  // one continuous capsule.
                                  borderRadius: BorderRadius.circular(barWidth / 4),
                                  // Full-height gray "track" behind every
                                  // bar, matching the reference design.
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: barMaxY,
                                    color: AppColors.dividerLight.withAlpha(85),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    LineChart(
                      LineChartData(
                        // Half-step padding on each side mirrors
                        // BarChartAlignment.spaceEvenly's own group spacing,
                        // so point i's x fraction lands on the same
                        // horizontal position as bar group i's center.
                        minX: -0.5,
                        maxX: n - 0.5,
                        minY: _tempAxisMin,
                        maxY: _tempAxisMax,
                        // Only the LineChart draws a grid — its temp-axis
                        // ticks are the "real" shared scale; the BarChart's
                        // own (rainfall-scaled) ticks would land at
                        // different pixel rows and look like a second,
                        // misaligned grid if both drew one.
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _tempAxisInterval,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: AppColors.dividerLight,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => AppColors.navy,
                            tooltipPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                              final i = spot.spotIndex;
                              if (i < 0 || i >= n) return null;
                              final isHumidityLine = spot.barIndex == 1;
                              final text = isHumidityLine
                                  ? '${fmtNum(points[i].humidity, dp: 0)}%'
                                  : '${fmtNum(points[i].temp, dp: 1)}°';
                              return LineTooltipItem(
                                text,
                                TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          // Mirrors the BarChart's visible top reservedSize
                          // so both plot areas stay the same height/aligned.
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: _topReserved,
                              getTitlesWidget: _blank,
                            ),
                          ),
                          // Mirrors the BarChart's visible left reservedSize
                          // — see the comment on BarChart's titlesData above.
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: _leftReserved,
                              interval: _tempAxisInterval,
                              getTitlesWidget: (value, meta) => Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: Text('${fmtNum(value)} $tempUnit', style: axisStyle),
                              ),
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: _rightReserved,
                              // Same tick positions as the left axis (shared
                              // y-domain) — but labeled in humidity's own %
                              // scale via the inverse mapping.
                              interval: _tempAxisInterval,
                              getTitlesWidget: (value, meta) => Padding(
                                padding: EdgeInsets.only(left: 4.w),
                                child: Text(
                                  fmtNum(tempScaleToHumidity(value), dp: 0),
                                  style: axisStyle,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: _bottomReserved,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final i = value.round();
                                if (i < 0 || i >= n) return const SizedBox.shrink();
                                return Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Text(timeLabel(points[i].time), style: axisStyle),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          // barIndex 0 — temperature (real values, real axis).
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < n; i++) FlSpot(i.toDouble(), points[i].temp),
                            ],
                            isCurved: true,
                            color: AppColors.navy,
                            barWidth: 2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                radius: 3.r,
                                color: AppColors.navy,
                                strokeWidth: 1.5,
                                strokeColor: Colors.white,
                              ),
                            ),
                          ),
                          // barIndex 1 — humidity (mapped position, real % in tooltip/axis).
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < n; i++)
                                FlSpot(i.toDouble(), humidityToTempScale(points[i].humidity)),
                            ],
                            isCurved: true,
                            color: AppColors.warning,
                            barWidth: 2,
                            dashArray: const [6, 4],
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                radius: 3.r,
                                color: AppColors.warning,
                                strokeWidth: 1.5,
                                strokeColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (var i = 0; i < n; i++)
                      Positioned(
                        left: _leftReserved + slot * i,
                        width: slot,
                        top: 0,
                        height: _topReserved.h,
                        child: Center(
                          child: Text(
                            '${rainLabel(points[i].rain)} \n$rainfallUnit',
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          _Legend(isBn: isBn),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.isBn});

  final bool isBn;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 11.sp, color: AppColors.textSecondaryLight);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _swatch(color: AppColors.barChart, dashed: false, isBar: true),
            SizedBox(width: 4.w),
            Text('weather.rainfall'.tr, style: style),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _swatch(color: AppColors.navy, dashed: false, isBar: false),
            SizedBox(width: 4.w),
            Text('weather.temperature'.tr, style: style),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _swatch(color: AppColors.warning, dashed: true, isBar: false),
            SizedBox(width: 4.w),
            Text('weather.humidity'.tr, style: style),
          ],
        ),
      ],
    );
  }

  Widget _swatch({required Color color, required bool dashed, required bool isBar}) {
    if (isBar) {
      return Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5.r),
        ),
      );
    }
    return CustomPaint(
      size: Size(16.w, 2.h),
      painter: _LineSwatchPainter(color: color, dashed: dashed),
    );
  }
}

class _LineSwatchPainter extends CustomPainter {
  _LineSwatchPainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
      return;
    }
    const dashWidth = 3.0;
    const dashGap = 2.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + dashWidth).clamp(0, size.width), size.height / 2),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _LineSwatchPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashed != dashed;
}
