/// Demo district → upazila data for the sign-up dropdowns.
///
/// This is a small sample so the UI works end-to-end. Replace with the
/// full DAE district/upazila list (ideally loaded from a bundled JSON
/// asset or the API) before release.
class BdLocations {
  BdLocations._();

  static const List<String> professions = [
    'Farmer',
    'Agri Officer',
    'Trader',
    'Student',
    'Other',
  ];

  static const Map<String, List<String>> districtUpazilas = {
    'Sherpur': ['Sherpur Sadar', 'Nalitabari', 'Nakla', 'Sreebardi', 'Jhenaigati'],
    'Mymensingh': ['Mymensingh Sadar', 'Trishal', 'Muktagacha', 'Bhaluka', 'Gaffargaon'],
    'Dhaka': ['Dhamrai', 'Savar', 'Keraniganj', 'Nawabganj', 'Dohar'],
    'Rangpur': ['Rangpur Sadar', 'Badarganj', 'Mithapukur', 'Pirgacha', 'Taraganj'],
    'Bogura': ['Bogura Sadar', 'Sherpur', 'Shibganj', 'Adamdighi', 'Gabtali'],
  };

  static List<String> get districts => districtUpazilas.keys.toList();

  static List<String> upazilasOf(String? district) =>
      district == null ? const [] : (districtUpazilas[district] ?? const []);
}
