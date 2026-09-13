import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/localization_string.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../domen/controllers/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SettingsController());
    final theme = Get.find<ThemeController>();
    return Scaffold(
      appBar: AppBar(title: Text(tr('common.settings'))),
      body: ListView(
        children: [
          Obx(() => SwitchListTile(
                title: Text(tr('common.language') + ' (বাংলা)'),
                value: c.language.value == 'bn',
                onChanged: (bn) => c.setLanguage(bn ? 'bn' : 'en'),
              )),
          Obx(() => SwitchListTile(
                title: const Text('Dark mode'),
                value: theme.isDark,
                onChanged: theme.toggleTheme,
              )),
        ],
      ),
    );
  }
}
