/// Maps BMD weather-icon filenames (as returned by the API's `icon` field,
/// e.g. "ic_mostly_cloudy_d.png") to the matching bundled asset, so the app
/// can render from assets/icons/weather_icons instead of hitting the
/// network. Filenames not in [_bundled] (e.g. a new icon BMD adds later)
/// fall back to the network image.
class WeatherIconAssets {
  WeatherIconAssets._();

  static const String _basePath = 'assets/icons/weather_icons/';

  static const Set<String> _bundled = {
    'ic_clear.png',
    'ic_clear_chance_of_rain.png',
    'ic_cloudy_with_heavy_rain_d.png',
    'ic_cloudy_with_heavy_rain_n.png',
    'ic_cloudy_with_light_rain.png',
    'ic_cloudy_with_light_rain_d.png',
    'ic_cloudy_with_light_rain_n.png',
    'ic_cloudy_with_moderate_rain_d.png',
    'ic_cloudy_with_moderate_rain_n.png',
    'ic_foog.png',
    'ic_lightning.png',
    'ic_mostly_clear.png',
    'ic_mostly_clear_chance_of_rain.png',
    'ic_mostly_cloudy.png',
    'ic_mostly_cloudy_d.png',
    'ic_mostly_cloudy_n.png',
    'ic_mostly_cloudy_with_heavy_rain_d.png',
    'ic_mostly_cloudy_with_heavy_rain_n.png',
    'ic_mostly_cloudy_with_light_rain_d.png',
    'ic_mostly_cloudy_with_light_rain_n.png',
    'ic_mostly_cloudy_with_moderate_rain_d.png',
    'ic_mostly_cloudy_with_moderate_rain_n.png',
    'ic_mostly_sunny.png',
    'ic_mostly_sunny_chance_of_rain.png',
    'ic_overcast.png',
    'ic_partly_cloudy_d.png',
    'ic_partly_cloudy_n.png',
    'ic_partly_cloudy_with_heavy_rain_d.png',
    'ic_partly_cloudy_with_heavy_rain_n.png',
    'ic_partly_cloudy_with_light_rain_d.png',
    'ic_partly_cloudy_with_light_rain_n.png',
    'ic_partly_cloudy_with_moderate_rain_d.png',
    'ic_partly_cloudy_with_moderate_rain_n.png',
    'ic_rainy.png',
    'ic_sunny.png',
    'ic_sunny_chance_of_rain.png',
    'ic_thundershower.png',
    'ic_thunderstorm.png',
  };

  /// Returns the local asset path for [apiIconFilename] (e.g.
  /// "ic_mostly_cloudy_d.png", optionally with a leading path/slashes), or
  /// null if we don't have a bundled asset for it.
  static String? assetPath(String apiIconFilename) {
    final fileName = apiIconFilename.split('/').last.trim();
    if (fileName.isEmpty || !_bundled.contains(fileName)) return null;
    return '$_basePath$fileName';
  }
}
