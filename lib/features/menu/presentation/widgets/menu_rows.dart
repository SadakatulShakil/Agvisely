import '../../../../models/custom_code_model.dart';

/// One rendered row on a custom-codes list page (Menu tab root, or the
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
List<MenuRow> flattenCustomCodes(List<CustomCodeModel> nodes, bool isBn) {
  final rows = <MenuRow>[];
  for (final node in nodes) {
    if (node.children.isNotEmpty) {
      rows.add(MenuRowHeader(node.displayTitle(isBn)));
      rows.addAll(flattenCustomCodes(node.children, isBn));
    } else {
      rows.add(MenuRowItem(node));
    }
  }
  return rows;
}
