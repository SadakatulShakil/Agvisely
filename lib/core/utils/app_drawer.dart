import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme_colors.dart';
import '../../features/crop_advisory/domen/binding/crop_advisory_binding.dart';
import '../../features/crop_advisory/presentation/pages/crop_advisory_page.dart';
import '../../features/disease_advisory/domen/binding/disease_advisory_binding.dart';
import '../../features/disease_advisory/presentation/pages/disease_advisory_page.dart';
import '../../features/livestock_advisory/domen/binding/livestock_advisory_binding.dart';
import '../../features/livestock_advisory/presentation/pages/livestock_advisory_page.dart';
import '../../features/aquaculture_advisory/domen/binding/aquaculture_advisory_binding.dart';
import '../../features/aquaculture_advisory/presentation/pages/aquaculture_advisory_page.dart';
import '../../features/weather/domen/binding/weather_binding.dart';
import '../../features/weather/presentation/pages/weather_page.dart';
import '../../features/notifications/presentation/pages/notification_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

/// Slide-out menu. Mirror the Figma "Menu" frame — module shortcuts,
/// settings, language, about, logout.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Agvisely',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _item(Icons.cloud_outlined, 'advisory.weather'.tr,
                () => Get.to(() => const WeatherPage(), binding: WeatherBinding())),
            _item(Icons.grass_outlined, 'advisory.crop'.tr,
                () => Get.to(() => const CropAdvisoryPage(), binding: CropAdvisoryBinding())),
            _item(Icons.coronavirus_outlined, 'advisory.disease'.tr,
                () => Get.to(() => const DiseaseAdvisoryPage(), binding: DiseaseAdvisoryBinding())),
            _item(Icons.pets_outlined, 'advisory.livestock'.tr,
                () => Get.to(() => const LivestockAdvisoryPage(), binding: LivestockAdvisoryBinding())),
            _item(Icons.set_meal_outlined, 'advisory.aquaculture'.tr,
                () => Get.to(() => const AquacultureAdvisoryPage(), binding: AquacultureAdvisoryBinding())),
            const Divider(),
            _item(Icons.notifications_none, 'common.notifications'.tr,
                () => Get.to(() => const NotificationPage())),
            _item(Icons.settings_outlined, 'common.settings'.tr,
                () => Get.to(() => const SettingsPage())),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, VoidCallback onTap) => ListTile(
        leading: Icon(icon, color: AppColors.primaryDark),
        title: Text(label),
        onTap: () {
          Get.back(); // close drawer
          onTap();
        },
      );
}
