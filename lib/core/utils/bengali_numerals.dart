/// Bengali ⇄ ASCII numeral conversion. Extracted out of CurrentWeatherModel
/// so other parsers (e.g. the 7-day forecast) can reuse the same logic
/// instead of duplicating it.
const String _bengaliDigits = '০১২৩৪৫৬৭৮৯';

/// Bengali numerals (and any other characters) to ASCII digits — numbers in
/// the bn API response are literally Bengali-numeral strings.
String toAsciiDigits(String s) {
  final buffer = StringBuffer();
  for (final ch in s.split('')) {
    final idx = _bengaliDigits.indexOf(ch);
    buffer.write(idx == -1 ? ch : idx.toString());
  }
  return buffer.toString();
}

/// Reverse of [toAsciiDigits] — ASCII 0-9 to Bengali numerals, for display.
String toBanglaDigits(String s) {
  final buffer = StringBuffer();
  for (final ch in s.split('')) {
    final idx = '0123456789'.indexOf(ch);
    buffer.write(idx == -1 ? ch : _bengaliDigits[idx]);
  }
  return buffer.toString();
}

/// Parses a numeric field that may be Bengali-numeral text, ASCII text, or
/// already a num — returns 0 if it can't be parsed at all.
double numOf(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(toAsciiDigits(v?.toString() ?? '')) ?? 0;
}
