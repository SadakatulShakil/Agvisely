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
  //   Android emulator → http://10.0.2.2:3000/api/v1
  //   physical device  → http://<machine-LAN-IP>:3000/api/v1
  //   Run this on CMD "ipconfig getifaddr en0" for your LAN IP on macOS, or ipconfig on Windows.
  // ===================================
  static const String baseUrlUser = 'http://192.168.68.52:3000/api/v1';
  static const String professions = '$baseUrlUser/professions';
  static const String signupUrl = '$baseUrlUser/users/signup';
  static const String loginUrl = '$baseUrlUser/users/login';
  static const String verifyOtpUrl = '$baseUrlUser/users/verify-otp';
  static const String userMeUrl = '$baseUrlUser/users/me';
  static const String userMeProfilePictureUrl = '$baseUrlUser/users/me/profile-picture';
  static const String refreshTokenUrl = '$baseUrlUser/users/refresh-token';
  static const String logoutUrl = '$baseUrlUser/users/logout';

  /// Host root for the user/auth backend (same host as [baseUrlUser], minus
  /// the `/api/v1` path) — used to resolve relative paths like
  /// `UserModel.profileUrl` into full, loadable image URLs.
  static String get baseUrlUserHost =>
      baseUrlUser.replaceFirst(RegExp(r'/api/v\d+$'), '');

  /// `GET /weather/current?lat=&lon=` — our own backend's authenticated
  static String weatherCurrent(String lat, String lon) =>
      '$baseUrlUser/weather/current?lat=$lat&lon=$lon';

  static const String advisoryCategories = '$baseUrlUser/advisory/categories';

  /// `GET /advisory/categories/{categoryId}/items` — the item grid (crops,
  /// livestock, etc.) shown on an advisory module's "select an item" screen.
  static String advisoryCategoryItems(int categoryId) =>
      '$baseUrlUser/advisory/categories/$categoryId/items';

  /// `GET /advisory/categories/{categoryId}/items/{itemId}/stages` — the
  /// stage list (sowing, sprouting, ...) shown after an item is picked.
  /// `stageCategory` picks between the item's advisory stages (default,
  /// also used when left out) and its disease stages — pass `'disease'`
  /// for the Crop Disease Early Warning flow.
  static String advisoryItemStages(int categoryId, int itemId, {String? stageCategory}) {
    final base = '$baseUrlUser/advisory/categories/$categoryId/items/$itemId/stages';
    return stageCategory == null || stageCategory.isEmpty
        ? base
        : '$base?category=$stageCategory';
  }

  /// `POST /advisory/categories/{categoryId}/items/{itemId}/stages/{stageId}/rules/match`
  /// with `{lat, lon}` body — the advisory rules already matched against
  /// that location's current weather (IPM rules always included), rendered
  /// as the body of [AdvisoryContentPage].
  static String advisoryStageRulesMatch(int categoryId, int itemId, int stageId) =>
      '$baseUrlUser/advisory/categories/$categoryId/items/$itemId/stages/$stageId/rules/match';

  /// `GET /user-choices` — the logged-in user's saved "My Choice" picks.
  /// `POST /user-choices` with `{categoryId, itemId}` — add one (confirmed
  /// live: the backend upserts by categoryId+itemId, so re-adding the same
  /// pair is safe, not an error).
  static const String userChoices = '$baseUrlUser/user-choices';

  /// `DELETE /user-choices/{id}` — removes one by the choice's own `id`
  /// (not categoryId/itemId).
  static String userChoice(int id) => '$baseUrlUser/user-choices/$id';

  // ===================================
  // Notifications
  // ===================================
  /// `GET /notifications?page=&limit=&order=` — the current user's
  /// notification inbox: ones sent to everyone plus ones sent to them by
  /// id, newest first. `limit` is capped at 100 by the backend; `order` is
  /// `asc`/`desc` by id (`desc` is the backend default).
  static String notifications({int page = 1, int limit = 20, String order = 'desc'}) =>
      '$baseUrlUser/notifications?page=$page&limit=$limit&order=$order';

  /// `PUT /notifications/{id}/read` — marks one notification read for the
  /// current user (idempotent: re-marking keeps the first `readAt`).
  static String notificationMarkRead(int id) => '$baseUrlUser/notifications/$id/read';

  // ===================================
  // Advisory modules (fill in as backend lands)
  // ===================================
  static const String weatherForecast = '$baseApiUrl/weather/forecast';
  static const String cropAdvisory = '$baseApiUrl/advisory/crop';
  static const String diseaseAdvisory = '$baseApiUrl/advisory/disease';
  static const String pestAdvisory = '$baseApiUrl/advisory/pest';
  static const String livestockAdvisory = '$baseApiUrl/advisory/livestock';
  static const String aquacultureAdvisory = '$baseApiUrl/advisory/aquaculture';
}
