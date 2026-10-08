import 'package:get/get.dart';

import '../controllers/seven_day_controller.dart';

/// Lazily provisions [SevenDayController] when the 7-day forecast route opens.
class SevenDayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SevenDayController>(() => SevenDayController());
  }
}
