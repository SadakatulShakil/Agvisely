import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../location/data/location_repository.dart';
import '../../../location/domen/binding/select_location_binding.dart';
import '../../../location/presentation/pages/select_location_page.dart';

/// Drives the home shell: bottom-nav selection + top-bar identity.
class HomeController extends GetxController {
  final navIndex = 0.obs;
  final locationName = 'Mirpur DOHS, Dhaka'.obs; // TODO: from location service

  void changeTab(int i) => navIndex.value = i;

  @override
  void onInit() {
    super.onInit();
    _refreshLocationName();
    // TODO: fetch dashboard payload (weather + advisory summaries + my choice)
  }

  void _refreshLocationName() {
    final saved = UserPrefService().locationName;
    if (saved != null && saved.isNotEmpty) locationName.value = saved;
  }

  /// Lets the user change their location any time from Home. The picker
  /// returns the raw UnionRecord (isFirstInstall: false — see
  /// SelectLocationPage) and this resolves + persists it, matching the
  /// same API-backed flow used elsewhere.
  Future<void> openLocationPicker() async {
    final result = await Get.to<UnionRecord>(
      () => SelectLocationPage(isFirstInstall: false),
      binding: SelectLocationBinding(),
    );
    if (result == null) return;

    final isBangla = Get.locale?.languageCode == 'bn';
    final fetched = await UserPrefService().fetchLocationDetailsFromApi(
      lat: result.lat,
      lon: result.lng,
      displayNameFallback: result.name,
      displayNameFallbackBn: result.nameBn,
    );
    if (fetched == null) {
      Get.snackbar('Error', 'Could not save location');
      return;
    }

    await UserPrefService().setFollowGPS(false);
    await UserPrefService().saveSelectedLocation(fetched, isBangla: isBangla);
    _refreshLocationName();
  }
}
