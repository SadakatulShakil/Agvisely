/// Slim, null-safe parser for the `result.location` object returned by
/// BMD's point-lookup endpoint (ApiEndpoints.locationLatlon). Only reads
/// the location-identity fields — none of the forecast/weather payload.
///
/// Real response shape (confirmed live):
/// { "result": { "location": {
///     "id": "257", "division": "Dhaka", "district": "Dhaka", "upazila": "Cantonment",
///     "division_bn": "...", "district_bn": "...", "upazila_bn": "...",
///     "location": "DOHS Baridhara, Cantonment, Dhaka" } } }
///
/// Note the Bangla fields are snake_case JSON keys, and the display name
/// is under the JSON key "location" (a pre-combined "city, upazila, district"
/// string) — not a key literally named "locationName".
class ApiLocationModel {
  final String? id;
  final String? locationName;
  final String? upazila;
  final String? upazilaBn;
  final String? district;
  final String? districtBn;
  final String? division;
  final String? divisionBn;

  ApiLocationModel({
    this.id,
    this.locationName,
    this.upazila,
    this.upazilaBn,
    this.district,
    this.districtBn,
    this.division,
    this.divisionBn,
  });

  factory ApiLocationModel.fromJson(Map<String, dynamic>? json) {
    final result = json?['result'] as Map<String, dynamic>?;
    final location = result?['location'] as Map<String, dynamic>?;
    return ApiLocationModel(
      id: location?['id']?.toString(),
      locationName: location?['location'] as String?,
      upazila: location?['upazila'] as String?,
      upazilaBn: location?['upazila_bn'] as String?,
      district: location?['district'] as String?,
      districtBn: location?['district_bn'] as String?,
      division: location?['division'] as String?,
      divisionBn: location?['division_bn'] as String?,
    );
  }
}
