import 'package:get/get.dart';
import '../controllers/aquaculture_advisory_controller.dart';

/// Lazily provisions [AquacultureAdvisoryController] when the Aquaculture Advisory route opens.
class AquacultureAdvisoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AquacultureAdvisoryController>(() => AquacultureAdvisoryController());
  }
}
