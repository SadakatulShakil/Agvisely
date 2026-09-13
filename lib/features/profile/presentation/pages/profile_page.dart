import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domen/controllers/profile_controller.dart';

/// Profile screen — placeholder scaffold. Build UI from the Figma
/// "Profile" frame, reading state from [ProfileController].
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicator()
              : const Text('Profile — TODO from Figma'),
        ),
      ),
    );
  }
}
