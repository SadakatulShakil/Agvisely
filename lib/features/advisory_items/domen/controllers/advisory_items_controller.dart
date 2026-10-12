import 'package:get/get.dart';

import '../../../../core/services/advisory_items_service.dart';
import '../../../../models/advisory_item_model.dart';

/// Generic "select an item for advisory" screen state — every advisory
/// category (crop, livestock, aquaculture, disease, ...) routes through
/// this one controller with its own [categoryId]/[categoryLabel] from the
/// live `GET /advisory/categories` response, so a category added on the
/// backend shows up and works without a new Flutter page.
class AdvisoryItemsController extends GetxController {
  AdvisoryItemsController({required this.categoryId, this.categoryLabel});

  final int categoryId;
  final String? categoryLabel;

  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final items = <AdvisoryItemModel>[].obs;
  final selectedIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  /// Always hits the network — no cache, so a retry after a failure (or a
  /// fresh visit) always reflects current server state.
  Future<void> loadItems() async {
    isLoading.value = true;
    errorMessage.value = null;
    selectedIndex.value = -1;

    final result = await AdvisoryItemsService().fetch(categoryId);
    if (result.items != null) {
      items.assignAll(result.items!);
    } else {
      items.clear();
      errorMessage.value = result.error;
    }
    isLoading.value = false;
  }

  void select(int index) => selectedIndex.value = index;
}
