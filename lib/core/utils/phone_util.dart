/// Bangladeshi mobile-number helpers.
///
/// Accepts any of these user inputs and canonicalises them to the local
/// 11-digit form `01XXXXXXXXX`:
///   +8801646923894  →  01646923894
///    8801646923894  →  01646923894
///     01646923894   →  01646923894
///      1646923894   →  01646923894   (missing leading zero)
///
/// A valid BD mobile number is `01` followed by an operator digit 3–9
/// (013–019) and 8 more digits — 11 digits total.
class PhoneUtil {
  PhoneUtil._();

  static final RegExp _valid = RegExp(r'^01[3-9]\d{8}$');

  /// Returns the canonical `01XXXXXXXXX` form, or `null` if it can't be
  /// coerced into a valid BD mobile number.
  static String? normalize(String input) {
    var d = input.replaceAll(RegExp(r'\D'), ''); // digits only
    if (d.startsWith('880')) d = d.substring(3); // drop country code
    if (d.startsWith('0')) d = d.substring(1); // drop any leading 0
    final canonical = '0$d'; // re-add the single leading 0
    return _valid.hasMatch(canonical) ? canonical : null;
  }

  static bool isValid(String input) => normalize(input) != null;

  /// Form-field validator. Returns an error string or null when valid.
  static String? validate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Please enter your mobile number';
    }
    return isValid(input)
        ? null
        : 'Enter a valid Bangladeshi number (e.g. 01646923894)';
  }
}
