import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../location/data/location_repository.dart';
import '../../presentation/widgets/saved_locations_sheet.dart';

/// Drives the home shell: bottom-nav selection + top-bar identity.
class HomeController extends GetxController {
  final navIndex = 0.obs;
  final locationName = 'Mirpur DOHS, Dhaka'.obs; // TODO: from location service

  /// True while a newly-picked custom location is being resolved via the
  /// API in the background — drives the small loader on the weather card.
  final isResolvingLocation = false.obs;

  void changeTab(int i) => navIndex.value = i;

  @override
  void onInit() {
    super.onInit();
    refreshLocationName();
    // TODO: fetch dashboard payload (weather + advisory summaries + my choice)
  }

  void refreshLocationName() {
    final saved = UserPrefService().locationName;
    if (saved != null && saved.isNotEmpty) locationName.value = saved;
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
        displayNameFallbackBn: item.upazilaBn.isEmpty
            ? item.nameBn
            : '${item.nameBn}, ${item.upazilaBn}',
        pcodeOverride: item.pcode,
      );
      if (loc != null) {
        await UserPrefService().addOrUpdateCustom(loc, makeCurrent: true);
        refreshLocationName();
      }
    } finally {
      isResolvingLocation.value = false;
    }
  }
}
