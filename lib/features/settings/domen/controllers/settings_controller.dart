import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';

/// Language + preferences state for the Settings screen.
class SettingsController extends GetxController {
  final language = 'bn'.obs; // 'en' | 'bn'

  @override
  void onInit() {
    super.onInit();
    language.value = UserPrefService().appLanguage;
  }

  Future<void> setLanguage(String code) async {
    language.value = code;
    await UserPrefService().setAppLanguage(code);
    Get.forceAppUpdate(); // rebuild strings across the app
  }
}
