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

  /// True for the single device-GPS entry in the saved-locations list.
  final bool isGps;

  /// True for whichever entry is the active location.
  final bool isCurrent;

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
    this.isGps = false,
    this.isCurrent = false,
  });

  SavedLocation copyWith({
    String? name,
    String? nameBn,
    double? lat,
    double? lng,
    String? pcode,
    String? upazila,
    String? upazilaBn,
    String? district,
    String? districtBn,
    String? division,
    String? divisionBn,
    bool? isGps,
    bool? isCurrent,
  }) {
    return SavedLocation(
      name: name ?? this.name,
      nameBn: nameBn ?? this.nameBn,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      pcode: pcode ?? this.pcode,
      upazila: upazila ?? this.upazila,
      upazilaBn: upazilaBn ?? this.upazilaBn,
      district: district ?? this.district,
      districtBn: districtBn ?? this.districtBn,
      division: division ?? this.division,
      divisionBn: divisionBn ?? this.divisionBn,
      isGps: isGps ?? this.isGps,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

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
    'isGps': isGps,
    'isCurrent': isCurrent,
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
    // Old stored entries predate these fields — default to false.
    isGps: json['isGps'] == true,
    isCurrent: json['isCurrent'] == true,
  );

  /// Display name combining union + district, matching the language.
  String displayName(bool isBangla) =>
      isBangla ? '$nameBn, $districtBn' : '$name, $district';
}
