/// Slim model for BMD's live-weather endpoint (ApiEndpoints.liveWeather) —
/// only `type` and `icon` are used; agvisely doesn't show live video,
/// lightning, rainfall, temp, or feels-like. Confirmed live: `type`/`icon`
/// are top-level fields (no `result` wrapper). `type` is server-localized
/// per Accept-Language; `icon` is a constant filename key regardless of
/// language.
class LiveWeatherModel {
  /// '' = don't override the forecast's condition text.
  final String type;

  /// '' = don't override the forecast's icon; else a PNG key like
  /// "ic_thundershower.png" — combine with ApiEndpoints.baseUrlWeatherIcon.
  final String icon;

  const LiveWeatherModel({this.type = '', this.icon = ''});

  factory LiveWeatherModel.fromJson(Map<String, dynamic>? json) {
    final j = json ?? const {};
    return LiveWeatherModel(
      type: j['type']?.toString() ?? '',
      icon: j['icon']?.toString() ?? '',
    );
  }
}
