import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../home/domen/controllers/home_controller.dart';

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
    Get.updateLocale(Locale(code));
    // Condition text/units are server-localized, not client-convertible —
    // refetch so they match the new Accept-Language.
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadWeather();
    }
  }
}
