import 'user_pref_service.dart';

/// Lightweight bilingual (English / Bangla) string system.
///
/// Same approach as BMD: a single in-memory map keyed by a stable
/// string id, resolved against [UserPrefService.appLanguage]. No async
/// load, works offline, renders correctly on the first frame.
///
/// Usage in a widget:  Text(tr('home.greeting'))
/// Add a key once here and it's available app-wide in both languages.
String tr(String key) {
  final lang = UserPrefService().appLanguage; // 'en' | 'bn'
  final entry = LocalizationString.map[key];
  if (entry == null) return key; // surfaces missing keys during dev
  return entry[lang] ?? entry['en'] ?? key;
}

class LocalizationString {
  LocalizationString._();

  /// key : { 'en': ..., 'bn': ... }
  static const Map<String, Map<String, String>> map = {
    // ── App / splash ─────────────────────────────────────────────────────
    'app.name': {'en': 'Agvisely', 'bn': 'এগভাইজলি'},
    'splash.tagline': {
      'en': 'Localized weather forecasts and expert farming advice',
      'bn': 'স্থানীয় আবহাওয়ার পূর্বাভাস ও কৃষি পরামর্শ',
    },

    // ── Bottom navigation ────────────────────────────────────────────────
    'nav.home': {'en': 'Home', 'bn': 'হোম'},
    'nav.pest': {'en': 'Pest Advisory', 'bn': 'পোকা পরামর্শ'},
    'nav.profile': {'en': 'Profile', 'bn': 'প্রোফাইল'},
    'nav.menu': {'en': 'Menu', 'bn': 'মেনু'},

    // ── Home ─────────────────────────────────────────────────────────────
    'home.greeting': {'en': 'Hi', 'bn': 'হ্যালো'},
    'home.feels_like': {'en': 'Feels Like', 'bn': 'অনুভূত'},
    'home.precipitation': {'en': 'Precipitation', 'bn': 'বৃষ্টিপাত'},
    'home.pressure': {'en': 'Pressure', 'bn': 'চাপ'},
    'home.wind': {'en': 'Wind', 'bn': 'বাতাস'},
    'home.next_7_days': {'en': 'Next 7 days', 'bn': 'আগামী ৭ দিন'},
    'home.my_choice': {'en': 'My Choice', 'bn': 'আমার পছন্দ'},
    'home.see_all': {'en': 'See all', 'bn': 'সব দেখুন'},

    // ── Advisory feature titles ──────────────────────────────────────────
    'advisory.crop': {'en': 'Crop Advisory', 'bn': 'ফসল পরামর্শ'},
    'advisory.disease': {'en': 'Disease Advisory', 'bn': 'রোগ পরামর্শ'},
    'advisory.pest': {'en': 'Pest Advisory', 'bn': 'পোকা পরামর্শ'},
    'advisory.livestock': {'en': 'Livestock Advisory', 'bn': 'গবাদি পশু পরামর্শ'},
    'advisory.aquaculture': {'en': 'Aquaculture Advisory', 'bn': 'মৎস্য পরামর্শ'},
    'advisory.weather': {'en': 'Weather Forecast', 'bn': 'আবহাওয়ার পূর্বাভাস'},

    // ── Auth ─────────────────────────────────────────────────────────────
    'auth.login': {'en': 'Log In', 'bn': 'লগ ইন'},
    'auth.signup': {'en': 'Sign Up', 'bn': 'নিবন্ধন'},
    'auth.mobile': {'en': 'Mobile Number', 'bn': 'মোবাইল নম্বর'},
    'auth.continue': {'en': 'Continue', 'bn': 'চালিয়ে যান'},

    // ── Common ───────────────────────────────────────────────────────────
    'common.notifications': {'en': 'Notifications', 'bn': 'বিজ্ঞপ্তি'},
    'common.settings': {'en': 'Settings', 'bn': 'সেটিংস'},
    'common.language': {'en': 'Language', 'bn': 'ভাষা'},
    'common.retry': {'en': 'Retry', 'bn': 'আবার চেষ্টা করুন'},
    'common.no_internet': {'en': 'No internet connection', 'bn': 'ইন্টারনেট সংযোগ নেই'},
  };
}
