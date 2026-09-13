import 'package:get/get.dart';

import '../controllers/location_pick_controller.dart';

class SelectLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectLocationController>(
      () => SelectLocationController(),
    );
  }
}
