import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';

/// Drives the home shell: bottom-nav selection + top-bar identity.
class HomeController extends GetxController {
  final navIndex = 0.obs;
  final locationName = 'Mirpur DOHS, Dhaka'.obs; // TODO: from location service

  void changeTab(int i) => navIndex.value = i;

  @override
  void onInit() {
    super.onInit();
    final saved = UserPrefService().locationName;
    if (saved != null && saved.isNotEmpty) locationName.value = saved;
    // TODO: fetch dashboard payload (weather + advisory summaries + my choice)
  }
}
