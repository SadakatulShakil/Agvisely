import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../presentation/widgets/saved_locations_sheet.dart';

/// Drives the home shell: bottom-nav selection + top-bar identity.
class HomeController extends GetxController {
  final navIndex = 0.obs;
  final locationName = 'Mirpur DOHS, Dhaka'.obs; // TODO: from location service

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
}
