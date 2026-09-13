import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domen/controllers/pest_advisory_controller.dart';

/// Pest Advisory screen — placeholder scaffold. Build UI from the Figma
/// "Pest Advisory" frame, reading state from [PestAdvisoryController].
class PestAdvisoryPage extends StatelessWidget {
  const PestAdvisoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PestAdvisoryController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Pest Advisory')),
      body: Center(
        child: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicator()
              : const Text('Pest Advisory — TODO from Figma'),
        ),
      ),
    );
  }
}
