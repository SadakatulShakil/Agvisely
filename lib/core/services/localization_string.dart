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
    'home.weather_unavailable': 'Weather unavailable',
    'home.next_7_days': 'Next 7 days',
    'home.my_choice': 'My Choice',
    'home.see_all': 'See all',

    // ── Advisory feature titles ──────────────────────────────────────────
    'advisory.crop': 'Crop Advisory',
    'advisory.crop_subtitle': 'Weather-based guidance for your standing crops',
    'advisory.disease': 'Crop Disease Early Warning',
    'advisory.disease_subtitle': 'Outbreak risks and control steps near you',
    'advisory.pest': 'Pest Advisory',
    'advisory.livestock': 'Livestock Advisory',
    'advisory.livestock_subtitle': 'Keep cattle and poultry safe this week',
    'advisory.aquaculture': 'Aquaculture Advisory',
    'advisory.aquaculture_subtitle': 'Protect your fish from heat and rain',
    'advisory.weather': 'Weather Forecast',

    // ── My choice feature titles ──────────────────────────────────────────
    'my_choice.boro_rice': 'Boro Rice',
    'my_choice.chicken': 'Chicken',
    'my_choice.wheat': 'Wheat',

    // ── Profile ──────────────────────────────────────────────────────────
    'profile.role_farmer': 'Farmer',
    'profile.favorite_locations': 'Favorite Locations',
    'profile.add_new_location': 'Add New Location',
    'profile.edit_profile': 'Edit profile',
    'profile.logout': 'Logout',

    // ── Menu ─────────────────────────────────────────────────────────────
    'menu.title': 'Menu items',
    'menu.barc_fertilizer': 'BARC Fertilizer Recommendation',
    'menu.ipm_booklist': 'IPM booklist',
    'menu.user_feedback': 'User Feedback',
    'menu.other_apps': 'Others Apps',

    // ── Pest advisory (crop-select demo) ──────────────────────────────────
    'pest_advisory.select_crop_title': 'Select a crop for advisory',
    'pest_advisory.go_next_step': 'Go Next Step',
    'pest_advisory.selected_prefix': 'Selected:',
    'pest_advisory.nothing_prefix': 'Please select a crop.',

    // ── Crop names (demo catalog) ──────────────────────────────────────────
    'crop.tomato': 'Tomato',
    'crop.kharif1': 'Kharif 1',
    'crop.kharif2': 'Kharif 2',
    'crop.maize': 'Maize',
    'crop.lentil': 'Lentil',
    'crop.wheat': 'Wheat',
    'crop.rabi': 'Rabi',
    'crop.potato': 'Potato',
    'crop.banana': 'Banana',
    'crop.mung_bean': 'Mung Bean',

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
    'home.weather_unavailable': 'আবহাওয়ার তথ্য পাওয়া যায়নি',
    'home.next_7_days': 'আগামী ৭ দিন',
    'home.my_choice': 'আমার পছন্দ',
    'home.see_all': 'সব দেখুন',

    // ── Advisory feature titles ──────────────────────────────────────────
    'advisory.crop': 'ফসল পরামর্শ',
    'advisory.crop_subtitle': 'আপনার ফসলের জন্য আবহাওয়াভিত্তিক পরামর্শ',
    'advisory.disease': 'ফসলের রোগ পূর্ব সতর্কতা',
    'advisory.disease_subtitle': 'আপনার আশেপাশে প্রাদুর্ভাবের ঝুঁকি ও নিয়ন্ত্রণ পদক্ষেপ',
    'advisory.pest': 'পোকা পরামর্শ',
    'advisory.livestock': 'গবাদি পশু পরামর্শ',
    'advisory.livestock_subtitle': 'এই সপ্তাহে গবাদি পশু ও হাঁস-মুরগি নিরাপদ রাখুন',
    'advisory.aquaculture': 'মৎস্য পরামর্শ',
    'advisory.aquaculture_subtitle': 'তাপ ও বৃষ্টি থেকে আপনার মাছ রক্ষা করুন',
    'advisory.weather': 'আবহাওয়ার পূর্বাভাস',

    // ── My choice feature titles ──────────────────────────────────────────
    'my_choice.boro_rice': 'বোরো ধান',
    'my_choice.chicken': 'মুরগি',
    'my_choice.wheat': 'গম',

    // ── Profile ──────────────────────────────────────────────────────────
    'profile.role_farmer': 'কৃষক',
    'profile.favorite_locations': 'পছন্দের অবস্থান',
    'profile.add_new_location': 'নতুন অবস্থান যোগ করুন',
    'profile.edit_profile': 'প্রোফাইল সম্পাদনা করুন',
    'profile.logout': 'লগ আউট',

    // ── Menu ─────────────────────────────────────────────────────────────
    'menu.title': 'মেনু আইটেম',
    'menu.barc_fertilizer': 'বার্ক সার সুপারিশ',
    'menu.ipm_booklist': 'আইপিএম বুকলিস্ট',
    'menu.user_feedback': 'ব্যবহারকারীর মতামত',
    'menu.other_apps': 'অন্যান্য অ্যাপ',

    // ── Pest advisory (crop-select demo) ──────────────────────────────────
    'pest_advisory.select_crop_title': 'পরামর্শের জন্য একটি ফসল নির্বাচন করুন',
    'pest_advisory.go_next_step': 'পরবর্তী পদক্ষেপ',
    'pest_advisory.selected_prefix': 'নির্বাচিত:',
    'pest_advisory.nothing_prefix': 'দয়া করে একটি ফসল নির্বাচন করুন।',

    // ── Crop names (demo catalog) ──────────────────────────────────────────
    'crop.tomato': 'টমেটো',
    'crop.kharif1': 'খরিফ ১',
    'crop.kharif2': 'খরিফ ২',
    'crop.maize': 'ভুট্টা',
    'crop.lentil': 'মসুর ডাল',
    'crop.wheat': 'গম',
    'crop.rabi': 'রবি',
    'crop.potato': 'আলু',
    'crop.banana': 'কলা',
    'crop.mung_bean': 'মুগ ডাল',

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
