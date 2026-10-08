import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import '../../../core/utils/bengali_numerals.dart';
import '../../../models/seven_day_model.dart';

/// Backs the 7-day forecast page. Demo-JSON-backed for now; cached per
/// language so a locale switch triggers exactly one re-parse.
class SevenDayRepository {
  List<DayForecast>? _cache;
  String? _cachedLang;

  Future<List<DayForecast>> load() async {
    final lang = Get.locale?.languageCode == 'bn' ? 'bn' : 'en';
    if (_cache != null && _cachedLang == lang) return _cache!;

    final raw = await rootBundle.loadString('assets/json/forecast_demo_$lang.json');
    // TODO(api): replace the two lines above with
    //   GET ApiEndpoints.locationLatlon?type=point&lat=<lat>&lon=<lon>
    //   (ApiClient already sends Accept-Language). Keep the SAME parser below —
    //   result.daily[] / result.steps[] is the real API's shape too.

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final result = decoded['result'] as Map<String, dynamic>? ?? const {};
    final dailyJson =
        (result['daily'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    final stepsJson =
        (result['steps'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

    final steps = stepsJson.map((s) {
      final rf = s['rf'] as Map<String, dynamic>?;
      final temp = s['temp'] as Map<String, dynamic>?;
      final rh = s['rh'] as Map<String, dynamic>?;
      return ForecastChartPoint(
        time: DateTime.parse(s['step_start'] as String),
        rain: numOf(rf?['val_max']),
        temp: numOf(temp?['val_avg']),
        humidity: numOf(rh?['val_avg']),
      );
    }).toList();

    final days = dailyJson.map((d) {
      final dayStart = DateTime.parse(d['step_start'] as String);
      final dayChart = steps
          .where((p) =>
              p.time.year == dayStart.year &&
              p.time.month == dayStart.month &&
              p.time.day == dayStart.day)
          .toList();
      return DayForecast.fromJson(d, chart: dayChart);
    }).toList();

    _cache = days;
    _cachedLang = lang;
    return days;
  }
}
