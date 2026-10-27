import 'package:get/get.dart';

import '../core/utils/bengali_numerals.dart' as numerals;

class CurrentWeatherModel {
  final double tempNow;
  final double tempHigh;
  final double tempLow;
  final double feelsLike;
  final double precipitationMm;
  final double humidityPercent;
  final double pressureHpa;
  final double windSpeedKmh;
  final double windDirDeg;
  final double windGustKmh;
  final double cloudCoverPercent;
  final double uvIndex;

  /// Already in the request's language — the backend reads `Accept-Language`
  /// for this one (unlike `condition`, which always sends both and lets the
  /// client pick).
  final String uvDescription;
  final double visibilityKm;

  /// 0 both when the API genuinely reports none and when the field is
  /// `null` (common outside daylight hours) — matches [DayForecast]'s same
  /// soil-moisture/sunshine/THI handling, there's no separate "unavailable"
  /// state today.
  final double soilMoisturePercent;
  final double sunshineHours;
  final double thi;
  final DateTime? sunrise;
  final DateTime? sunset;
  final String condition;
  final String conditionShort;
  final String tempUnit;
  final String rfUnit;
  final String rhUnit;
  final String windspdUnit;
  final String windgustUnit;
  final String cldcvrUnit;
  final String soilmoistUnit;
  final String sunshineUnit;

  /// Raw filename from the API, e.g. "ic_mostly_cloudy_d.png" — combine with
  /// ApiEndpoints.baseUrlWeatherIcon for the full icon URL. Empty when the
  /// API didn't send one; callers should fall back to a local icon.
  final String icon;

  CurrentWeatherModel({
    required this.tempNow,
    required this.tempHigh,
    required this.tempLow,
    required this.feelsLike,
    required this.precipitationMm,
    required this.humidityPercent,
    required this.pressureHpa,
    required this.windSpeedKmh,
    required this.windDirDeg,
    required this.windGustKmh,
    required this.cloudCoverPercent,
    required this.uvIndex,
    required this.uvDescription,
    required this.visibilityKm,
    required this.soilMoisturePercent,
    required this.sunshineHours,
    required this.thi,
    this.sunrise,
    this.sunset,
    required this.condition,
    required this.conditionShort,
    required this.tempUnit,
    required this.rfUnit,
    required this.rhUnit,
    required this.windspdUnit,
    required this.windgustUnit,
    required this.cldcvrUnit,
    required this.soilmoistUnit,
    required this.sunshineUnit,
    required this.icon,
  });

  static double _numOf(dynamic v) => numerals.numOf(v);

  static DateTime? _dateTimeOf(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(numerals.toAsciiDigits(v.toString()));
  }

  /// ASCII 0-9 to Bengali numerals, for display.
  static String toBanglaDigits(String s) => numerals.toBanglaDigits(s);

  bool get _bn => Get.locale?.languageCode == 'bn';

  String _num(num v, {int dp = 0}) {
    final ascii = v.toStringAsFixed(dp);
    return _bn ? toBanglaDigits(ascii) : ascii;
  }

  String get tempNowText => '${_num(tempNow)}$tempUnit';
  String get tempNowUnit => _bn?'সে':'C';

  /// Just the localized number, no unit — lets callers style the unit
  /// (e.g. tempUnit) at a different size than the number.
  String get tempNowValue => _num(tempNow);
  String get tempHighText => '${_num(tempHigh)}$tempUnit';
  String get tempLowText => '${_num(tempLow)}$tempUnit';
  String get feelsLikeText => '${_num(feelsLike)}$tempUnit';

  /// Zero-padded to 2 digits (matches the Figma "00 mm" convention) before
  /// Bangla-digit transliteration.
  String get precipText {
    final ascii = precipitationMm.round().toString().padLeft(1, '0');
    return '${_bn ? toBanglaDigits(ascii) : ascii} $rfUnit';
  }

  String get humidityText => '${_num(humidityPercent)}%';

  /// No pressure-unit field exists in the API in either language — "hPa" is
  /// hardcoded, matching BMD's own app (only the digits are localized).
  String get pressureText => '${_num(pressureHpa)} hPa';

  String get windText => '${_num(windSpeedKmh)} $windspdUnit';
  String get windGustText => '${_num(windGustKmh)} $windgustUnit';
  String get cloudCoverText => '${_num(cloudCoverPercent)} $cldcvrUnit'.trim();
  String get uvText => _num(uvIndex);

  /// No unit field for visibility in the API — "km" is hardcoded, same
  /// reasoning as [pressureText].
  String get visibilityText => '${_num(visibilityKm, dp: 1)} km';
  String get soilMoistureText => '${_num(soilMoisturePercent, dp: 1)}$soilmoistUnit';
  String get sunshineText => '${_num(sunshineHours, dp: 1)} $sunshineUnit';
  String get thiText => _num(thi, dp: 1);

  Map<String, dynamic> toCacheJson() => {
        'tempNow': tempNow,
        'tempHigh': tempHigh,
        'tempLow': tempLow,
        'feelsLike': feelsLike,
        'precipitationMm': precipitationMm,
        'humidityPercent': humidityPercent,
        'pressureHpa': pressureHpa,
        'windSpeedKmh': windSpeedKmh,
        'windDirDeg': windDirDeg,
        'windGustKmh': windGustKmh,
        'cloudCoverPercent': cloudCoverPercent,
        'uvIndex': uvIndex,
        'uvDescription': uvDescription,
        'visibilityKm': visibilityKm,
        'soilMoisturePercent': soilMoisturePercent,
        'sunshineHours': sunshineHours,
        'thi': thi,
        'sunrise': sunrise?.toIso8601String(),
        'sunset': sunset?.toIso8601String(),
        'condition': condition,
        'conditionShort': conditionShort,
        'tempUnit': tempUnit,
        'rfUnit': rfUnit,
        'rhUnit': rhUnit,
        'windspdUnit': windspdUnit,
        'windgustUnit': windgustUnit,
        'cldcvrUnit': cldcvrUnit,
        'soilmoistUnit': soilmoistUnit,
        'sunshineUnit': sunshineUnit,
        'icon': icon,
      };

  static CurrentWeatherModel fromCacheJson(Map<String, dynamic> j) {
    // Only matters for a cache blob written before these unit fields existed
    // (or before this bn-fallback fix) — a normal cache always has them,
    // written correctly by [toCacheJson] from an already-resolved [fromJson].
    final bn = Get.locale?.languageCode == 'bn';
    return CurrentWeatherModel(
        tempNow: (j['tempNow'] as num).toDouble(),
        tempHigh: (j['tempHigh'] as num).toDouble(),
        tempLow: (j['tempLow'] as num).toDouble(),
        feelsLike: (j['feelsLike'] as num).toDouble(),
        precipitationMm: (j['precipitationMm'] as num).toDouble(),
        humidityPercent: (j['humidityPercent'] as num?)?.toDouble() ?? 0,
        pressureHpa: (j['pressureHpa'] as num).toDouble(),
        windSpeedKmh: (j['windSpeedKmh'] as num).toDouble(),
        windDirDeg: (j['windDirDeg'] as num).toDouble(),
        windGustKmh: (j['windGustKmh'] as num?)?.toDouble() ?? 0,
        cloudCoverPercent: (j['cloudCoverPercent'] as num?)?.toDouble() ?? 0,
        uvIndex: (j['uvIndex'] as num?)?.toDouble() ?? 0,
        uvDescription: j['uvDescription']?.toString() ?? '',
        visibilityKm: (j['visibilityKm'] as num?)?.toDouble() ?? 0,
        soilMoisturePercent: (j['soilMoisturePercent'] as num?)?.toDouble() ?? 0,
        sunshineHours: (j['sunshineHours'] as num?)?.toDouble() ?? 0,
        thi: (j['thi'] as num?)?.toDouble() ?? 0,
        sunrise: _dateTimeOf(j['sunrise']),
        sunset: _dateTimeOf(j['sunset']),
        condition: j['condition']?.toString() ?? '',
        conditionShort: j['conditionShort']?.toString() ?? '',
        tempUnit: j['tempUnit']?.toString() ?? (bn ? '°সে' : '°C'),
        rfUnit: j['rfUnit']?.toString() ?? (bn ? 'মি:মি:' : 'mm'),
        rhUnit: j['rhUnit']?.toString() ?? '%',
        windspdUnit: j['windspdUnit']?.toString() ?? (bn ? 'কিমি/ঘণ্টা' : 'km/h'),
        windgustUnit: j['windgustUnit']?.toString() ?? (bn ? 'কিমি/ঘণ্টা' : 'km/h'),
        cldcvrUnit: j['cldcvrUnit']?.toString() ?? (bn ? 'অক্টা' : ''),
        soilmoistUnit: j['soilmoistUnit']?.toString() ?? '%',
        sunshineUnit: j['sunshineUnit']?.toString() ?? (bn ? 'ঘণ্টা' : 'hrs'),
        icon: j['icon']?.toString() ?? '',
      );
  }

  static Map<String, dynamic>? _range(Map<String, dynamic>? obj, String key) =>
      obj?[key] as Map<String, dynamic>?;

  /// Returns null when there's no usable current-conditions data at all —
  /// callers should treat that as "unavailable", not render zeros.
  static CurrentWeatherModel? fromJson(Map<String, dynamic>? json) {
    // `result` is the BMD-direct/demo-JSON envelope key; `data` is our own
    // backend's `/api/v1/weather/current` (same inner shape, confirmed live).
    final result =
        (json?['result'] ?? json?['data']) as Map<String, dynamic>?;
    final current = result?['current'] as Map<String, dynamic>?;
    if (current == null || current.isEmpty) return null;

    final dailyList = result?['daily'] as List<dynamic>?;
    final today =
        (dailyList != null && dailyList.isNotEmpty)
            ? dailyList.first as Map<String, dynamic>?
            : null;

    final currentTemp = _range(current, 'temp');
    final dailyTemp = _range(today, 'temp') ?? currentTemp;
    final rf = _range(current, 'rf');
    final rh = _range(current, 'rh');
    final windspd = _range(current, 'windspd');
    final winddir = _range(current, 'winddir');
    final windgust = _range(current, 'windgust');
    final cldcvr = _range(current, 'cldcvr');

    final bn = Get.locale?.languageCode == 'bn';
    final bnCondition = current['type'] as String?;
    final enCondition = current['typen'] as String?;
    final condition = bn
        ? (bnCondition?.isNotEmpty == true ? bnCondition : enCondition)
        : (enCondition?.isNotEmpty == true ? enCondition : bnCondition);

    return CurrentWeatherModel(
      tempNow: _numOf(currentTemp?['val_avg']),
      tempHigh: _numOf(dailyTemp?['val_max']),
      tempLow: _numOf(dailyTemp?['val_min']),
      feelsLike: _numOf(current['feels']),
      precipitationMm: _numOf(rf?['val_avg']),
      humidityPercent: _numOf(rh?['val_avg']),
      pressureHpa: _numOf(current['pressure']),
      windSpeedKmh: _numOf(windspd?['val_avg']),
      windDirDeg: _numOf(winddir?['val_avg']),
      windGustKmh: _numOf(windgust?['val_avg']),
      cloudCoverPercent: _numOf(cldcvr?['val_avg']),
      uvIndex: _numOf(current['uv']),
      uvDescription: (current['uvDesc'] as String?) ?? '',
      visibilityKm: _numOf(current['vis']),
      soilMoisturePercent: _numOf(current['soil_moisture']),
      sunshineHours: _numOf(current['sunshine_hours']),
      thi: _numOf(current['thi']),
      sunrise: _dateTimeOf(current['sunrise']),
      sunset: _dateTimeOf(current['sunset']),
      condition: condition ?? '',
      conditionShort: (current['capabbr'] as String?) ?? '',
      // The bn-mode fallback (used when the API omits a unit field — observed
      // for sunshine_unit whenever sunshine_hours is null) must itself be a
      // Bangla string, not the English default reused from the `!bn` branch.
      tempUnit: bn ? ((current['temp_unit'] as String?) ?? '°সে') : '°C',
      rfUnit: bn ? ((current['rf_unit'] as String?) ?? 'মি:মি:') : 'mm',
      rhUnit: bn ? ((current['rh_unit'] as String?) ?? '%') : '%',
      windspdUnit: bn ? ((current['windspd_unit'] as String?) ?? 'কিমি/ঘণ্টা') : 'km/h',
      windgustUnit: bn ? ((current['windgust_unit'] as String?) ?? 'কিমি/ঘণ্টা') : 'km/h',
      cldcvrUnit: bn ? ((current['cldcvr_unit'] as String?) ?? 'অক্টা') : '',
      soilmoistUnit: bn ? ((current['soilmoist_unit'] as String?) ?? '%') : '%',
      sunshineUnit: bn ? ((current['sunshine_unit'] as String?) ?? 'ঘণ্টা') : 'hrs',
      icon: (current['icon'] as String?) ?? '',
    );
  }
}
