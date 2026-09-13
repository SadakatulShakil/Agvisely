import 'package:get/get.dart';
import '../controllers/livestock_advisory_controller.dart';

/// Lazily provisions [LivestockAdvisoryController] when the Livestock Advisory route opens.
class LivestockAdvisoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LivestockAdvisoryController>(() => LivestockAdvisoryController());
  }
}
