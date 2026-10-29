import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../home/domen/controllers/home_controller.dart';
import '../../../weather/domen/controllers/seven_day_controller.dart';

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
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      // The live condition/icon override (HomeController.fetchLiveWeather)
      // was fetched under the OLD language and silently keeps its previous
      // value if the refetch below fails or times out — clear it now so a
      // flaky retry can't leave stale-language text on screen; loadWeather()
      // falls back to the forecast's own (already correctly re-localized)
      // condition until a fresh live result lands.
      home.liveType.value = '';
      home.liveIcon.value = '';
      // Condition text/units are server-localized, not client-convertible —
      // refetch so they match the new Accept-Language.
      home.loadWeather();
      // The displayed location name is derived from the SavedLocation's
      // name/nameBn, not re-read automatically — recompute for the new locale.
      home.refreshLocationName();
      home.loadTodayChart();
    }
    if (Get.isRegistered<SevenDayController>()) {
      // Same reasoning — the demo JSON is split per-language, and the real
      // forecast endpoint is server-localized too, so re-load rather than
      // trying to client-convert.
      Get.find<SevenDayController>().load();
    }
  }
}
