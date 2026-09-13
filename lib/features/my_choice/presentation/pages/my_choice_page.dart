import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domen/controllers/my_choice_controller.dart';

/// My Choice screen — placeholder scaffold. Build UI from the Figma
/// "My Choice" frame, reading state from [MyChoiceController].
class MyChoicePage extends StatelessWidget {
  const MyChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyChoiceController>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Choice')),
      body: Center(
        child: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicator()
              : const Text('My Choice — TODO from Figma'),
        ),
      ),
    );
  }
}
