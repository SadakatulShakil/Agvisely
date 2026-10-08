import 'package:get/get.dart';

import '../core/utils/bengali_numerals.dart';

/// {val_min, val_avg, val_max} — the shape nearly every numeric field in
/// the forecast API comes in.
class NumericRange {
  final double valMin;
  final double valAvg;
  final double valMax;

  const NumericRange({
    required this.valMin,
    required this.valAvg,
    required this.valMax,
  });

  static const zero = NumericRange(valMin: 0, valAvg: 0, valMax: 0);

  factory NumericRange.fromJson(Map<String, dynamic>? j) {
    if (j == null) return zero;
    return NumericRange(
      valMin: numOf(j['val_min']),
      valAvg: numOf(j['val_avg']),
      valMax: numOf(j['val_max']),
    );
  }
}

/// Units carried per-day in the API response (they can vary by locale,
/// e.g. "°C" vs "°সে").
class ForecastUnits {
  final String temp;
  final String rf;
  final String windspd;
  final String soilmoist;
  final String sunshine;

  const ForecastUnits({
    required this.temp,
    required this.rf,
    required this.windspd,
    required this.soilmoist,
    required this.sunshine,
  });

  factory ForecastUnits.fromJson(Map<String, dynamic> j) => ForecastUnits(
        temp: j['temp_unit']?.toString() ?? '°C',
        rf: j['rf_unit']?.toString() ?? 'mm',
        windspd: j['windspd_unit']?.toString() ?? 'km/h',
        soilmoist: j['soilmoist_unit']?.toString() ?? '%',
        sunshine: j['sunshine_unit']?.toString() ?? 'hrs',
      );
}

/// One 3-hourly point for the per-day chart.
class ForecastChartPoint {
  final DateTime time;
  final double rain;
  final double temp;
  final double humidity;

  const ForecastChartPoint({
    required this.time,
    required this.rain,
    required this.temp,
    required this.humidity,
  });
}

/// One day of `result.daily[]`, plus the slice of `result.steps[]` that
/// falls on that calendar day (its chart).
class DayForecast {
  final String date;
  final String weekday;
  final DateTime dayStart;
  final String icon;
  final String? typenewIcon;
  final String condition;
  final double tempHigh;
  final double tempLow;
  final double feels;
  final NumericRange rf;
  final NumericRange rh;
  final NumericRange cldcvr;
  final NumericRange windspd;
  final double windDirDeg;
  final double soilMoisture;
  final double sunshineHours;
  final double thi;
  final ForecastUnits units;
  final List<ForecastChartPoint> chart;

  const DayForecast({
    required this.date,
    required this.weekday,
    required this.dayStart,
    required this.icon,
    this.typenewIcon,
    required this.condition,
    required this.tempHigh,
    required this.tempLow,
    required this.feels,
    required this.rf,
    required this.rh,
    required this.cldcvr,
    required this.windspd,
    required this.windDirDeg,
    required this.soilMoisture,
    required this.sunshineHours,
    required this.thi,
    required this.units,
    required this.chart,
  });

  factory DayForecast.fromJson(
    Map<String, dynamic> j, {
    required List<ForecastChartPoint> chart,
  }) {
    final typenew = j['typenew'] as Map<String, dynamic>?;
    final temp = j['temp'] as Map<String, dynamic>?;
    return DayForecast(
      date: j['date']?.toString() ?? '',
      weekday: j['weekday']?.toString() ?? '',
      dayStart: DateTime.parse(j['step_start'] as String),
      icon: j['icon']?.toString() ?? '',
      typenewIcon: typenew?['icon']?.toString(),
      condition: j['type']?.toString() ?? '',
      tempHigh: numOf(temp?['val_max']),
      tempLow: numOf(temp?['val_min']),
      feels: numOf(j['feels']),
      rf: NumericRange.fromJson(j['rf'] as Map<String, dynamic>?),
      rh: NumericRange.fromJson(j['rh'] as Map<String, dynamic>?),
      cldcvr: NumericRange.fromJson(j['cldcvr'] as Map<String, dynamic>?),
      windspd: NumericRange.fromJson(j['windspd'] as Map<String, dynamic>?),
      windDirDeg: numOf((j['winddir'] as Map<String, dynamic>?)?['val_avg']),
      soilMoisture:
          numOf((j['soil_moisture'] as Map<String, dynamic>?)?['val_avg']),
      sunshineHours: numOf(j['sunshine_hours']),
      thi: numOf(j['thi']),
      units: ForecastUnits.fromJson(j),
      chart: chart,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return dayStart.year == now.year &&
        dayStart.month == now.month &&
        dayStart.day == now.day;
  }

  /// typenew's icon is the more specific condition artwork (e.g. "partly
  /// cloudy WITH light rain" vs just "partly cloudy") — prefer it when
  /// present.
  String get displayIcon =>
      (typenewIcon != null && typenewIcon!.isNotEmpty) ? typenewIcon! : icon;

  // ── Display (locale-aware digit formatting) ─────────────────────────────

  bool get _bn => Get.locale?.languageCode == 'bn';

  String _num(num v, {int dp = 0}) {
    final ascii = v.toStringAsFixed(dp);
    return _bn ? toBanglaDigits(ascii) : ascii;
  }

  String get tempHighText => _num(tempHigh);
  String get tempLowText => _num(tempLow);
  String get feelsLikeText => '${_num(feels)}${units.temp}';
  String get rainfallText => '${_num(rf.valMin)}-${_num(rf.valMax)} ${units.rf}';
  String get cloudCoverText => '${_num(cldcvr.valAvg)}%';
  String get humidityText => '${_num(rh.valAvg)}%';
  String get soilMoistureText => '${_num(soilMoisture, dp: 1)}${units.soilmoist}';
  String get sunshineText => '${_num(sunshineHours)} ${units.sunshine}';
  String get windText => '${_num(windspd.valAvg, dp: 1)} ${units.windspd}';
  String get thiText => _num(thi, dp: 1);
}
