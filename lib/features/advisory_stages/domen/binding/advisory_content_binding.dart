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
    this.stageCategory,
  });

  final int categoryId;
  final String? categoryLabel;
  final AdvisoryItemModel item;
  final AdvisoryStageModel stage;

  /// `true` for the Pest Advisory flow — only the IPM advisory section is
  /// shown, see [AdvisoryContentModel.fromRules].
  final bool ipmOnly;

  /// `'disease'` for the Crop Disease Early Warning flow — the content page
  /// renders the backend's HTML as-is only for this flow; every other flow
  /// keeps the plain-text bullet rendering.
  final String? stageCategory;

  @override
  void dependencies() {
    Get.lazyPut<AdvisoryContentController>(
      () => AdvisoryContentController(
        categoryId: categoryId,
        categoryLabel: categoryLabel,
        item: item,
        stage: stage,
        ipmOnly: ipmOnly,
        stageCategory: stageCategory,
      ),
    );
  }
}
