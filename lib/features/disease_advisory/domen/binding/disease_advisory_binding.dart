import 'package:get/get.dart';
import '../controllers/disease_advisory_controller.dart';

/// Lazily provisions [DiseaseAdvisoryController] when the Disease Advisory route opens.
class DiseaseAdvisoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiseaseAdvisoryController>(() => DiseaseAdvisoryController());
  }
}
