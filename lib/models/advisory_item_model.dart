/// One tile of an advisory category's "select an item for advisory" grid,
/// from `GET /advisory/categories/{categoryId}/items`.
class AdvisoryItemModel {
  final int id;
  final int categoryId;
  final String name;
  final String? nameBn;
  final String? imageUrl; // relative path — resolve via ApiEndpoints.baseUrlUserHost
  final int sortOrder;
  final bool isActive;

  const AdvisoryItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.nameBn,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory AdvisoryItemModel.fromJson(Map<String, dynamic> j) => AdvisoryItemModel(
        id: j['id'] as int,
        categoryId: j['categoryId'] is int ? j['categoryId'] as int : 0,
        name: j['name']?.toString() ?? '',
        nameBn: j['nameBn']?.toString(),
        imageUrl: j['imageUrl']?.toString(),
        sortOrder: j['sortOrder'] is int ? j['sortOrder'] as int : 0,
        isActive: j['isActive'] != false,
      );

  String label(bool isBn) =>
      isBn && (nameBn != null && nameBn!.isNotEmpty) ? nameBn! : name;
}
