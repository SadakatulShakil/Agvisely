/// Where [LocationGatePage] (and, on fallback, [SelectLocationPage]) should
/// land once a location is resolved.
///
/// - [home]: already-logged-in users (splash screen re-entry).
/// - [login]: fresh install / not-yet-logged-in users — location is
///   resolved once, up front, so district/upazila are already known by the
///   time they reach the signup form.
enum LocationGateDestination { home, login }
