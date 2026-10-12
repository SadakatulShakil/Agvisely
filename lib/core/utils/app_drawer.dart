import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme_colors.dart';
import '../../features/advisory_items/domen/binding/advisory_items_binding.dart';
import '../../features/advisory_items/presentation/pages/advisory_items_page.dart';
import '../../features/weather/domen/binding/seven_day_binding.dart';
import '../../features/weather/presentation/pages/seven_day_page.dart';
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
                () => Get.to(() => const SevenDayPage(), binding: SevenDayBinding())),
            // The drawer has no live AdvisoryCategoryModel in scope (unlike
            // the home grid, which passes the real tapped category through)
            // — these fallback ids mirror the backend's known category
            // ordering: 1=crop, 2=livestock, 3=aquaculture, 4=disease.
            _item(Icons.grass_outlined, 'advisory.crop'.tr,
                () => _openAdvisoryShortcut(categoryId: 1, categoryLabel: 'advisory.crop'.tr)),
            _item(Icons.coronavirus_outlined, 'advisory.disease'.tr,
                () => _openAdvisoryShortcut(categoryId: 4, categoryLabel: 'advisory.disease'.tr)),
            _item(Icons.pets_outlined, 'advisory.livestock'.tr,
                () => _openAdvisoryShortcut(categoryId: 2, categoryLabel: 'advisory.livestock'.tr)),
            _item(Icons.set_meal_outlined, 'advisory.aquaculture'.tr,
                () => _openAdvisoryShortcut(categoryId: 3, categoryLabel: 'advisory.aquaculture'.tr)),
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

  void _openAdvisoryShortcut({required int categoryId, required String categoryLabel}) {
    Get.to(
      () => const AdvisoryItemsPage(),
      binding: AdvisoryItemsBinding(categoryId: categoryId, categoryLabel: categoryLabel),
    );
  }
}
