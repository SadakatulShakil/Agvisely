import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/advisory_categories_service.dart';
import '../../../../core/services/fcm_sync_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/user_choices_service.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../models/advisory_category_model.dart';
import '../../../../models/current_weather_model.dart';
import '../../../../models/seven_day_model.dart';
import '../../../../models/user_choice_model.dart';
import '../../../location/data/location_repository.dart';
import '../../../weather/data/seven_day_repository.dart';
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

  final advisoryCategories = <AdvisoryCategoryModel>[].obs;

  final myChoices = <UserChoiceModel>[].obs;

  final todayChart = <ForecastChartPoint>[].obs;
  final todayChartRainUnit = 'mm'.obs;
  final todayChartTempUnit = 'C'.obs;
  final _sevenDayRepository = SevenDayRepository();

  // ── Live weather (condition/icon only — see LiveWeatherModel) ─────────────
  final liveType = ''.obs;
  final liveIcon = ''.obs;
  int _liveReqId = 0;
  int _weatherReqId = 0;

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
    // Cached data renders immediately, before either network call lands —
    // loadWeather/loadMyChoices below refresh it live and leave it as-is
    // (rather than blanking it) if that refresh fails, e.g. offline.
    currentWeather.value = UserPrefService().cachedCurrentWeather;
    final cachedChoices = UserPrefService().cachedMyChoices;
    if (cachedChoices != null) myChoices.assignAll(cachedChoices);
    final cachedChart = UserPrefService().cachedTodayChart;
    if (cachedChart != null) {
      todayChart.assignAll(cachedChart.points);
      todayChartRainUnit.value = cachedChart.rainUnit.replaceAll(":", "");
      todayChartTempUnit.value = cachedChart.tempUnit;
    }
    refreshLocationName();
    loadWeather();
    loadAdvisoryCategories();
    loadTodayChart();
    loadMyChoices();
    unawaited(FcmSyncService().syncFcmToken());
  }

  @override
  void onReady() {
    super.onReady();
    // Consumes a notification tap that arrived while the app was being
    // cold-started from a terminated state (navigator wasn't ready yet when
    // the tap was first detected) — FCM-posted and locally-shown
    // notifications each track this separately.
    FirebaseService().handlePendingFcmNavigation();
    NotificationService().handlePendingNavigation();

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

  /// Cache-first + background refresh for the advisory grid, same pattern
  /// as [ProfessionsService]/[AdvisoryCategoriesService] elsewhere.
  Future<void> loadAdvisoryCategories() async {
    final cached = AdvisoryCategoriesService().cached;
    if (cached != null) advisoryCategories.assignAll(cached);

    final fresh = await AdvisoryCategoriesService().fetch();
    if (fresh != null) advisoryCategories.assignAll(fresh);
  }

  /// The dashboard's "My Choice" carousel — `GET /user-choices`. Fails
  /// silently (leaves [myChoices] as-is, which `onInit` already seeded from
  /// [UserPrefService.cachedMyChoices]) so a flaky network just shows the
  /// last-known list rather than an error banner on the dashboard. A success
  /// persists so the next cold start has it too.
  Future<void> loadMyChoices() async {
    final result = await UserChoicesService().fetch();
    if (result.choices != null) {
      myChoices.assignAll(result.choices!);
      unawaited(UserPrefService().setCachedMyChoices(result.choices!));
    }
  }

  /// Today's 3-hourly chart for the dashboard's forecast preview — same
  /// [SevenDayRepository]/demo JSON the 7-day page uses, just today's slice.
  /// Re-called on every location change (see [onLocationChanged] etc.) and
  /// by SettingsController on a language switch — [SevenDayRepository]'s own
  /// cache is keyed by lat/lon so this always reflects the active location.
  /// Persists so the next cold start has it too.
  Future<void> loadTodayChart() async {
    final days = await _sevenDayRepository.load();
    final today = days.firstWhereOrNull((d) => d.isToday) ??
        (days.isNotEmpty ? days.first : null);
    final chart = today?.chart ?? const <ForecastChartPoint>[];
    final rainUnit = today?.units.rf ?? 'mm';
    final tempUnit = today?.units.temp ?? 'C';
    todayChart.assignAll(chart);
    todayChartRainUnit.value = rainUnit.replaceAll(':', '');
    todayChartTempUnit.value = tempUnit;
    if (chart.isNotEmpty) {
      unawaited(UserPrefService().setCachedTodayChart(
        points: chart,
        rainUnit: rainUnit,
        tempUnit: tempUnit,
      ));
    }
  }

  /// Fetches current-weather for the active saved location's lat/lon.
  /// No-ops silently if no location has been resolved yet. Stale-response
  /// guarded like [fetchLiveWeather] — rapid location switching (saved
  /// locations sheet, GPS auto-refresh) can fire this concurrently, and an
  /// older call landing after a newer one must not overwrite it. A failed
  /// fetch (e.g. offline) leaves [currentWeather] as whatever was already
  /// showing — cached or a previous successful fetch — rather than blanking
  /// the card; a success persists so the next cold start has it too.
  Future<void> loadWeather() async {
    final lat = double.tryParse(UserPrefService().getLat() ?? '');
    final lon = double.tryParse(UserPrefService().getLon() ?? '');
    if (lat == null || lon == null) return;

    fetchLiveWeather(lat, lon); // fire-and-forget — never blocks the forecast

    final myId = ++_weatherReqId;
    isLoadingWeather.value = true;
    try {
      final weather = await _weatherRepository.fetchCurrentWeather(
        lat: lat,
        lon: lon,
      );
      if (myId != _weatherReqId) return; // stale — a newer call is active
      if (weather != null) {
        currentWeather.value = weather;
        unawaited(UserPrefService().setCachedCurrentWeather(weather));
      }
    } finally {
      if (myId == _weatherReqId) isLoadingWeather.value = false;
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
  /// locations sheet) — refreshes the displayed name, weather, and today's
  /// chart for the newly-active lat/lon.
  Future<void> onLocationChanged() async {
    refreshLocationName();
    await loadWeather();
    loadTodayChart();
  }

  /// Pull-to-refresh entry point for the home dashboard.
  Future<void> refreshAll() async {
    refreshLocationName();
    await loadWeather();
    loadTodayChart();
    loadMyChoices();
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
        loadTodayChart();
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
        loadTodayChart();
      }
    } finally {
      _isSyncing.value = false;
    }
  }

  /// App-resume hook. GPS active → check whether a refresh is due; custom
  /// location active → silently refresh just the GPS list entry so it's
  /// current if the user switches back, without touching the active weather.
  Future<void> _onResume() async {
    unawaited(ApiClient().ensureValidToken()); // proactive session refresh
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
