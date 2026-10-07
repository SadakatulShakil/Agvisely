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
    'home.weather_forecast': 'Today\'s Weather Forecast',
    'home.see_all': 'See all',
    'home.view7days': 'View 7 Days',

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

    // ── Weather forecast (7-day detail) ────────────────────────────────────
    'weather.title': '7 Days Weather Forecast',
    'weather.rainfall': 'Rainfall',
    'weather.cloud_coverage': 'Cloud coverage',
    'weather.humidity': 'Humidity',
    'weather.soil_moisture': 'Soil Moisture',
    'weather.sunshine': 'Sunshine',
    'weather.thi': 'THI',
    'weather.view_graph': 'View Rainfall, temperature, humidity graph',
    'weather.hide_graph': 'Hide graph',

    // ── My choice feature titles ──────────────────────────────────────────
    'my_choice.boro_rice': 'Boro Rice',
    'my_choice.chicken': 'Chicken',
    'my_choice.wheat': 'Wheat',

    // ── Profile ──────────────────────────────────────────────────────────
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
    'auth.contact_no': 'Contact No',
    'auth.request_otp': 'Request OTP',

    // ── Onboarding ───────────────────────────────────────────────────────
    'onboarding.slide1_title': 'Localized weather forecasts',
    'onboarding.slide1_subtitle':
        'Accurate, area-specific forecasts for your district and upazila — every day.',
    'onboarding.slide2_title': 'Expert farming advice',
    'onboarding.slide2_subtitle':
        'Crop, pest, disease and livestock guidance tailored to your season and location.',
    'onboarding.slide3_title': 'Timely alerts, even offline',
    'onboarding.slide3_subtitle':
        'Get warnings before bad weather hits and browse advice without a connection.',
    'onboarding.skip': 'Skip',
    'onboarding.next': 'Next',
    'onboarding.get_started': 'Get Started',

    // ── Login ────────────────────────────────────────────────────────────
    'login.welcome_back': 'Welcome back',
    'login.subtitle': 'Enter your mobile number to receive a one-time code',
    'login.new_here': 'New here?',
    'login.create_account': 'Create an account',

    // ── Sign up ──────────────────────────────────────────────────────────
    'signup.intro':
        'To create a quick and easy one-time sign-up, you only need some pieces of information',
    'signup.your_name': 'Your Name',
    'signup.name_hint': 'Write your name here',
    'signup.your_profession': 'Your Profession',
    'signup.select_profession': 'Select a profession',
    'signup.select_profession_error': 'Please select a profession',
    'signup.already_have_account': 'Already have an account?',

    // ── OTP ──────────────────────────────────────────────────────────────
    'otp.title': 'OTP Verification Code',
    'otp.sent_to': 'We have sent the verification code to',
    'otp.verify': 'Verify OTP',
    'otp.resend': 'Resend code',

    // ── Locations ────────────────────────────────────────────────────────
    'locations.title': 'Locations',
    'locations.current_location': 'Current Location',
    'locations.add_location': 'Add location',
    'select_location.title': 'Select Location',
    'select_location.search_hint': 'Search upazila or district...',
    'select_location.no_results': 'No results found',

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
    'home.weather_forecast': 'আজকের আবহাওয়ার পূর্বাভাস',
    'home.see_all': 'সব দেখুন',
    'home.view7days': '৭ দিনের',

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

    // ── Weather forecast (7-day detail) ────────────────────────────────────
    'weather.title': '৭ দিনের আবহাওয়ার পূর্বাভাস',
    'weather.rainfall': 'বৃষ্টিপাত',
    'weather.cloud_coverage': 'মেঘের আচ্ছাদন',
    'weather.humidity': 'আর্দ্রতা',
    'weather.soil_moisture': 'মাটির আর্দ্রতা',
    'weather.sunshine': 'সূর্যালোক',
    'weather.thi': 'THI',
    'weather.view_graph': 'বৃষ্টিপাত, তাপমাত্রা, আর্দ্রতার গ্রাফ দেখুন',
    'weather.hide_graph': 'গ্রাফ লুকান',

    // ── My choice feature titles ──────────────────────────────────────────
    'my_choice.boro_rice': 'বোরো ধান',
    'my_choice.chicken': 'মুরগি',
    'my_choice.wheat': 'গম',

    // ── Profile ──────────────────────────────────────────────────────────
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
    'auth.contact_no': 'যোগাযোগ নম্বর',
    'auth.request_otp': 'ওটিপি পাঠান',

    // ── Onboarding ───────────────────────────────────────────────────────
    'onboarding.slide1_title': 'স্থানীয় আবহাওয়ার পূর্বাভাস',
    'onboarding.slide1_subtitle':
        'প্রতিদিন আপনার জেলা ও উপজেলার জন্য নির্ভুল, এলাকাভিত্তিক পূর্বাভাস।',
    'onboarding.slide2_title': 'বিশেষজ্ঞ কৃষি পরামর্শ',
    'onboarding.slide2_subtitle':
        'আপনার মৌসুম ও এলাকা অনুযায়ী ফসল, পোকামাকড়, রোগ ও গবাদি পশুর পরামর্শ।',
    'onboarding.slide3_title': 'সময়মতো সতর্কতা, অফলাইনেও',
    'onboarding.slide3_subtitle':
        'খারাপ আবহাওয়ার আগেই সতর্কবার্তা পান এবং ইন্টারনেট ছাড়াই পরামর্শ দেখুন।',
    'onboarding.skip': 'এড়িয়ে যান',
    'onboarding.next': 'পরবর্তী',
    'onboarding.get_started': 'শুরু করুন',

    // ── Login ────────────────────────────────────────────────────────────
    'login.welcome_back': 'ফিরে আসার জন্য স্বাগতম',
    'login.subtitle': 'ওয়ান-টাইম কোড পেতে আপনার মোবাইল নম্বর দিন',
    'login.new_here': 'নতুন এসেছেন?',
    'login.create_account': 'অ্যাকাউন্ট তৈরি করুন',

    // ── Sign up ──────────────────────────────────────────────────────────
    'signup.intro':
        'দ্রুত ও সহজ এক-ধাপের নিবন্ধনের জন্য আপনাকে শুধু কয়েকটি তথ্য দিতে হবে',
    'signup.your_name': 'আপনার নাম',
    'signup.name_hint': 'আপনার নাম লিখুন',
    'signup.your_profession': 'আপনার পেশা',
    'signup.select_profession': 'একটি পেশা নির্বাচন করুন',
    'signup.select_profession_error': 'অনুগ্রহ করে একটি পেশা নির্বাচন করুন',
    'signup.already_have_account': 'ইতিমধ্যে একটি অ্যাকাউন্ট আছে?',

    // ── OTP ──────────────────────────────────────────────────────────────
    'otp.title': 'ওটিপি যাচাইকরণ কোড',
    'otp.sent_to': 'যাচাইকরণ কোড পাঠানো হয়েছে',
    'otp.verify': 'ওটিপি যাচাই করুন',
    'otp.resend': 'আবার কোড পাঠান',

    // ── Locations ────────────────────────────────────────────────────────
    'locations.title': 'লোকেশন সমূহ',
    'locations.current_location': 'বর্তমান অবস্থান',
    'locations.add_location': 'লোকেশন যোগ করুন',
    'select_location.title': 'লোকেশন নির্বাচন করুন',
    'select_location.search_hint': 'উপজেলা বা জেলা খুঁজুন...',
    'select_location.no_results': 'কোন ফলাফল পাওয়া যায়নি',

    // ── Common ───────────────────────────────────────────────────────────
    'common.notifications': 'বিজ্ঞপ্তি',
    'common.settings': 'সেটিংস',
    'common.language': 'ভাষা',
    'common.retry': 'আবার চেষ্টা করুন',
    'common.no_internet': 'ইন্টারনেট সংযোগ নেই',
  };
}
