import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../../models/current_weather_model.dart';
import '../../../location/data/location_repository.dart';
import '../../../weather/data/weather_repository.dart';
import '../../presentation/widgets/saved_locations_sheet.dart';

/// Drives the home shell: bottom-nav selection + top-bar identity.
class HomeController extends GetxController {
  final navIndex = 0.obs;
  final locationName = 'Mirpur DOHS, Dhaka'.obs; // TODO: from location service

  /// True while a newly-picked custom location is being resolved via the
  /// API in the background — drives the small loader on the weather card.
  final isResolvingLocation = false.obs;

  final currentWeather = Rxn<CurrentWeatherModel>();
  final isLoadingWeather = false.obs;
  final _weatherRepository = WeatherRepository();

  void changeTab(int i) => navIndex.value = i;

  @override
  void onInit() {
    super.onInit();
    refreshLocationName();
    loadWeather();
    // TODO: fetch dashboard payload (advisory summaries + my choice)
  }

  void refreshLocationName() {
    final saved = UserPrefService().locationName;
    if (saved != null && saved.isNotEmpty) locationName.value = saved;
  }

  /// Fetches current-weather for the active saved location's lat/lon.
  /// No-ops silently if no location has been resolved yet.
  Future<void> loadWeather() async {
    final lat = double.tryParse(UserPrefService().getLat() ?? '');
    final lon = double.tryParse(UserPrefService().getLon() ?? '');
    if (lat == null || lon == null) return;

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
}
