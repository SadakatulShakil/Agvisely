import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../models/current_weather_model.dart';
import '../../../location/data/location_repository.dart';
import '../../../weather/data/weather_repository.dart';
import '../../presentation/widgets/saved_locations_sheet.dart';

/// Drives the home shell: bottom-nav selection + top-bar identity.
class HomeController extends GetxController with WidgetsBindingObserver {
  final navIndex = 0.obs;
  final locationName = 'Mirpur DOHS, Dhaka'.obs; // TODO: from location service

  /// True while a newly-picked custom location is being resolved via the
  /// API in the background — drives the small loader on the weather card.
  final isResolvingLocation = false.obs;

  final currentWeather = Rxn<CurrentWeatherModel>();
  final isLoadingWeather = false.obs;
  final _weatherRepository = WeatherRepository();

  // ── Live weather (condition/icon only — see LiveWeatherModel) ─────────────
  final liveType = ''.obs;
  final liveIcon = ''.obs;
  int _liveReqId = 0;

  // ── GPS auto-refresh tracking (mirrors BMD-Abohawa's HomeController) ──────
  /// Last time we successfully fetched GPS — null means never this session.
  DateTime? _lastGpsFetchTime;
  double? _lastLat;
  double? _lastLon;
  final _isSyncing = false.obs;

  /// Minimum time between automatic GPS refreshes on resume.
  static const Duration _gpsRefreshInterval = Duration(minutes: 30);

  /// Minimum distance (meters) moved before forcing a refresh within the
  /// time window.
  static const double _gpsRefreshDistanceMeters = 5000;

  void changeTab(int i) => navIndex.value = i;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    refreshLocationName();
    loadWeather();
    // TODO: fetch dashboard payload (advisory summaries + my choice)
  }

  @override
  void onReady() {
    super.onReady();
    // Cached/live data already on screen → don't compete with initial
    // render. Nothing on screen yet → sync almost immediately so the
    // first forecast loads fast instead of sitting on the empty state.
    final coldNoData = currentWeather.value == null;
    Future.delayed(Duration(seconds: coldNoData ? 1 : 3), _autoSyncGps);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onResume();
  }

  /// Recomputes the displayed name from the actual current [SavedLocation]
  /// (not the flat cached pref string, which is baked in whatever language
  /// was active when it was written) so it reflects the language that's
  /// active right now — including right after a language toggle.
  Future<void> refreshLocationName() async {
    final list = await UserPrefService().getSavedLocations();
    final current = list.firstWhereOrNull((l) => l.isCurrent);
    if (current != null) {
      locationName.value = current.displayName(Get.locale?.languageCode == 'bn');
      return;
    }
    final saved = UserPrefService().locationName;
    if (saved != null && saved.isNotEmpty) locationName.value = saved;
  }

  /// Fetches current-weather for the active saved location's lat/lon.
  /// No-ops silently if no location has been resolved yet.
  Future<void> loadWeather() async {
    final lat = double.tryParse(UserPrefService().getLat() ?? '');
    final lon = double.tryParse(UserPrefService().getLon() ?? '');
    if (lat == null || lon == null) return;

    fetchLiveWeather(lat, lon); // fire-and-forget — never blocks the forecast

    isLoadingWeather.value = true;
    try {
      currentWeather.value = await _weatherRepository.fetchCurrentWeather(
        lat: lat,
        lon: lon,
      );
    } finally {
      isLoadingWeather.value = false;
    }
  }

  /// Nearest-station condition/icon — overrides the forecast's per-field
  /// when non-empty. Stale-response guarded: only the most recent call for
  /// this controller's lifetime is allowed to write `liveType`/`liveIcon`.
  Future<void> fetchLiveWeather(double lat, double lon) async {
    final myId = ++_liveReqId;
    try {
      final live = await _weatherRepository
          .getLiveWeather(lat: lat, lon: lon)
          .timeout(const Duration(seconds: 5));
      if (myId != _liveReqId) return; // stale — a newer call is active
      liveType.value = live.type;
      liveIcon.value = live.icon;
    } catch (_) {
      // keep previous values on failure
    }
  }

  /// Called after the active location changes (switched in the saved-
  /// locations sheet) — refreshes both the displayed name and the weather
  /// for the newly-active lat/lon.
  Future<void> onLocationChanged() async {
    refreshLocationName();
    await loadWeather();
  }

  /// Pull-to-refresh entry point for the home dashboard.
  Future<void> refreshAll() async {
    refreshLocationName();
    await loadWeather();
    // TODO: advisory summaries once that endpoint exists
  }

  /// Opens the saved-locations sheet — switch, delete, or add a location.
  Future<void> openSavedLocationsSheet() async {
    final context = Get.context;
    if (context == null) return;
    await SavedLocationsSheet.show(context);
  }

  /// Resolves a picked union through the API and adds it as a new saved
  /// location. Runs in the background (the sheet closes as soon as the
  /// union is picked, before this completes) — [isResolvingLocation] drives
  /// a small loader on the weather card while the network call is in flight.
  Future<void> addCustomLocation(UnionRecord item) async {
    isResolvingLocation.value = true;
    try {
      final loc = await UserPrefService().fetchLocationDetailsFromApi(
        lat: item.lat,
        lon: item.lng,
        displayNameFallback:
            item.upazila.isEmpty ? item.name : '${item.name}, ${item.upazila}',
        displayNameFallbackBn:
            item.upazilaBn.isEmpty
                ? item.nameBn
                : '${item.nameBn}, ${item.upazilaBn}',
        pcodeOverride: item.pcode,
      );
      if (loc != null) {
        await UserPrefService().addOrUpdateCustom(loc, makeCurrent: true);
        refreshLocationName();
        loadWeather();
      }
    } finally {
      isResolvingLocation.value = false;
    }
  }

  /// Silent GPS sync — called once on cold start (via [onReady]) and again
  /// whenever [_refreshIfNeeded] decides a periodic refresh is due. Records
  /// fetch time/position for the next threshold check. Only reloads the
  /// weather/location-name display when GPS is the active location; a
  /// custom-picked location is never overridden (its GPS list entry still
  /// gets refreshed silently, via [LocationService.getLocation] itself).
  Future<void> _autoSyncGps() async {
    if (_isSyncing.value) return;
    _isSyncing.value = true;
    try {
      final success = await LocationService().getLocation(
        onSettingsOpened: () {},
        timeoutSeconds: 10,
        isSilent: true,
      );
      if (!success) return;

      _lastGpsFetchTime = DateTime.now();
      _lastLat = double.tryParse(UserPrefService().lat ?? '');
      _lastLon = double.tryParse(UserPrefService().lon ?? '');

      if (UserPrefService().isFollowingGPS) {
        refreshLocationName();
        await loadWeather();
      }
    } finally {
      _isSyncing.value = false;
    }
  }

  /// App-resume hook. GPS active → check whether a refresh is due; custom
  /// location active → silently refresh just the GPS list entry so it's
  /// current if the user switches back, without touching the active weather.
  Future<void> _onResume() async {
    if (UserPrefService().isFollowingGPS) {
      await _refreshIfNeeded();
    } else {
      await LocationService().getLocation(onSettingsOpened: () {}, isSilent: true);
    }
  }

  /// Only ever called while GPS is the active location. Refreshes when
  /// either threshold is crossed: 30+ minutes since the last fetch, or the
  /// device has moved 5+ km since then.
  Future<void> _refreshIfNeeded() async {
    final now = DateTime.now();
    final lastFetch = _lastGpsFetchTime;
    if (lastFetch == null || now.difference(lastFetch) >= _gpsRefreshInterval) {
      await _autoSyncGps();
      return;
    }

    if (_lastLat != null && _lastLon != null) {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
        ).timeout(const Duration(seconds: 5));

        final distanceMoved = Geolocator.distanceBetween(
          _lastLat!,
          _lastLon!,
          position.latitude,
          position.longitude,
        );
        if (distanceMoved >= _gpsRefreshDistanceMeters) {
          await _autoSyncGps();
        }
      } catch (_) {
        // GPS fix failed (timeout, disabled, etc) — skip; the time
        // threshold will catch it on the next resume.
      }
    }
  }
}
