import 'package:get/get.dart';
import '../controllers/weather_controller.dart';

/// Lazily provisions [WeatherController] when the Weather Forecast route opens.
class WeatherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeatherController>(() => WeatherController());
  }
}
