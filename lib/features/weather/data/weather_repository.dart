import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/services/user_pref_service.dart';
import '../../../models/current_weather_model.dart';
import '../../../models/live_weather_model.dart';

/// Fetches current-weather data, preferring our own authenticated backend
/// (`ApiEndpoints.weatherCurrent`, confirmed live to return the same
/// `current`/`daily[]` shape as BMD's point-lookup) and falling back to
/// BMD's point-lookup endpoint directly — the original, always-available
/// (no-login-required) source — if the backend call fails for any reason
/// (logged out, backend unreachable, etc).
class WeatherRepository {
  Future<CurrentWeatherModel?> fetchCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    final fromBackend = await _fetchFromOwnBackend(lat, lon);
    if (fromBackend != null) return fromBackend;
    return _fetchFromBmd(lat, lon);
  }

  Future<CurrentWeatherModel?> _fetchFromOwnBackend(double lat, double lon) async {
    try {
      final token = await UserPrefService().getAccessToken();
      if (token == null || token.isEmpty) return null;
      final data = await ApiClient().get(
        ApiEndpoints.weatherCurrent(lat.toString(), lon.toString()),
        headers: {'Authorization': 'Bearer $token'},
      );
      return CurrentWeatherModel.fromJson(data as Map<String, dynamic>?);
    } catch (_) {
      return null;
    }
  }

  Future<CurrentWeatherModel?> _fetchFromBmd(double lat, double lon) async {
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
