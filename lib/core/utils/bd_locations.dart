/// Static reference data for the sign-up screen that isn't in the location
/// dataset. District/Upazila now come from LocationRepository
/// (assets/json/location_list.json) — see AuthController.
class BdLocations {
  BdLocations._();

  static const List<String> professions = [
    'Farmer',
    'Agri Officer',
    'Trader',
    'Student',
    'Other',
  ];
}
