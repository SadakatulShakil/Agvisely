import 'package:get/get.dart';
import '../controllers/pest_advisory_controller.dart';

/// Lazily provisions [PestAdvisoryController] when the Pest Advisory route opens.
class PestAdvisoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PestAdvisoryController>(() => PestAdvisoryController());
  }
}
