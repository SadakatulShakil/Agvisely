import 'package:get/get.dart';
import '../controllers/pest_advisory_controller.dart';

/// Provisions the permanent [PestAdvisoryController] when the Pest Advisory
/// route opens. Unused while the page lives as a bottom-nav tab (the page
/// puts its own permanent controller directly, like the other tabs) — kept
/// for if/when this is ever pushed as its own route instead.
class PestAdvisoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PestAdvisoryController>()) {
      Get.put(PestAdvisoryController(), permanent: true);
    }
  }
}
