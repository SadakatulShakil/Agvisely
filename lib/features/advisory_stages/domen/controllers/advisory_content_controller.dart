import 'package:get/get.dart';

import '../../../../core/services/advisory_content_service.dart';
import '../../../../models/advisory_content_model.dart';
import '../../../../models/advisory_item_model.dart';
import '../../../../models/advisory_stage_model.dart';

/// "See The Advisory" screen state — the picked [item] and [stage] came from
/// [AdvisoryStagesController]; this controller loads that stage's advisory
/// content fresh every time (no cache, like its siblings).
class AdvisoryContentController extends GetxController {
  AdvisoryContentController({
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

  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final content = Rxn<AdvisoryContentModel>();

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  Future<void> loadContent() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await AdvisoryContentService()
        .fetch(categoryId, item.id, stage.id, ipmOnly: ipmOnly);
    if (result.content != null) {
      content.value = result.content;
    } else {
      content.value = null;
      errorMessage.value = result.error;
    }
    isLoading.value = false;
  }
}
