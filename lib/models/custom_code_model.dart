/// One node in the Menu tab's `GET /custom-codes` tree — the whole tree
/// arrives nested in a single response (each node's `children` already
/// contains its full subtree), so browsing deeper is purely client-side;
/// there's no separate per-node fetch endpoint today. `parentId` is kept
/// (rather than threading parent object references through the otherwise
/// immutable model) so a flat id→node index built once after parsing can
/// answer "go back" by looking up `parentId` — see
/// `MenuController.goToParent`.
class CustomCodeModel {
  final int id;
  final int? parentId;
  final String name;
  final String? nameBn;

  /// `'list'` (navigate into `children`), `'pdf'` (open [url]), `'dialog'`
  /// (open the feedback-submission popup) — any other value is treated as
  /// inert (no tap action), since its behavior isn't defined by the backend
  /// contract this model follows.
  final String type;

  final String? iconUrl;
  final String? url;
  final bool isExternal;

  /// Only meaningful for `'list'` nodes — the title/subtitle to show on
  /// the drill-down page for THIS node's children (not this node's own
  /// label, which is [name]/[nameBn]).
  final String? sectionTitle;
  final String? sectionTitleBn;
  final String? sectionDescription;

  final int sortOrder;
  final bool isActive;
  final bool isChildren;
  final List<CustomCodeModel> children;

  const CustomCodeModel({
    required this.id,
    this.parentId,
    required this.name,
    this.nameBn,
    required this.type,
    this.iconUrl,
    this.url,
    this.isExternal = false,
    this.sectionTitle,
    this.sectionTitleBn,
    this.sectionDescription,
    this.sortOrder = 0,
    this.isActive = true,
    this.isChildren = false,
    this.children = const [],
  });

  factory CustomCodeModel.fromJson(Map<String, dynamic> j) => CustomCodeModel(
    id: j['id'] is int ? j['id'] as int : 0,
    parentId: j['parentId'] is int ? j['parentId'] as int : null,
    name: j['name']?.toString() ?? '',
    nameBn: j['nameBn']?.toString(),
    type: j['type']?.toString() ?? '',
    iconUrl: j['iconUrl']?.toString(),
    url: j['url']?.toString(),
    isExternal: j['isExternal'] == true,
    sectionTitle: j['sectionTitle']?.toString(),
    sectionTitleBn: j['sectionTitleBn']?.toString(),
    sectionDescription: j['sectionDescription']?.toString(),
    sortOrder: j['sortOrder'] is int ? j['sortOrder'] as int : 0,
    isActive: j['isActive'] != false,
    isChildren: j['isChildren'] == true,
    children:
        (j['children'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => CustomCodeModel.fromJson(e.cast<String, dynamic>()))
            .where((c) => c.isActive)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
  );

  /// This node's own label — the card/row name on the Menu tab.
  String label(bool isBn) =>
      isBn && (nameBn != null && nameBn!.isNotEmpty) ? nameBn! : name;

  /// The drill-down app-bar title for THIS node's children — falls back to
  /// an empty string when the backend hasn't set a section title at all
  /// (e.g. a root-level node, where [MenuPage] falls back to the generic
  /// "Menu" title instead of calling this).
  String displayTitle(bool isBn) =>
      isBn && (sectionTitleBn != null && sectionTitleBn!.isNotEmpty)
          ? sectionTitleBn!
          : (sectionTitle ?? '');
}
