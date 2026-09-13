import 'package:get/get.dart';

/// GetX translations for Agvisely. Every entry has both an 'en' and a 'bn'
/// value; the active language follows [UserPrefService.appLanguage] via
/// GetMaterialApp's `locale`. Usage in a widget: `Text('home.greeting'.tr)`.
class LocalizationString extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': _en,
    'bn': _bn,
  };

  static const Map<String, String> _en = {
    // ── App / splash ─────────────────────────────────────────────────────
    'app.name': 'Agvisely',
    'splash.tagline': 'Localized weather forecasts and expert farming advice',
    'initializing_services': 'Initializing services...',
    'ready_launching_app': 'Launching app...',

    // ── Bottom navigation ────────────────────────────────────────────────
    'nav.home': 'Home',
    'nav.pest': 'Pest Advisory',
    'nav.profile': 'Profile',
    'nav.menu': 'Menu',

    // ── Home ─────────────────────────────────────────────────────────────
    'home.greeting': 'Hi',
    'home.feels_like': 'Feels Like',
    'home.precipitation': 'Precipitation',
    'home.pressure': 'Pressure',
    'home.wind': 'Wind',
    'home.next_7_days': 'Next 7 days',
    'home.my_choice': 'My Choice',
    'home.see_all': 'See all',

    // ── Advisory feature titles ──────────────────────────────────────────
    'advisory.crop': 'Crop Advisory',
    'advisory.disease': 'Disease Advisory',
    'advisory.pest': 'Pest Advisory',
    'advisory.livestock': 'Livestock Advisory',
    'advisory.aquaculture': 'Aquaculture Advisory',
    'advisory.weather': 'Weather Forecast',

    // ── Auth ─────────────────────────────────────────────────────────────
    'auth.login': 'Log In',
    'auth.signup': 'Sign Up',
    'auth.mobile': 'Mobile Number',
    'auth.continue': 'Continue',

    // ── Common ───────────────────────────────────────────────────────────
    'common.notifications': 'Notifications',
    'common.settings': 'Settings',
    'common.language': 'Language',
    'common.retry': 'Retry',
    'common.no_internet': 'No internet connection',
  };

  static const Map<String, String> _bn = {
    // ── App / splash ─────────────────────────────────────────────────────
    'app.name': 'এগভাইজলি',
    'splash.tagline': 'স্থানীয় আবহাওয়ার পূর্বাভাস ও কৃষি পরামর্শ',
    'initializing_services': 'সেবা প্রস্তুত করা হচ্ছে...',
    'ready_launching_app': 'অ্যাপ চালু হচ্ছে...',

    // ── Bottom navigation ────────────────────────────────────────────────
    'nav.home': 'হোম',
    'nav.pest': 'পোকা পরামর্শ',
    'nav.profile': 'প্রোফাইল',
    'nav.menu': 'মেনু',

    // ── Home ─────────────────────────────────────────────────────────────
    'home.greeting': 'হ্যালো',
    'home.feels_like': 'অনুভূত',
    'home.precipitation': 'বৃষ্টিপাত',
    'home.pressure': 'চাপ',
    'home.wind': 'বাতাস',
    'home.next_7_days': 'আগামী ৭ দিন',
    'home.my_choice': 'আমার পছন্দ',
    'home.see_all': 'সব দেখুন',

    // ── Advisory feature titles ──────────────────────────────────────────
    'advisory.crop': 'ফসল পরামর্শ',
    'advisory.disease': 'রোগ পরামর্শ',
    'advisory.pest': 'পোকা পরামর্শ',
    'advisory.livestock': 'গবাদি পশু পরামর্শ',
    'advisory.aquaculture': 'মৎস্য পরামর্শ',
    'advisory.weather': 'আবহাওয়ার পূর্বাভাস',

    // ── Auth ─────────────────────────────────────────────────────────────
    'auth.login': 'লগ ইন',
    'auth.signup': 'নিবন্ধন',
    'auth.mobile': 'মোবাইল নম্বর',
    'auth.continue': 'চালিয়ে যান',

    // ── Common ───────────────────────────────────────────────────────────
    'common.notifications': 'বিজ্ঞপ্তি',
    'common.settings': 'সেটিংস',
    'common.language': 'ভাষা',
    'common.retry': 'আবার চেষ্টা করুন',
    'common.no_internet': 'ইন্টারনেট সংযোগ নেই',
  };
}
