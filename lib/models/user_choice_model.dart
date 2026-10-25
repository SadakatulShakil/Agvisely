/// One saved pick on the "My Choice" page, from `GET /user-choices` (and the
/// single object `POST /user-choices` returns on success). Unlike
/// [AdvisoryItemModel], the category/item names come back already flattened
/// onto this object (`categoryName`/`itemName` etc.) rather than nested.
class UserChoiceModel {
  final int id;
  final int categoryId;
  final String categoryName;
  final String? categoryNameBn;
  final int itemId;
  final String itemName;
  final String? itemNameBn;
  final String? itemImageUrl; // relative path — resolve via ApiEndpoints.baseUrlUserHost

  const UserChoiceModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    this.categoryNameBn,
    required this.itemId,
    required this.itemName,
    this.itemNameBn,
    this.itemImageUrl,
  });

  factory UserChoiceModel.fromJson(Map<String, dynamic> j) => UserChoiceModel(
        id: j['id'] as int,
        categoryId: j['categoryId'] is int ? j['categoryId'] as int : 0,
        categoryName: j['categoryName']?.toString() ?? '',
        categoryNameBn: j['categoryNameBn']?.toString(),
        itemId: j['itemId'] is int ? j['itemId'] as int : 0,
        itemName: j['itemName']?.toString() ?? '',
        itemNameBn: j['itemNameBn']?.toString(),
        itemImageUrl: j['itemImageUrl']?.toString(),
      );

  String itemLabel(bool isBn) =>
      isBn && (itemNameBn != null && itemNameBn!.isNotEmpty) ? itemNameBn! : itemName;

  /// For [UserPrefService.cachedMyChoices] — the home dashboard's carousel
  /// only, not the My Choice page itself (which always hits the network).
  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'categoryNameBn': categoryNameBn,
        'itemId': itemId,
        'itemName': itemName,
        'itemNameBn': itemNameBn,
        'itemImageUrl': itemImageUrl,
      };
}
