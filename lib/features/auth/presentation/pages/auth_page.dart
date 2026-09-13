import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domen/controllers/auth_controller.dart';

/// Sign In screen — placeholder scaffold. Build UI from the Figma
/// "Sign In" frame, reading state from [AuthController].
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicator()
              : const Text('Sign In — TODO from Figma'),
        ),
      ),
    );
  }
}
