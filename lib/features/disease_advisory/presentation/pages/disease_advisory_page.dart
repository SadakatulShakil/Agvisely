import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domen/controllers/disease_advisory_controller.dart';

/// Disease Advisory screen — placeholder scaffold. Build UI from the Figma
/// "Disease Advisory" frame, reading state from [DiseaseAdvisoryController].
class DiseaseAdvisoryPage extends StatelessWidget {
  const DiseaseAdvisoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiseaseAdvisoryController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Disease Advisory')),
      body: Center(
        child: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicator()
              : const Text('Disease Advisory — TODO from Figma'),
        ),
      ),
    );
  }
}
