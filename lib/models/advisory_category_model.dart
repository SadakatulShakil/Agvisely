/// One tile of the home dashboard's advisory grid, from
/// `GET /advisory/categories`.
class AdvisoryCategoryModel {
  final int id;
  final String name;
  final String? nameBn;
  final String icon; // relative path — resolve via ApiEndpoints.baseUrlUserHost
  final String? description;
  final String? descriptionBn;
  final int sortOrder;
  final bool isActive;

  const AdvisoryCategoryModel({
    required this.id,
    required this.name,
    this.nameBn,
    required this.icon,
    this.description,
    this.descriptionBn,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory AdvisoryCategoryModel.fromJson(Map<String, dynamic> j) =>
      AdvisoryCategoryModel(
        id: j['id'] as int,
        name: j['name']?.toString() ?? '',
        nameBn: j['nameBn']?.toString(),
        icon: j['icon']?.toString() ?? '',
        description: j['description']?.toString(),
        descriptionBn: j['descriptionBn']?.toString(),
        sortOrder: j['sortOrder'] is int ? j['sortOrder'] as int : 0,
        isActive: j['isActive'] != false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameBn': nameBn,
        'icon': icon,
        'description': description,
        'descriptionBn': descriptionBn,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };

  String label(bool isBn) =>
      isBn && (nameBn != null && nameBn!.isNotEmpty) ? nameBn! : name;

  String subtitle(bool isBn) {
    final bn = descriptionBn;
    if (isBn && bn != null && bn.isNotEmpty) return bn;
    return description ?? '';
  }
}
