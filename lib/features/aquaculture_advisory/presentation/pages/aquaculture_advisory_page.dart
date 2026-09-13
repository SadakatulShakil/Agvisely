import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domen/controllers/aquaculture_advisory_controller.dart';

/// Aquaculture Advisory screen — placeholder scaffold. Build UI from the Figma
/// "Aquaculture Advisory" frame, reading state from [AquacultureAdvisoryController].
class AquacultureAdvisoryPage extends StatelessWidget {
  const AquacultureAdvisoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AquacultureAdvisoryController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Aquaculture Advisory')),
      body: Center(
        child: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicator()
              : const Text('Aquaculture Advisory — TODO from Figma'),
        ),
      ),
    );
  }
}
