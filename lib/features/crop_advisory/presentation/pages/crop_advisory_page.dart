import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domen/controllers/crop_advisory_controller.dart';

/// Crop Advisory screen — placeholder scaffold. Build UI from the Figma
/// "Crop Advisory" frame, reading state from [CropAdvisoryController].
class CropAdvisoryPage extends StatelessWidget {
  const CropAdvisoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CropAdvisoryController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Advisory')),
      body: Center(
        child: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicator()
              : const Text('Crop Advisory — TODO from Figma'),
        ),
      ),
    );
  }
}
