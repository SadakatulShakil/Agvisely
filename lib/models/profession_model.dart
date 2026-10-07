class ProfessionModel {
  final int id;
  final String name;
  final String? nameBn;
  final bool isDefault;

  const ProfessionModel({
    required this.id,
    required this.name,
    this.nameBn,
    this.isDefault = false,
  });

  factory ProfessionModel.fromJson(Map<String, dynamic> j) => ProfessionModel(
        id: j['id'] as int,
        name: j['name']?.toString() ?? '',
        nameBn: j['nameBn']?.toString(),
        isDefault: j['isDefault'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameBn': nameBn,
        'isDefault': isDefault,
      };

  String label(bool isBn) =>
      isBn && (nameBn != null && nameBn!.isNotEmpty) ? nameBn! : name;
}
