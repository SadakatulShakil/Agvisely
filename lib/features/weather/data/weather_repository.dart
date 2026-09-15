import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../models/current_weather_model.dart';

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
}
