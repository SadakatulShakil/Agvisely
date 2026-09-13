import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domen/controllers/livestock_advisory_controller.dart';

/// Livestock Advisory screen — placeholder scaffold. Build UI from the Figma
/// "Livestock Advisory" frame, reading state from [LivestockAdvisoryController].
class LivestockAdvisoryPage extends StatelessWidget {
  const LivestockAdvisoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LivestockAdvisoryController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Livestock Advisory')),
      body: Center(
        child: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicator()
              : const Text('Livestock Advisory — TODO from Figma'),
        ),
      ),
    );
  }
}
