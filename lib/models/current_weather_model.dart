import 'package:get/get.dart';

import '../core/utils/bengali_numerals.dart' as numerals;

class CurrentWeatherModel {
  final double tempNow;
  final double tempHigh;
  final double tempLow;
  final double feelsLike;
  final double precipitationMm;
  final double pressureHpa;
  final double windSpeedKmh;
  final double windDirDeg;
  final String condition;
  final String conditionShort;
  final String tempUnit;
  final String rfUnit;
  final String windspdUnit;

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
    required this.pressureHpa,
    required this.windSpeedKmh,
    required this.windDirDeg,
    required this.condition,
    required this.conditionShort,
    required this.tempUnit,
    required this.rfUnit,
    required this.windspdUnit,
    required this.icon,
  });

  static double _numOf(dynamic v) => numerals.numOf(v);

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

  /// No pressure-unit field exists in the API in either language — "hPa" is
  /// hardcoded, matching BMD's own app (only the digits are localized).
  String get pressureText => '${_num(pressureHpa)} hPa';

  String get windText => '${_num(windSpeedKmh)} $windspdUnit';

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
    final windspd = _range(current, 'windspd');
    final winddir = _range(current, 'winddir');

    // Our own backend's endpoint always sends bn condition text/units
    // regardless of locale (confirmed live) — `typen` carries the en
    // condition text alongside bn's `type`. No-op against BMD-direct/demo
    // JSON, which already match the active locale.
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
      pressureHpa: _numOf(current['pressure']),
      windSpeedKmh: _numOf(windspd?['val_avg']),
      windDirDeg: _numOf(winddir?['val_avg']),
      condition: condition ?? '',
      conditionShort: (current['capabbr'] as String?) ?? '',
      tempUnit: bn ? ((current['temp_unit'] as String?) ?? '°C') : '°C',
      rfUnit: bn ? ((current['rf_unit'] as String?) ?? 'mm') : 'mm',
      windspdUnit: bn ? ((current['windspd_unit'] as String?) ?? 'km/h') : 'km/h',
      icon: (current['icon'] as String?) ?? '',
    );
  }
}
