import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/api_location_model.dart';
import '../../models/saved_location_model.dart';
import '../network/api_endpoints.dart';

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
  static const String _keySelectedLocation = 'SELECTED_LOCATION';
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
  Future<void> setFollowGPS(bool follow) async {
    await _prefs?.setBool(_keyFollowGPS, follow);
  }

  // ── Location-flow (splash gate / SelectLocationPage / LocationService) ─────
  String? getLat() => lat;
  String? getLon() => lon;

  Future<void> saveLatLonData(String lat, String lon) async {
    await _prefs?.setString(_keyLat, lat);
    await _prefs?.setString(_keyLon, lon);
  }

  /// Persists the user's chosen union as the active location: lat/lon,
  /// the display name shown on Home (via the existing [locationName]
  /// getter), and the full record for later district/upazila/pcode reads.
  Future<void> saveSelectedLocation(SavedLocation loc, {required bool isBangla}) async {
    await saveLatLonData(loc.lat.toString(), loc.lng.toString());
    await setLocationName(loc.displayName(isBangla));
    await _prefs?.setString(_keySelectedLocation, jsonEncode(loc.toJson()));
  }

  SavedLocation? getSelectedLocation() {
    final raw = _prefs?.getString(_keySelectedLocation);
    if (raw == null) return null;
    try {
      return SavedLocation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// GPS-driven update that must never clobber a location the user picked
  /// manually. Mirrors BMD's isFollowingGPS / updateGPSLocationSilently
  /// distinction — agvisely has a single active-location slot rather than
  /// BMD's saved-locations list, so "silently update the GPS entry" collapses
  /// to "only touch the active slot when the user is still following GPS".
  Future<void> updateGPSLocationSilently(SavedLocation loc, {required bool isBangla}) async {
    if (!isFollowingGPS) return;
    await saveSelectedLocation(loc, isBangla: isBangla);
  }

  /// Resolves a lat/lon into a full location (district/upazila/division)
  /// via BMD's weather API. [displayNameFallback]/[displayNameFallbackBn],
  /// when given, are PREFERRED over the API's own location name (matches
  /// BMD: a caller-supplied name — e.g. from the local union picker — is
  /// more natural than the API's combined "city, upazila, district" string).
  /// Returns null only when there's nothing usable at all: the API call
  /// failed/returned no name AND no fallback name was given.
  Future<SavedLocation?> fetchLocationDetailsFromApi({
    required double lat,
    required double lon,
    String displayNameFallback = '',
    String displayNameFallbackBn = '',
  }) async {
    ApiLocationModel? apiLoc;
    try {
      final resp = await http.get(
        Uri.parse('${ApiEndpoints.locationLatlon}?type=point&lat=$lat&lon=$lon'),
        headers: {'Accept-Language': Get.locale?.languageCode ?? 'bn'},
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        apiLoc = ApiLocationModel.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
      }
    } catch (e) {
      apiLoc = null;
    }

    final apiName = apiLoc?.locationName ?? '';
    final nameEn = displayNameFallback.isNotEmpty ? displayNameFallback : apiName;
    final nameBn = displayNameFallbackBn.isNotEmpty ? displayNameFallbackBn : apiName;

    if (nameEn.isEmpty && nameBn.isEmpty) return null;

    return SavedLocation(
      name: nameEn,
      nameBn: nameBn,
      lat: lat,
      lng: lon,
      pcode: apiLoc?.id ?? '',
      upazila: apiLoc?.upazila ?? '',
      upazilaBn: apiLoc?.upazilaBn ?? '',
      district: apiLoc?.district ?? '',
      districtBn: apiLoc?.districtBn ?? '',
      division: apiLoc?.division ?? '',
      divisionBn: apiLoc?.divisionBn ?? '',
    );
  }
}
