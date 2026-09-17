import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../models/current_weather_model.dart';
import '../../../models/live_weather_model.dart';

/// Fetches current-weather data via BMD's point-lookup endpoint — the same
/// host/endpoint ApiLocationModel already reads for location resolution.
/// Agvisely has no weather backend of its own yet (see ApiEndpoints.weatherForecast),
/// so this is the only live source for current conditions.
class WeatherRepository {
  Future<CurrentWeatherModel?> fetchCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    try {
      final data = await ApiClient().get(
        '${ApiEndpoints.locationLatlon}?type=point&lat=$lat&lon=$lon',
      );
      return CurrentWeatherModel.fromJson(data as Map<String, dynamic>?);
    } catch (_) {
      return null;
    }
  }

  /// Nearest-station live conditions — only `type`/`icon` are used
  /// (see LiveWeatherModel). Empty model on any failure so callers can
  /// treat it the same as "no live override" without extra null checks.
  Future<LiveWeatherModel> getLiveWeather({
    required double lat,
    required double lon,
  }) async {
    try {
      final data = await ApiClient().get(
        ApiEndpoints.liveWeather(lat.toString(), lon.toString()),
      );
      return LiveWeatherModel.fromJson(data as Map<String, dynamic>?);
    } catch (_) {
      return const LiveWeatherModel();
    }
  }
}
