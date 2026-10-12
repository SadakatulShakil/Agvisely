import 'package:get/get.dart';
import '../controllers/advisory_items_controller.dart';

/// Lazily provisions [AdvisoryItemsController] for whichever advisory
/// category was tapped. [categoryId] must be the real id from
/// `GET /advisory/categories` — callers with no live category in scope
/// (e.g. a static menu shortcut) pass a known fallback id instead.
class AdvisoryItemsBinding extends Bindings {
  AdvisoryItemsBinding({required this.categoryId, this.categoryLabel});

  final int categoryId;
  final String? categoryLabel;

  @override
  void dependencies() {
    Get.lazyPut<AdvisoryItemsController>(
      () => AdvisoryItemsController(categoryId: categoryId, categoryLabel: categoryLabel),
    );
  }
}
