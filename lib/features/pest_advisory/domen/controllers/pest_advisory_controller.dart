import 'package:get/get.dart';

import '../../../../core/services/advisory_items_service.dart';
import '../../../../models/advisory_item_model.dart';

/// Pest Advisory tab — pest attacks only crops, so this always browses the
/// Crop category's item list (mirrors [AdvisoryItemsController], fixed to
/// [cropCategoryId] instead of taking a category from a route argument,
/// since this is a permanent bottom-nav tab rather than a pushed page).
class PestAdvisoryController extends GetxController {
  static const cropCategoryId = 1;

  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final items = <AdvisoryItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await AdvisoryItemsService().fetch(cropCategoryId);
    if (result.items != null) {
      items.assignAll(result.items!);
    } else {
      items.clear();
      errorMessage.value = result.error;
    }
    isLoading.value = false;
  }
}
