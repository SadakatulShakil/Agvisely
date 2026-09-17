class ApiEndpoints {
  ApiEndpoints._();

  // ===================================
  // Base URLs  — TODO: point at the DAE / Agvisely backend
  // ===================================
  static const String baseApiUrl = 'https://api.agvisely.gov.bd'; // TODO
  static const String baseAssetsUrl = 'https://agvisely.gov.bd/assets'; // TODO

  // Reachability probe used by NetworkController — leave as-is.
  static const String checkNetwork = 'https://clients3.google.com/generate_204';

  // ===================================
  // Location resolution (BMD weather API — same host BMD-Abohawa uses to
  // turn a lat/lon into a district/upazila/division; agvisely has no
  // equivalent of its own yet, so location lookups go through this host).
  // ===================================
  static const String baseUrlWeather = 'https://usf.bmd.gov.bd/api/app';
  static const String locationLatlon = '$baseUrlWeather/weather/forecast';

  // Condition icons for the `icon` field on current/daily/steps entries
  // (e.g. "ic_mostly_cloudy_d.png") — same host, confirmed live.
  static const String baseUrlWeatherIcon = 'https://usf.bmd.gov.bd/src/weather_icon';

  // Live weather (nearest station) — confirmed live: `type`/`icon` are
  // top-level, no `result` wrapper. `type` is server-localized per
  // Accept-Language; `icon` is a constant filename key either way.
  static String liveWeather(String lat, String lon) =>
      '$baseUrlWeather/weather/liveweather?lat=$lat&lon=$lon';

  // ===================================
  // Auth & user
  // ===================================
  static const String sendOtp = '$baseApiUrl/auth/mobile';
  static const String verifyOtp = '$baseApiUrl/auth/otpcheck';
  static const String refreshToken = '$baseApiUrl/auth/refresh';
  static const String userProfile = '$baseApiUrl/user/info';
  static const String fcmTokenUpdate = '$baseApiUrl/notification/token';

  // ===================================
  // Notifications
  // ===================================
  static const String notificationList = '$baseApiUrl/notification/list';

  // ===================================
  // Advisory modules (fill in as backend lands)
  // ===================================
  static const String weatherForecast = '$baseApiUrl/weather/forecast';
  static const String cropAdvisory = '$baseApiUrl/advisory/crop';
  static const String diseaseAdvisory = '$baseApiUrl/advisory/disease';
  static const String pestAdvisory = '$baseApiUrl/advisory/pest';
  static const String livestockAdvisory = '$baseApiUrl/advisory/livestock';
  static const String aquacultureAdvisory = '$baseApiUrl/advisory/aquaculture';
  static const String myChoice = '$baseApiUrl/user/mychoice';
}
