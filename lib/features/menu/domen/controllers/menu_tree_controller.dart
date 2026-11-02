import 'package:get/get.dart';

import '../../../../core/services/custom_codes_service.dart';
import '../../../../models/custom_code_model.dart';

/// Drives the Menu tab's dynamic `GET /custom-codes` tree — the root list
/// shown on the tab itself, plus a flat id→node index (built once per
/// fetch) so drilling into a `'list'` node can go "back" by looking up a
/// node's own `parentId`, without relying on the Flutter navigation stack.
/// The whole tab — root list and every drill-down level — renders from a
/// single page ([MenuPage]): [currentNode] is null at the root and holds
/// whichever node is currently being browsed otherwise.
class MenuTreeController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final items = <CustomCodeModel>[].obs;

  /// Null at the tab's root list; otherwise the `'list'` node currently
  /// being browsed, whose `children` drive the visible rows.
  final currentNode = Rxn<CustomCodeModel>();

  final _index = <int, CustomCodeModel>{};

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await CustomCodesService().fetch();
    if (result.items != null) {
      items.assignAll(result.items!);
      _index.clear();
      for (final node in result.items!) {
        _indexNode(node);
      }
    } else {
      items.clear();
      errorMessage.value = result.error;
    }
    isLoading.value = false;
  }

  void _indexNode(CustomCodeModel node) {
    _index[node.id] = node;
    for (final child in node.children) {
      _indexNode(child);
    }
  }

  /// Folds a lazily-fetched node (`GET /custom-codes/{id}`, now carrying
  /// its own children) back into the index, so `parentOf` keeps working
  /// for everything reachable from it.
  void mergeFetchedNode(CustomCodeModel node) => _indexNode(node);

  /// Null when [node] is a root (nothing to go back to).
  CustomCodeModel? parentOf(CustomCodeModel node) =>
      node.parentId == null ? null : _index[node.parentId];

  /// Drills into [node] — used as the `onOpenList` callback for
  /// `handleCustomCodeTap`.
  void open(CustomCodeModel node) => currentNode.value = node;

  /// Resets back to the root list — called when the user leaves the Menu
  /// tab for another bottom-nav tab, so coming back always lands on the
  /// starting view instead of wherever they last left off drilling.
  void resetToRoot() => currentNode.value = null;

  /// Moves up one level: to [currentNode]'s parent, or back to the root
  /// list when it has none. Returns false (no-op) when already at the
  /// root, so the caller can fall back to the default back behavior.
  ///
  /// A resolved parent with no `parentId` of its own is a root-level node —
  /// `flattenCustomCodes` already shows those inline (as a header + its
  /// children) on the root list rather than behind their own tap, so
  /// landing on one here would just redraw that same content as a
  /// redundant titled page. Collapse straight to the root list instead.
  bool goBack() {
    final node = currentNode.value;
    if (node == null) return false;
    final parent = parentOf(node);
    currentNode.value = parent?.parentId == null ? null : parent;
    return true;
  }
}
