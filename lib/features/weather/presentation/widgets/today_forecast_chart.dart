import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/bengali_numerals.dart';
import '../../../../models/seven_day_model.dart';

class TodayForecastChart extends StatelessWidget {
  const TodayForecastChart({
    super.key,
    required this.points,
    this.height = 260,
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
  static const _topReserved = 30.0;

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
    final axisStyle = TextStyle(fontSize: 10.sp, color: FigmaColors.neutralBody, fontWeight: FontWeight.w600);

    final rains = points.map((p) => p.rain).toList();
    final maxRain = rains.reduce((a, b) => a > b ? a : b);

    final barMaxY = maxRain <= 0 ? 5.0 : maxRain * 1.5;

    final barStub = barMaxY * 0.03;

    const gridLines = 8;
    const gridIntervals = gridLines - 1;

    final humidities = points.map((p) => p.humidity).toList();
    final humMinRaw = humidities.reduce((a, b) => a < b ? a : b);
    final humMaxRaw = humidities.reduce((a, b) => a > b ? a : b);
    final humMin = (humMinRaw - 5).clamp(0, 100).toDouble();
    final humMax = (humMaxRaw + 5).clamp(0, 100).toDouble();
    final humSpan = humMax - humMin;

    final temps = points.map((p) => p.temp).toList();
    final tempMinRaw = temps.reduce((a, b) => a < b ? a : b);
    final tempMaxRaw = temps.reduce((a, b) => a > b ? a : b);
    final tempAxisMin = tempMinRaw - 5;
    final tempAxisMax = tempMaxRaw + 5;
    final tempAxisInterval = (tempAxisMax - tempAxisMin) / gridIntervals;

    double humidityToTempScale(double humidity) =>
        tempAxisMin +
        ((humidity.clamp(humMin, humMax) - humMin) / humSpan) *
            (tempAxisMax - tempAxisMin);

    double tempScaleToHumidity(double tempScaleValue) =>
        humMin +
        ((tempScaleValue - tempAxisMin) / (tempAxisMax - tempAxisMin)) * humSpan;

    bool isDuplicateMaxTick(double value) =>
        value != tempAxisMax && (value - tempAxisMax).abs() < tempAxisInterval / 1000;

    int nearestRow(double value) =>
        ((value - tempAxisMin) / tempAxisInterval).round().clamp(0, gridIntervals);

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
                    LineChart(
                      LineChartData(
                        minX: -0.5,
                        maxX: n - 0.5,
                        minY: tempAxisMin,
                        maxY: tempAxisMax,
                        baselineY: tempAxisMin,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: tempAxisInterval,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: FigmaColors.neutralBackground,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineTouchData: const LineTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: _topReserved,
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
                        ),
                        lineBarsData: const [],
                      ),
                    ),
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
                                  color: FigmaColors.chartRainfall,
                                  width: barWidth,
                                  borderRadius: BorderRadius.circular(barWidth / 4),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: barMaxY,
                                    color: FigmaColors.neutralBackground.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    LineChart(
                      LineChartData(

                        minX: -0.5,
                        maxX: n - 0.5,
                        minY: tempAxisMin,
                        maxY: tempAxisMax,
                        baselineY: tempAxisMin,

                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(
                          enabled: false,//enable or disable tool tip
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => AppColors.navy,
                            tooltipPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                              final i = spot.spotIndex - 1;
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
                              interval: tempAxisInterval,
                              getTitlesWidget: (value, meta) {
                                if (isDuplicateMaxTick(value)) return const SizedBox.shrink();
                                final rowValue = tempAxisMin + nearestRow(value) * tempAxisInterval;
                                return Padding(
                                  padding: EdgeInsets.only(right: 4.w),
                                  child: Text(fmtNum(rowValue), style: axisStyle),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: _rightReserved,
                              interval: tempAxisInterval,
                              getTitlesWidget: (value, meta) {
                                if (isDuplicateMaxTick(value)) return const SizedBox.shrink();
                                final rowValue = tempAxisMin + nearestRow(value) * tempAxisInterval;
                                return Padding(
                                  padding: EdgeInsets.only(left: 4.w),
                                  child: Text(
                                    fmtNum(tempScaleToHumidity(rowValue), dp: 0),
                                    style: axisStyle,
                                  ),
                                );
                              },
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
                            color: FigmaColors.chartTemperature,
                            barWidth: 2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                radius: 3.r,
                                color: FigmaColors.chartTemperature,
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
                            color: FigmaColors.chartHumidity,
                            barWidth: 2,
                            dashArray: const [6, 4],
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                radius: 3.r,
                                color: FigmaColors.chartHumidity,
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
                        bottom: _bottomReserved.h +
                            ((points[i].rain <= 0 ? barStub : points[i].rain) / barMaxY) *
                                (constraints.maxHeight - _bottomReserved.h - _topReserved.h) +
                            6.h,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // White stroke so the temp/humidity line (drawn)
                              Text(
                                rainLabel(points[i].rain),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 2
                                    ..color = Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                rainLabel(points[i].rain),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: FigmaColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          _Legend(isBn: isBn, rfUnit: rainfallUnit, tempUnit: tempUnit),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.isBn,
    required this.rfUnit,
    required this.tempUnit,
  });

  final bool isBn;
  final String rfUnit;
  final String tempUnit;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 12.sp, color: FigmaColors.neutralSecondary, fontWeight: FontWeight.w500);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _swatch(color: FigmaColors.chartRainfall, dashed: false, isBar: true),
            SizedBox(width: 4.w),
            Text('${'home.rainfall'.tr} - $rfUnit', style: style),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _swatch(color: FigmaColors.chartTemperature, dashed: false, isBar: false),
            SizedBox(width: 4.w),
            Text('${'weather.temperature'.tr} - $tempUnit', style: style),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _swatch(color: FigmaColors.chartHumidity, dashed: true, isBar: false),
            SizedBox(width: 4.w),
            Text('${'home.humidity'.tr} - %', style: style),
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
