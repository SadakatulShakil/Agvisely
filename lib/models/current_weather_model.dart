import 'package:get/get.dart';

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

  static const _bengaliDigits = '০১২৩৪৫৬৭৮৯';

  static String _toAsciiDigits(String s) {
    final buffer = StringBuffer();
    for (final ch in s.split('')) {
      final idx = _bengaliDigits.indexOf(ch);
      buffer.write(idx == -1 ? ch : idx.toString());
    }
    return buffer.toString();
  }

  static double _numOf(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(_toAsciiDigits(v?.toString() ?? '')) ?? 0;
  }

  /// Reverse of [_toAsciiDigits] — ASCII 0-9 to Bengali numerals, for display.
  static String toBanglaDigits(String s) {
    final buffer = StringBuffer();
    for (final ch in s.split('')) {
      final idx = '0123456789'.indexOf(ch);
      buffer.write(idx == -1 ? ch : _bengaliDigits[idx]);
    }
    return buffer.toString();
  }

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
    final result = json?['result'] as Map<String, dynamic>?;
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

    return CurrentWeatherModel(
      tempNow: _numOf(currentTemp?['val_avg']),
      tempHigh: _numOf(dailyTemp?['val_max']),
      tempLow: _numOf(dailyTemp?['val_min']),
      feelsLike: _numOf(current['feels']),
      precipitationMm: _numOf(rf?['val_avg']),
      pressureHpa: _numOf(current['pressure']),
      windSpeedKmh: _numOf(windspd?['val_avg']),
      windDirDeg: _numOf(winddir?['val_avg']),
      condition: (current['type'] as String?) ?? '',
      conditionShort: (current['capabbr'] as String?) ?? '',
      tempUnit: (current['temp_unit'] as String?) ?? '°C',
      rfUnit: (current['rf_unit'] as String?) ?? 'mm',
      windspdUnit: (current['windspd_unit'] as String?) ?? 'km/h',
      icon: (current['icon'] as String?) ?? '',
    );
  }
}
