import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domen/controllers/weather_controller.dart';

/// Weather Forecast screen — placeholder scaffold. Build UI from the Figma
/// "Weather Forecast" frame, reading state from [WeatherController].
class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WeatherController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Forecast')),
      body: Center(
        child: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicator()
              : const Text('Weather Forecast — TODO from Figma'),
        ),
      ),
    );
  }
}
