import 'package:get/get.dart';

import '../../../../models/advisory_item_model.dart';
import '../controllers/advisory_stages_controller.dart';

/// Lazily provisions [AdvisoryStagesController] for the item picked on
/// [AdvisoryItemsPage].
class AdvisoryStagesBinding extends Bindings {
  AdvisoryStagesBinding({
    required this.categoryId,
    required this.item,
    this.categoryLabel,
  });

  final int categoryId;
  final AdvisoryItemModel item;
  final String? categoryLabel;

  @override
  void dependencies() {
    Get.lazyPut<AdvisoryStagesController>(
      () => AdvisoryStagesController(
        categoryId: categoryId,
        item: item,
        categoryLabel: categoryLabel,
      ),
    );
  }
}
