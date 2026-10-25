import 'package:get/get.dart';

import '../../../../core/services/advisory_stages_service.dart';
import '../../../../models/advisory_item_model.dart';
import '../../../../models/advisory_stage_model.dart';

/// "Select a stage for advisory" screen state — the picked [item] (and its
/// [categoryId]) came from [AdvisoryItemsController]; this controller loads
/// that item's stage list fresh every time (no cache, like its sibling).
class AdvisoryStagesController extends GetxController {
  AdvisoryStagesController({
    required this.categoryId,
    required this.item,
    this.categoryLabel,
    this.stageCategory,
  });

  final int categoryId;
  final AdvisoryItemModel item;
  final String? categoryLabel;

  /// `'disease'` for the Crop Disease Early Warning flow; `null` fetches
  /// the item's advisory stages.
  final String? stageCategory;

  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final stages = <AdvisoryStageModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStages();
  }

  Future<void> loadStages() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await AdvisoryStagesService()
        .fetch(categoryId, item.id, stageCategory: stageCategory);
    if (result.stages != null) {
      stages.assignAll(result.stages!);
    } else {
      stages.clear();
      errorMessage.value = result.error;
    }
    isLoading.value = false;
  }
}
