import 'package:get/get.dart';
import '../controllers/crop_advisory_controller.dart';

/// Lazily provisions [CropAdvisoryController] when the Crop Advisory route opens.
class CropAdvisoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CropAdvisoryController>(() => CropAdvisoryController());
  }
}
