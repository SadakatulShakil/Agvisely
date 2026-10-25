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
    this.stageCategory,
    this.ipmOnly = false,
  });

  final int categoryId;
  final AdvisoryItemModel item;
  final String? categoryLabel;

  /// `'disease'` for the Crop Disease Early Warning flow; `null` fetches
  /// the item's advisory stages.
  final String? stageCategory;

  /// `true` for the Pest Advisory flow — carried through to
  /// [AdvisoryContentBinding] so the content page shows IPM advice only.
  final bool ipmOnly;

  @override
  void dependencies() {
    Get.lazyPut<AdvisoryStagesController>(
      () => AdvisoryStagesController(
        categoryId: categoryId,
        item: item,
        categoryLabel: categoryLabel,
        stageCategory: stageCategory,
        ipmOnly: ipmOnly,
      ),
    );
  }
}
