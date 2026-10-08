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
  // Location resolution (BMD weather API — same host BMD-Abohawa uses to fetch weather data)
  // ===================================
  static const String baseUrlWeather = 'https://usf.bmd.gov.bd/api/app';
  static const String locationLatlon = '$baseUrlWeather/weather/forecast';

  static const String baseUrlWeatherIcon = 'https://usf.bmd.gov.bd/src/weather_icon';

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
  // User/auth backend (signup, login, OTP, professions)
  // localhost works ONLY on the host machine. For testing:
  //   Android emulator → http://10.0.2.2:3000/api/v1
  //   physical device  → http://<machine-LAN-IP>:3000/api/v1
  // ===================================
  static const String baseUrlUser = 'http://192.168.68.54:3000/api/v1';
  static const String professions = '$baseUrlUser/professions';
  static const String signupUrl = '$baseUrlUser/users/signup';
  static const String loginUrl = '$baseUrlUser/users/login';
  static const String verifyOtpUrl = '$baseUrlUser/users/verify-otp';
  static const String userMeUrl = '$baseUrlUser/users/me';
  static const String refreshTokenUrl = '$baseUrlUser/users/refresh-token';
  static const String logoutUrl = '$baseUrlUser/users/logout';

  /// Host root for the user/auth backend (same host as [baseUrlUser], minus
  /// the `/api/v1` path) — used to resolve relative paths like
  /// `UserModel.profileUrl` into full, loadable image URLs.
  static String get baseUrlUserHost =>
      baseUrlUser.replaceFirst(RegExp(r'/api/v\d+$'), '');

  static const String advisoryCategories = '$baseUrlUser/advisory/categories';

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
