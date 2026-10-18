import 'package:get/get.dart';
import '../controllers/advisory_disease_items_controller.dart';

/// Lazily provisions [AdvisoryDiseaseItemsController] for the "Crop Disease
/// Early Warning" category. [categoryId] must be that category's real id
/// from `GET /advisory/categories` so it can be excluded from its own
/// category-switcher dropdown.
class AdvisoryDiseaseItemsBinding extends Bindings {
  AdvisoryDiseaseItemsBinding({required this.categoryId, this.categoryLabel});

  final int categoryId;
  final String? categoryLabel;

  @override
  void dependencies() {
    Get.lazyPut<AdvisoryDiseaseItemsController>(
      () => AdvisoryDiseaseItemsController(
        diseaseCategoryId: categoryId,
        categoryLabel: categoryLabel,
      ),
    );
  }
}
