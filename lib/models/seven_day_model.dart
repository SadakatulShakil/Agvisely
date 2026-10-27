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
  final String windgust;
  final String cldcvr;
  final String soilmoist;
  final String sunshine;

  const ForecastUnits({
    required this.temp,
    required this.rf,
    required this.windspd,
    required this.windgust,
    required this.cldcvr,
    required this.soilmoist,
    required this.sunshine,
  });

  /// The live API always returns bn-flavored unit strings regardless of
  /// locale (confirmed against `/api/v1/weather/current`) — so for English,
  /// these are fixed rather than read off the response. A no-op for the bn
  /// response (and for forecast_demo_en.json, which already stores these
  /// exact strings).
  factory ForecastUnits.fromJson(Map<String, dynamic> j, {bool isBn = true}) {
    if (!isBn) {
      return const ForecastUnits(
        temp: '°C',
        rf: 'mm',
        windspd: 'km/h',
        windgust: 'km/h',
        cldcvr: '',
        soilmoist: '%',
        sunshine: 'hrs',
      );
    }
    // This branch only runs when isBn is true — the fallback (used when the
    // API omits a unit field) must be the Bangla string, not the English
    // default from the `!isBn` branch above.
    return ForecastUnits(
      temp: j['temp_unit']?.toString() ?? '°সে',
      rf: j['rf_unit']?.toString() ?? 'মি:মি:',
      windspd: j['windspd_unit']?.toString() ?? 'কিমি/ঘণ্টা',
      windgust: j['windgust_unit']?.toString() ?? 'কিমি/ঘণ্টা',
      cldcvr: j['cldcvr_unit']?.toString() ?? 'অক্টা',
      soilmoist: j['soilmoist_unit']?.toString() ?? '%',
      sunshine: j['sunshine_unit']?.toString() ?? 'ঘণ্টা',
    );
  }
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

  /// For [UserPrefService.cachedTodayChart] — the home dashboard's chart
  /// preview only, so a cold start shows the last-known location's chart
  /// immediately instead of a blank/demo one while the live fetch is in
  /// flight.
  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'rain': rain,
        'temp': temp,
        'humidity': humidity,
      };

  factory ForecastChartPoint.fromJson(Map<String, dynamic> j) => ForecastChartPoint(
        time: DateTime.parse(j['time'] as String),
        rain: (j['rain'] as num).toDouble(),
        temp: (j['temp'] as num).toDouble(),
        humidity: (j['humidity'] as num).toDouble(),
      );
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
  final NumericRange windgust;
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
    required this.windgust,
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
    bool? isBn,
  }) {
    final bn = isBn ?? (Get.locale?.languageCode == 'bn');
    final typenew = j['typenew'] as Map<String, dynamic>?;
    final temp = j['temp'] as Map<String, dynamic>?;
    // The live API always sends bn condition text in `type` (and the en one
    // in `typen`) regardless of locale — pick whichever matches, falling
    // back to the other if one's missing. A no-op for forecast_demo_*.json,
    // where `type` already matches the file's own language.
    final bnCondition = j['type']?.toString();
    final enCondition = j['typen']?.toString();
    final condition = bn
        ? (bnCondition?.isNotEmpty == true ? bnCondition : enCondition)
        : (enCondition?.isNotEmpty == true ? enCondition : bnCondition);
    return DayForecast(
      date: j['date']?.toString() ?? '',
      weekday: j['weekday']?.toString() ?? '',
      dayStart: DateTime.parse(j['step_start'] as String),
      icon: j['icon']?.toString() ?? '',
      typenewIcon: typenew?['icon']?.toString(),
      condition: condition ?? '',
      tempHigh: numOf(temp?['val_max']),
      tempLow: numOf(temp?['val_min']),
      feels: numOf(j['feels']),
      rf: NumericRange.fromJson(j['rf'] as Map<String, dynamic>?),
      rh: NumericRange.fromJson(j['rh'] as Map<String, dynamic>?),
      cldcvr: NumericRange.fromJson(j['cldcvr'] as Map<String, dynamic>?),
      windspd: NumericRange.fromJson(j['windspd'] as Map<String, dynamic>?),
      windgust: NumericRange.fromJson(j['windgust'] as Map<String, dynamic>?),
      windDirDeg: numOf((j['winddir'] as Map<String, dynamic>?)?['val_avg']),
      soilMoisture:
          numOf((j['soil_moisture'] as Map<String, dynamic>?)?['val_avg']),
      sunshineHours: numOf(j['sunshine_hours']),
      thi: numOf(j['thi']),
      units: ForecastUnits.fromJson(j, isBn: bn),
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
  String get displayIcon => icon;

  // ── Display (locale-aware digit formatting) ─────────────────────────────

  bool get _bn => Get.locale?.languageCode == 'bn';

  String _num(num v, {int dp = 0}) {
    final ascii = v.toStringAsFixed(dp);
    return _bn ? toBanglaDigits(ascii) : ascii;
  }

  String get tempHighText => '${_num(tempHigh)}${units.temp}';
  String get tempLowText => '${_num(tempLow)}${units.temp}';
  String get feelsLikeText => '${_num(feels)}${units.temp}';
  String get rainfallText => '${_num(rf.valMin)}-${_num(rf.valMax)} ${units.rf}';
  String get cloudCoverText => '${_num(cldcvr.valAvg)} ${units.cldcvr}'.trim();
  String get humidityText => '${_num(rh.valAvg)}%';
  String get windGustText => '${_num(windgust.valAvg, dp: 1)} ${units.windgust}';
  String get soilMoistureText => '${_num(soilMoisture, dp: 1)}${units.soilmoist}';
  String get sunshineText => '${_num(sunshineHours)} ${units.sunshine}';
  String get windText => '${_num(windspd.valAvg, dp: 1)} ${units.windspd}';
  String get thiText => _num(thi, dp: 1);
}
