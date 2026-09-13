class SavedLocation {
  final String name;
  final String nameBn;
  final double lat;
  final double lng;
  final String pcode;
  final String upazila;
  final String upazilaBn;
  final String district;
  final String districtBn;
  final String division;
  final String divisionBn;

  SavedLocation({
    required this.name,
    required this.nameBn,
    required this.lat,
    required this.lng,
    required this.pcode,
    required this.upazila,
    required this.upazilaBn,
    required this.district,
    required this.districtBn,
    required this.division,
    required this.divisionBn,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'nameBn': nameBn,
    'lat': lat,
    'lng': lng,
    'pcode': pcode,
    'upazila': upazila,
    'upazilaBn': upazilaBn,
    'district': district,
    'districtBn': districtBn,
    'division': division,
    'divisionBn': divisionBn,
  };

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
    name: json['name'] ?? '',
    nameBn: json['nameBn'] ?? '',
    lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
    lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    pcode: json['pcode'] ?? '',
    upazila: json['upazila'] ?? '',
    upazilaBn: json['upazilaBn'] ?? '',
    district: json['district'] ?? '',
    districtBn: json['districtBn'] ?? '',
    division: json['division'] ?? '',
    divisionBn: json['divisionBn'] ?? '',
  );

  /// Display name combining union + district, matching the language.
  String displayName(bool isBangla) =>
      isBangla ? '$nameBn, $districtBn' : '$name, $district';
}
