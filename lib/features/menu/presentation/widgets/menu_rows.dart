import '../../../../models/custom_code_model.dart';

/// One rendered row on a custom-codes list page (Menu tab root, or the
/// drill-down browser page) — either a non-tappable section label (a
/// node's own title, shown above children the app already has) or an
/// actual tappable item.
sealed class MenuRow {}

class MenuRowHeader extends MenuRow {
  MenuRowHeader(this.title);
  final String title;
}

class MenuRowItem extends MenuRow {
  MenuRowItem(this.node);
  final CustomCodeModel node;
}

/// `GET /custom-codes/{id}` fetch (see `handleCustomCodeTap`), not this
List<MenuRow> flattenCustomCodes(List<CustomCodeModel> nodes) {
  final rows = <MenuRow>[];
  for (final node in nodes) {
    if (node.children.isNotEmpty) {
      rows.add(MenuRowHeader(node.displayTitle));
      rows.addAll(flattenCustomCodes(node.children));
    } else {
      rows.add(MenuRowItem(node));
    }
  }
  return rows;
}
