import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/services/user_pref_service.dart';
import '../../../core/utils/bengali_numerals.dart';
import '../../../models/seven_day_model.dart';

/// Backs the 7-day forecast page (and the home dashboard's "today" chart).
/// Prefers a live call to our own backend's `/api/v1/weather/current` for
/// the active saved location; falls back to the bundled demo JSON — its
/// only source before — on any failure (logged out, no location resolved
/// yet, backend unreachable). Cached per (language, lat, lon) so repeat
/// calls (home + 7-day page both call this) don't refetch needlessly.
class SevenDayRepository {
  List<DayForecast>? _cache;
  String? _cachedKey;

  Future<List<DayForecast>> load() async {
    final isBn = Get.locale?.languageCode == 'bn';
    final lang = isBn ? 'bn' : 'en';
    final lat = UserPrefService().getLat();
    final lon = UserPrefService().getLon();
    final cacheKey = '$lang|$lat|$lon';
    if (_cache != null && _cachedKey == cacheKey) return _cache!;

    final live = await _loadLive(lat, lon);
    final decoded = live ??
        jsonDecode(await rootBundle.loadString('assets/json/forecast_demo_$lang.json'))
            as Map<String, dynamic>;

    // `result` is the demo-JSON envelope key; `data` is our own backend's
    // (confirmed live to carry the same inner shape).
    final result =
        (decoded['result'] ?? decoded['data']) as Map<String, dynamic>? ?? const {};
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
      return DayForecast.fromJson(d, chart: dayChart, isBn: isBn);
    }).toList();

    // TODO(api): the live endpoint's daily[] currently runs ~10 days deep but
    // steps[] (its per-day graph source) only covers ~4 days of 3-hourly
    // detail — days past that render with an empty graph. Capped to 4 for
    // now so every visible day actually has a graph; bump back to 7 (the
    // "7 Day Forecast" page's original framing) once steps[] covers a full
    // week, or once empty-chart days are handled some other way in the UI.
    final cappedDays = days.length > 4 ? days.sublist(0, 4) : days;

    _cache = cappedDays;
    _cachedKey = cacheKey;
    return cappedDays;
  }

  /// Returns the decoded `{message, data: {...}}` envelope on success, or
  /// null (caller falls back to demo JSON) if there's no location yet, no
  /// session, or the call fails for any reason.
  Future<Map<String, dynamic>?> _loadLive(String? lat, String? lon) async {
    if (lat == null || lat.isEmpty || lon == null || lon.isEmpty) return null;
    try {
      final token = await UserPrefService().getAccessToken();
      if (token == null || token.isEmpty) return null;
      final resp = await ApiClient().get(
        ApiEndpoints.weatherCurrent(lat, lon),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp is! Map || resp['data'] is! Map) return null;
      return resp as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
