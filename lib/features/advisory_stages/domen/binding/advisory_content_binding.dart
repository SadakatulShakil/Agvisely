import 'package:get/get.dart';

import '../../../../models/advisory_item_model.dart';
import '../../../../models/advisory_stage_model.dart';
import '../controllers/advisory_content_controller.dart';

/// Lazily provisions [AdvisoryContentController] for the stage picked on
/// [AdvisoryStagesPage].
class AdvisoryContentBinding extends Bindings {
  AdvisoryContentBinding({
    required this.categoryId,
    required this.categoryLabel,
    required this.item,
    required this.stage,
    this.ipmOnly = false,
  });

  final int categoryId;
  final String? categoryLabel;
  final AdvisoryItemModel item;
  final AdvisoryStageModel stage;

  /// `true` for the Pest Advisory flow — only the IPM advisory section is
  /// shown, see [AdvisoryContentModel.fromRules].
  final bool ipmOnly;

  @override
  void dependencies() {
    Get.lazyPut<AdvisoryContentController>(
      () => AdvisoryContentController(
        categoryId: categoryId,
        categoryLabel: categoryLabel,
        item: item,
        stage: stage,
        ipmOnly: ipmOnly,
      ),
    );
  }
}
