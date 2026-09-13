import 'package:shared_preferences/shared_preferences.dart';

class UserPrefService {
  UserPrefService._internal();
  static final UserPrefService _instance = UserPrefService._internal();
  factory UserPrefService() => _instance;

  SharedPreferences? _prefs;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    _prefs = await SharedPreferences.getInstance();
    _ready = true;
  }

  // Keys
  static const String _keyUserToken = 'TOKEN';
  static const String _keyUserRefresh = 'REFRESH';
  static const String _keyUserId = 'ID';
  static const String _keyUserEmail = 'EMAIL';
  static const String _keyUserName = 'NAME';
  static const String _keyFirstName = 'FIRSTNAME';
  static const String _keyLastName = 'LASTNAME';
  static const String _keyUserMobile = 'MOBILE';
  static const String _keyUserAddress = 'ADDRESS';
  static const String _keyUserType = 'TYPE';
  static const String _keyUserPhoto = 'PHOTO';
  static const String _keyFcmToken = 'FCM';
  static const String _keyLat = 'LAT';
  static const String _keyCitizenLat = 'CITY_LAT';
  static const String _keyLon = 'LON';
  static const String _keyCitizenLon = 'CITY_LON';
  static const String _keyLocationId = 'LOCATION_ID';
  static const String _keyLocationName = 'LOCATION_NAME';
  static const String _keyDisplayName = 'DISPLAY_NAME';
  static const String _keyLocationUpazila = 'LOCATION_UPAZILA';
  static const String _keyLocationUpazilaBn = 'LOCATION_UPAZILA_BN';
  static const String _keyLocationDistrict = 'LOCATION_DISTRICT';
  static const String _keyLocationDistrictBn = 'LOCATION_DISTRICT_BN';
  static const String _keyLocationDivision = 'LOCATION_DIVISION';
  static const String _keyLocationDivisionBn = 'LOCATION_DIVISION_BN';
  static const String _keyAppLanguage = 'APP_LANGUAGE';
  static const String _updatedDate = 'CONTENT_UPDATE';
  static const String _keyFollowGPS = 'FOLLOW_GPS';
  static const String _keySurveyLastSubmitted = 'SURVEY_LAST_SUBMITTED_AT';
  static const String _keyLiveVideoUrl    = 'live_video_url';
  static const String _keyLiveWeatherType = 'live_weather_type';
  static const String _keyLiveWeatherIcon = 'live_weather_icon';

  static const String _keySavedLocations = 'SAVED_LOCATIONS';
  static const int _surveyCooldownMinutes = 60;

  // ===== Utility =====
  Future<void> _setStringIfChanged(String key, String value) async {
    if (_prefs?.getString(key) != value) {
      await _prefs?.setString(key, value);
    }
  }

  // ===== Firebase =====
  Future<void> saveFireBaseData(String fcmToken) async {
    await _setStringIfChanged(_keyFcmToken, fcmToken);
  }

  // ── Generic pass-throughs (used by NotificationPrefs, theme, etc.) ─────────
  bool? getBool(String key) => _prefs?.getBool(key);
  Future<bool>? setBool(String key, bool value) => _prefs?.setBool(key, value);

  String? getString(String key) => _prefs?.getString(key);
  Future<bool>? setString(String key, String value) =>
      _prefs?.setString(key, value);

  int? getInt(String key) => _prefs?.getInt(key);
  Future<bool>? setInt(String key, int value) => _prefs?.setInt(key, value);

  double? getDouble(String key) => _prefs?.getDouble(key);
  Future<bool>? setDouble(String key, double value) =>
      _prefs?.setDouble(key, value);

  Future<bool>? remove(String key) => _prefs?.remove(key);

  // ── App-specific keys ──────────────────────────────────────────────────────
  static const String _kLanguage = 'app_language';
  static const String _kOnboarded = 'has_onboarded';
  static const String _kLoggedIn = 'is_logged_in';
  static const String _kLocationName = 'selected_location_name';

  /// 'en' or 'bn' — defaults to Bangla for Agvisely's audience.
  String get appLanguage => _prefs?.getString(_kLanguage) ?? 'bn';
  Future<bool>? setAppLanguage(String code) =>
      _prefs?.setString(_kLanguage, code);

  bool get hasOnboarded => _prefs?.getBool(_kOnboarded) ?? false;
  Future<bool>? setOnboarded(bool v) => _prefs?.setBool(_kOnboarded, v);

  bool get isLoggedIn => _prefs?.getBool(_kLoggedIn) ?? false;
  Future<bool>? setLoggedIn(bool v) => _prefs?.setBool(_kLoggedIn, v);

  String? get locationName => _prefs?.getString(_kLocationName);
  Future<bool>? setLocationName(String v) =>
      _prefs?.setString(_kLocationName, v);

  // ===== Getters =====
  String? get userId => _prefs?.getString(_keyUserId);
  String? get userName => _prefs?.getString(_keyUserName);
  String? get firstName => _prefs?.getString(_keyFirstName);
  String? get lastName => _prefs?.getString(_keyLastName);
  String? get userEmail => _prefs?.getString(_keyUserEmail);
  String? get userMobile => _prefs?.getString(_keyUserMobile);
  String? get userAddress => _prefs?.getString(_keyUserAddress);
  String? get userType => _prefs?.getString(_keyUserType);
  String? get userPhoto => _prefs?.getString(_keyUserPhoto);
  String? get fcmToken => _prefs?.getString(_keyFcmToken);
  String? get lat => _prefs?.getString(_keyLat);
  String? get lon => _prefs?.getString(_keyLon);
  String? get locationId => _prefs?.getString(_keyLocationId);
  String? get displayName => _prefs?.getString(_keyDisplayName);
  String? get locationUpazila => _prefs?.getString(_keyLocationUpazila);
  String? get locationUpazilaBn => _prefs?.getString(_keyLocationUpazilaBn);
  String? get locationDistrict => _prefs?.getString(_keyLocationDistrict);
  String? get locationDistrictBn => _prefs?.getString(_keyLocationDistrictBn);
  String? get locationDivision => _prefs?.getString(_keyLocationDivision);
  String? get locationDivisionBn => _prefs?.getString(_keyLocationDivisionBn);
  bool get isFollowingGPS => _prefs?.getBool(_keyFollowGPS) ?? true; // Default to true
}
