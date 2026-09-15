/// Parses the `result.current` (+ `result.daily[0]` for today's high/low)
/// objects from BMD's forecast endpoint (ApiEndpoints.locationLatlon) — the
/// same host/endpoint already used for location resolution.
///
/// Real response shape (confirmed live), trimmed to the fields this model
/// reads:
/// { "result": {
///     "current": {
///       "temp": {"val_min":"33.4","val_avg":"34.4","val_max":"35.4"},
///       "feels": "38.6", "pressure": 1006,
///       "rf": {"val_min":"0","val_avg":"0","val_max":"1"}, "rf_unit": "mm",
///       "windspd": {"val_avg":"7.8"}, "windspd_unit": "km/h",
///       "winddir": {"val_avg":"267.2"},
///       "type": "Mostly Cloudy With Light Rain", "capabbr": "Partly sunny",
///       "temp_unit": "°C" },
///     "daily": [ { "temp": {"val_min":"26.9","val_max":"35.4"} }, ... ] } }
///
/// `current.temp` is only the average over the current 3-hour step, so H/L
/// come from today's entry in `daily` (the day's actual min/max) instead.
///
/// With `Accept-Language: bn` every number in the payload comes back as a
/// Bengali-numeral STRING (e.g. pressure `"১০০৭"` instead of `1006`) — even
/// fields that are a raw JSON number in the English response. `double.parse`
/// can't read Bengali digits, so they must be transliterated to ASCII first
/// or every field silently parses to 0.
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

  static Map<String, dynamic>? _range(Map<String, dynamic>? obj, String key) =>
      obj?[key] as Map<String, dynamic>?;

  /// Returns null when there's no usable current-conditions data at all —
  /// callers should treat that as "unavailable", not render zeros.
  static CurrentWeatherModel? fromJson(Map<String, dynamic>? json) {
    final result = json?['result'] as Map<String, dynamic>?;
    final current = result?['current'] as Map<String, dynamic>?;
    if (current == null || current.isEmpty) return null;

    final dailyList = result?['daily'] as List<dynamic>?;
    final today = (dailyList != null && dailyList.isNotEmpty)
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
    );
  }
}
