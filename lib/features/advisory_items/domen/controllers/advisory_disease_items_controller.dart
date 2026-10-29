import 'package:get/get.dart';

import '../../../../core/services/advisory_categories_service.dart';
import '../../../../core/services/advisory_items_service.dart';
import '../../../../models/advisory_category_model.dart';
import '../../../../models/advisory_item_model.dart';

/// "Crop Disease Early Warning" screen state — unlike the other advisory
/// categories (which browse their own item list straight away), this one
/// lets the user switch between the *other* categories (crop, livestock,
/// aquaculture, ...) via a dropdown and browses that category's item list
/// underneath. [diseaseCategoryId] is excluded from the dropdown since it
/// has no items of its own.
class AdvisoryDiseaseItemsController extends GetxController {
  AdvisoryDiseaseItemsController({required this.diseaseCategoryId, this.categoryLabel});

  final int diseaseCategoryId;
  final String? categoryLabel;

  final categories = <AdvisoryCategoryModel>[].obs;
  final categoriesLoading = false.obs;
  final categoriesLoadFailed = false.obs;
  final selectedCategory = Rxn<AdvisoryCategoryModel>();

  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final items = <AdvisoryItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    categoriesLoading.value = true;
    categoriesLoadFailed.value = false;

    final cached = AdvisoryCategoriesService().cached;
    if (cached != null) _applyCategories(cached);

    final fresh = await AdvisoryCategoriesService().fetch();
    if (fresh != null) {
      _applyCategories(fresh);
    } else if (cached == null) {
      categoriesLoadFailed.value = true;
    }
    categoriesLoading.value = false;
  }

  void _applyCategories(List<AdvisoryCategoryModel> all) {
    final browsable = all.where((c) => c.id != diseaseCategoryId).toList();
    categories.assignAll(browsable);

    final current = selectedCategory.value;
    final stillValid = current != null && browsable.any((c) => c.id == current.id);
    if (!stillValid && browsable.isNotEmpty) {
      onCategoryChanged(browsable.first);
    }
  }

  /// Pull-to-refresh: reloads the category dropdown and the currently
  /// selected category's items.
  Future<void> reload() async {
    await loadCategories();
    final current = selectedCategory.value;
    if (current != null) await onCategoryChanged(current);
  }

  Future<void> onCategoryChanged(AdvisoryCategoryModel? category) async {
    selectedCategory.value = category;
    items.clear();
    errorMessage.value = null;
    if (category == null) return;

    isLoading.value = true;
    final result = await AdvisoryItemsService().fetch(category.id);
    if (result.items != null) {
      items.assignAll(result.items!);
    } else {
      errorMessage.value = result.error;
    }
    isLoading.value = false;
  }
}
