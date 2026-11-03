class SavedLocation {
  final String name;
  final String nameBn;

  /// [name]/[nameBn] as originally resolved (geocoded/picked), before any
  /// user rename — [renameCustomLocation] only ever touches [name]/[nameBn],
  /// never these. The Home dashboard header shows this (via
  /// [originalDisplayName]) so renaming an entry in the saved-locations list
  /// doesn't change what Home shows for the active location; the
  /// saved-locations list itself shows [displayName] (the current, possibly
  /// renamed, label).
  final String originalName;
  final String originalNameBn;

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

  /// The backend's own id for this location, returned by `POST
  /// /user-locations` — null until that sync succeeds at least once (e.g.
  /// added while offline), in which case there's nothing to delete
  /// server-side either.
  final String? remoteId;

  SavedLocation({
    required this.name,
    required this.nameBn,
    String? originalName,
    String? originalNameBn,
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
    this.remoteId,
  }) : originalName = originalName ?? name,
       originalNameBn = originalNameBn ?? nameBn;

  SavedLocation copyWith({
    String? name,
    String? nameBn,
    String? originalName,
    String? originalNameBn,
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
    String? remoteId,
  }) {
    return SavedLocation(
      name: name ?? this.name,
      nameBn: nameBn ?? this.nameBn,
      originalName: originalName ?? this.originalName,
      originalNameBn: originalNameBn ?? this.originalNameBn,
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
      remoteId: remoteId ?? this.remoteId,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'nameBn': nameBn,
    'originalName': originalName,
    'originalNameBn': originalNameBn,
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
    'remoteId': remoteId,
  };

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
    name: json['name'] ?? '',
    nameBn: json['nameBn'] ?? '',
    // Old stored entries predate these fields — the current name was also
    // the original name back then, so falling back to it is exact, not a
    // guess.
    originalName: json['originalName']?.toString() ?? json['name']?.toString(),
    originalNameBn: json['originalNameBn']?.toString() ?? json['nameBn']?.toString(),
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
    // Old stored entries predate this field too — null is the correct
    // "never synced" state for them, not an empty string.
    remoteId: json['remoteId']?.toString(),
  );

  /// Display name, matching the language — reflects [name]/[nameBn], so a
  /// user rename shows up here. Used by the saved-locations list/sheet.
  ///
  /// GPS entries: [name]/[nameBn] already come straight from BMD's API as a
  /// pre-combined "place, upazila, district" string — appending district
  /// again here would duplicate it (e.g. "...তুরাগ, ঢাকা, ঢাকা").
  /// Custom (union-picked) entries: [name]/[nameBn] are just "Union,
  /// Upazila" — district is appended to complete the picture.
  String displayName(bool isBangla) => _display(isBangla, name, nameBn);

  /// Same as [displayName], but off [originalName]/[originalNameBn] — never
  /// affected by a rename. Used by the Home dashboard header, which should
  /// keep showing the real resolved place regardless of any nickname given
  /// to it in the saved-locations list.
  String originalDisplayName(bool isBangla) => _display(isBangla, originalName, originalNameBn);

  String _display(bool isBangla, String n, String nBn) {
    final label = isBangla ? nBn : n;
    if (isGps) return label;
    final d = isBangla ? districtBn : district;
    return d.isEmpty ? label : '$label, $d';
  }
}
