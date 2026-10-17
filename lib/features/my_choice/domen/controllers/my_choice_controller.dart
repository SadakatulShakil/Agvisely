import 'package:get/get.dart';

import '../../../../core/services/advisory_categories_service.dart';
import '../../../../core/services/advisory_items_service.dart';
import '../../../../core/services/user_choices_service.dart';
import '../../../../models/advisory_category_model.dart';
import '../../../../models/advisory_item_model.dart';
import '../../../../models/user_choice_model.dart';

/// My Choice — screen state. [choices] backs the page's grid; the rest
/// backs the "Add new" sheet's category → item dropdowns.
class MyChoiceController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final choices = <UserChoiceModel>[].obs;

  // ── "Add new" sheet state ────────────────────────────────────────────────
  final categories = <AdvisoryCategoryModel>[].obs;
  final categoriesLoading = false.obs;
  final categoriesLoadFailed = false.obs;
  final selectedCategory = Rxn<AdvisoryCategoryModel>();

  final items = <AdvisoryItemModel>[].obs;
  final itemsLoading = false.obs;
  final itemsLoadFailed = false.obs;
  final selectedItem = Rxn<AdvisoryItemModel>();

  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadChoices();
  }

  Future<void> loadChoices() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await UserChoicesService().fetch();
    if (result.choices != null) {
      choices.assignAll(result.choices!);
    } else {
      choices.clear();
      errorMessage.value = result.error;
    }
    isLoading.value = false;
  }

  /// Resets the sheet to its blank state — called each time "Add new" is
  /// opened, so nothing is ever pre-selected.
  void resetAddForm() {
    selectedCategory.value = null;
    selectedItem.value = null;
    items.clear();
    itemsLoadFailed.value = false;
    loadCategories();
  }

  Future<void> loadCategories() async {
    categoriesLoading.value = true;
    categoriesLoadFailed.value = false;

    final cached = AdvisoryCategoriesService().cached;
    if (cached != null) categories.assignAll(cached);

    final fresh = await AdvisoryCategoriesService().fetch();
    if (fresh != null) {
      categories.assignAll(fresh);
    } else if (cached == null) {
      categoriesLoadFailed.value = true;
    }
    categoriesLoading.value = false;
  }

  Future<void> onCategoryChanged(AdvisoryCategoryModel? category) async {
    selectedCategory.value = category;
    selectedItem.value = null;
    items.clear();
    itemsLoadFailed.value = false;
    if (category == null) return;

    itemsLoading.value = true;
    final result = await AdvisoryItemsService().fetch(category.id);
    if (result.items != null) {
      items.assignAll(result.items!);
    } else {
      itemsLoadFailed.value = true;
    }
    itemsLoading.value = false;
  }

  /// Returns a user-facing error message on failure, or null on success.
  Future<String?> submitAddChoice() async {
    final category = selectedCategory.value;
    final item = selectedItem.value;
    if (category == null || item == null) {
      return 'my_choice.pick_both'.tr;
    }

    isSubmitting.value = true;
    try {
      final result = await UserChoicesService().add(
        categoryId: category.id,
        itemId: item.id,
      );
      if (result.choice == null) return result.error;

      // The backend upserts by (categoryId, itemId) — replace any existing
      // entry with the same id instead of duplicating it in the grid.
      final idx = choices.indexWhere((c) => c.id == result.choice!.id);
      if (idx != -1) {
        choices[idx] = result.choice!;
      } else {
        choices.add(result.choice!);
      }
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Optimistically removes [choice] from the grid; restores it and
  /// returns an error message if the server call fails. Returns null on
  /// success.
  Future<String?> removeChoice(UserChoiceModel choice) async {
    final idx = choices.indexOf(choice);
    if (idx == -1) return null;
    choices.removeAt(idx);

    final result = await UserChoicesService().remove(choice.id);
    if (!result.success) {
      choices.insert(idx, choice);
      return result.error;
    }
    return null;
  }
}
