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

  /// Persists the user's chosen union as the active location. Kept for
  /// existing call sites — now implemented via the saved-locations list so
  /// the entry also shows up in the saved-locations sheet. [isBangla] is
  /// unused internally (the mirror sync reads [Get.locale] itself) but kept
  /// in the signature for compatibility.
  Future<void> saveSelectedLocation(SavedLocation loc, {required bool isBangla}) =>
      addOrUpdateCustom(loc, makeCurrent: true);

  SavedLocation? getSelectedLocation() {
    final raw = _prefs?.getString(_keySelectedLocation);
    if (raw == null) return null;
    try {
      return SavedLocation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
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

  // ── Saved-locations list (GPS entry + custom entries) ──────────────────────

  Future<List<SavedLocation>> _readSavedLocations() async {
    final raw = _prefs?.getStringList(_keySavedLocations) ?? [];
    return raw
        .map((e) {
          try {
            return SavedLocation.fromJson(jsonDecode(e) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<SavedLocation>()
        .toList();
  }

  Future<void> _writeSavedLocations(List<SavedLocation> list) async {
    await _prefs?.setStringList(
      _keySavedLocations,
      list.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  /// Mirrors the isCurrent entry into the flat keys the rest of the app
  /// reads (getLat/getLon/locationName/isFollowingGPS).
  Future<void> _syncMirrorFromList(List<SavedLocation> list) async {
    final current = list.firstWhereOrNull((l) => l.isCurrent);
    if (current == null) return;
    final isBangla = Get.locale?.languageCode == 'bn';
    await saveLatLonData(current.lat.toString(), current.lng.toString());
    await setLocationName(current.displayName(isBangla));
    await setFollowGPS(current.isGps);
  }

  /// GPS first, then the rest alphabetically. isCurrent is preserved as data
  /// on each entry, not used for ordering.
  Future<List<SavedLocation>> getSavedLocations() async {
    final list = await _readSavedLocations();
    list.sort((a, b) {
      if (a.isGps != b.isGps) return a.isGps ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    return list;
  }

  /// Replaces the single isGps=true entry (there is only ever one).
  Future<void> upsertGpsLocation(SavedLocation gps, {bool makeCurrent = false}) async {
    final list = await _readSavedLocations();
    final idx = list.indexWhere((l) => l.isGps);
    final wasCurrent = idx != -1 && list[idx].isCurrent;
    final shouldBeCurrent = makeCurrent || wasCurrent;
    final entry = gps.copyWith(isGps: true, isCurrent: shouldBeCurrent);

    if (shouldBeCurrent) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].isCurrent) list[i] = list[i].copyWith(isCurrent: false);
      }
    }
    if (idx != -1) {
      list[idx] = entry;
    } else {
      list.add(entry);
    }
    await _writeSavedLocations(list);
    await _syncMirrorFromList(list);
  }

  /// Adds or updates a custom (non-GPS) entry, matched by pcode.
  Future<void> addOrUpdateCustom(SavedLocation loc, {bool makeCurrent = true}) async {
    final list = await _readSavedLocations();
    final entry = loc.copyWith(isGps: false, isCurrent: makeCurrent);
    final idx = loc.pcode.isNotEmpty
        ? list.indexWhere((l) => !l.isGps && l.pcode == loc.pcode)
        : -1;

    if (makeCurrent) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].isCurrent) list[i] = list[i].copyWith(isCurrent: false);
      }
    }
    if (idx != -1) {
      list[idx] = entry;
    } else {
      list.add(entry);
    }
    await _writeSavedLocations(list);
    await _syncMirrorFromList(list);
  }

  /// Marks [loc] as the active entry (matched by isGps, or by pcode for
  /// custom entries) and clears isCurrent on every other entry.
  Future<void> setCurrent(SavedLocation loc) async {
    final list = await _readSavedLocations();
    for (var i = 0; i < list.length; i++) {
      final isMatch =
          loc.isGps ? list[i].isGps : (!list[i].isGps && list[i].pcode == loc.pcode);
      list[i] = list[i].copyWith(isCurrent: isMatch);
    }
    await _writeSavedLocations(list);
    await _syncMirrorFromList(list);
  }

  /// Removes a custom entry by pcode. Never removes the GPS entry. If the
  /// removed entry was current, falls back to the GPS entry (or the first
  /// remaining entry) as current.
  Future<void> removeLocation(String pcode) async {
    final list = await _readSavedLocations();
    final removed = list.firstWhereOrNull((l) => !l.isGps && l.pcode == pcode);
    if (removed == null) return;

    list.removeWhere((l) => !l.isGps && l.pcode == pcode);
    if (removed.isCurrent && list.isNotEmpty) {
      final gpsIdx = list.indexWhere((l) => l.isGps);
      if (gpsIdx != -1) {
        list[gpsIdx] = list[gpsIdx].copyWith(isCurrent: true);
      } else {
        list[0] = list[0].copyWith(isCurrent: true);
      }
    }
    await _writeSavedLocations(list);
    await _syncMirrorFromList(list);
  }
}
