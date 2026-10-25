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
    'splash.tagline':
        'Localized weather forecasts and expert farming advice — right in your hands.',
    'splash.technical_partner': 'Technical Partner',
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
    'home.high': 'H:',
    'home.low': 'L:',
    'home.weather_unavailable': 'Weather unavailable',
    'home.next_7_days': 'Next 7 days',
    'home.my_choice': 'My Choice',
    'home.weather_forecast': 'Today\'s Weather Forecast',
    'home.see_all': 'See all',
    'home.view7days': 'View 7 Days',

    // ── Advisory feature titles ──────────────────────────────────────────
    'advisory.crop': 'Crop Advisory',
    'advisory.disease': 'Crop Disease Early Warning',
    'advisory.pest': 'Pest Advisory',
    'advisory.livestock': 'Livestock Advisory',
    'advisory.aquaculture': 'Aquaculture Advisory',
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
    'weather.temperature': 'Temperature',
    'weather.today': 'Today',

    // ── My choice page ───────────────────────────────────────────────────
    'my_choice.empty_home': "You haven't picked anything yet — select it from your profile.",
    'my_choice.add_new': 'Add new',
    'my_choice.add_new_title': 'Add New',
    'my_choice.add_new_subtitle': 'Give info to add a new item',
    'my_choice.category': 'Category',
    'my_choice.select_category': 'Select category',
    'my_choice.item': 'Item',
    'my_choice.select_item': 'Select item',
    'my_choice.select_category_first': 'Select a category first',
    'my_choice.add_button': 'Add New',
    'my_choice.add_success': 'Added to My Choice',
    'my_choice.add_failed': 'Could not add',
    'my_choice.remove': 'Remove',
    'my_choice.remove_confirm': 'Remove @item from My Choice?',
    'my_choice.remove_failed': 'Could not remove',
    'my_choice.pick_both': 'Please select both a category and an item.',
    'my_choice.already_added_title': 'Already Added',
    'my_choice.already_added': 'This item is already in your My Choice list.',

    // ── Profile ──────────────────────────────────────────────────────────
    'profile.favorite_locations': 'Favorite Locations',
    'profile.add_new_location': 'Add New Location',
    'profile.edit_profile': 'Edit profile',
    'profile.logout': 'Logout',
    'profile.name': 'Name',
    'profile.profession': 'Profession',
    'profile.select_profession': 'Select profession',
    'profile.update_success': 'Profile updated',
    'profile.update_failed': 'Could not update profile',
    'profile.change_photo': 'Change photo',
    'profile.take_photo': 'Take photo',
    'profile.choose_from_gallery': 'Choose from gallery',
    'profile.picture_unsupported_format': 'Only PNG, JPEG or WebP images are supported.',
    'profile.picture_too_large': "Couldn't shrink this image below 2MB — please choose a smaller photo.",
    'profile.picture_update_failed': 'Could not update profile picture',
    'profile.picture_update_success': 'Profile picture updated',

    // ── Menu ─────────────────────────────────────────────────────────────
    'menu.title': 'Menu items',
    'menu.barc_fertilizer': 'BARC Fertilizer Recommendation',
    'menu.ipm_booklist': 'IPM booklist',
    'menu.user_feedback': 'User Feedback',
    'menu.other_apps': 'Others Apps',

    // ── Pest advisory (crop-select demo) ──────────────────────────────────
    'pest_advisory.select_crop_title': 'Select a crop for advisory',

    // ── Advisory items (generic item grid, any category) ───────────────────
    'advisory_items.select_item_title': 'Select an item for advisory',
    'advisory_items.select_item_title_for': 'Select an item for @category',
    'advisory_items.title_crop': 'Select a crop for Advisory',
    'advisory_items.title_livestock': 'Select a Live-stock for Advisory',
    'advisory_items.title_aquaculture': 'Select a Aquaculture for Advisory',
    'advisory_items.disease_title': 'Disease Advisory',
    'advisory_items.select_category_label': 'Select Category',
    'advisory_items.retry': 'Retry',
    'advisory_items.empty': 'No items available right now.',
    'advisory_items.empty_for': 'No items available for @category right now.',

    // ── Advisory stages (generic stage list, any item) ──────────────────────
    'advisory_stages.select_stage_title': 'Select a stage for advisory',
    'advisory_stages.select_stage_title_for': 'Select a @category stage for advisory',
    'advisory_stages.title_crop': 'Select a crop stage for advisory',
    'advisory_stages.title_livestock': 'Select a livestock stage for advisory',
    'advisory_stages.title_aquaculture': 'Select a Aquaculture stage for advisory',
    'advisory_stages.disease_title_for': 'Disease Advisory / @item',
    'advisory_stages.card_subtitle': 'Select a stage to see relevant advisory',
    'advisory_stages.retry': 'Retry',
    'advisory_stages.empty_for': 'No stages available for @item right now.',

    // ── Advisory content (the stage's full advisory body) ───────────────────
    'advisory_content.heading': 'Crop Advisory',
    'advisory_content.retry': 'Retry',
    'advisory_content.share': 'Share',
    'advisory_content.download_pdf': 'Download PDF',
    'advisory_content.error': 'Could not load this advisory.',

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
    'auth.enter_name': 'Please enter your name',
    'auth.enter_otp_code': 'Enter the @length-digit code',
    'auth.otp_resent': 'A new OTP has been sent',
    'auth.verification_failed': 'Verification failed. Please try again.',

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
    'notifications.empty': 'No notifications yet.',
    'notifications.mark_all_read': 'Mark all read',
    'common.settings': 'Settings',
    'common.language': 'Language',
    'common.retry': 'Retry',
    'common.no_internet': 'No internet connection',
    'common.save': 'Save',
    'common.cancel': 'Cancel',
    'common.error': 'Error',

    // ── Errors (network/API — NetworkExceptions, ApiClient, services) ──────
    'error.no_internet': 'No internet connection. Please check your network.',
    'error.timeout': 'Connection timed out. The server took too long to respond.',
    'error.invalid_response': 'Invalid response format received from the server.',
    'error.server_connection': 'Server connection error occurred.',
    'error.unexpected_network': 'An unexpected network error occurred.',
    'error.login_again': 'Please log in again.',
    'error.session_expired': 'Your session has expired. Please log in again.',
    'error.request_failed': 'Request failed (@code)',
    'error.select_location_first': 'Please select a location first.',
    'error.no_advisory_yet': 'No advisory available for this stage yet.',
    'error.could_not_save_location': 'Could not save location',

    // ── Settings ─────────────────────────────────────────────────────────
    'settings.dark_mode': 'Dark mode',
  };

  static const Map<String, String> _bn = {
    // ── App / splash ─────────────────────────────────────────────────────
    'app.name': 'এগভাইজলি',
    'splash.tagline': 'স্থানীয় আবহাওয়ার পূর্বাভাস ও কৃষি পরামর্শ — এখন আপনার হাতের মুঠোয়।',
    'splash.technical_partner': 'কারিগরি সহযোগী',
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
    'home.high': 'উচ্চ:',
    'home.low': 'নিম্ন:',
    'home.weather_unavailable': 'আবহাওয়ার তথ্য পাওয়া যায়নি',
    'home.next_7_days': 'আগামী ৭ দিন',
    'home.my_choice': 'আমার পছন্দ',
    'home.weather_forecast': 'আজকের আবহাওয়ার পূর্বাভাস',
    'home.see_all': 'সব দেখুন',
    'home.view7days': '৭ দিনের',

    // ── Advisory feature titles ──────────────────────────────────────────
    'advisory.crop': 'ফসল পরামর্শ',
    'advisory.disease': 'ফসলের রোগ পূর্ব সতর্কতা',
    'advisory.pest': 'পোকা পরামর্শ',
    'advisory.livestock': 'গবাদি পশু পরামর্শ',
    'advisory.aquaculture': 'মৎস্য পরামর্শ',
    'advisory.weather': 'আবহাওয়ার পূর্বাভাস',

    // ── Weather forecast (7-day detail) ────────────────────────────────────
    'weather.title': '৭ দিনের আবহাওয়ার পূর্বাভাস',
    'weather.rainfall': 'বৃষ্টিপাত',
    'weather.cloud_coverage': 'মেঘের আচ্ছাদন',
    'weather.humidity': 'আর্দ্রতা',
    'weather.soil_moisture': 'মাটির আর্দ্রতা',
    'weather.sunshine': 'রোদ',
    'weather.thi': 'তাপ-আর্দ্রতা সূচক',
    'weather.view_graph': 'বৃষ্টিপাত, তাপমাত্রা, আর্দ্রতার গ্রাফ দেখুন',
    'weather.hide_graph': 'গ্রাফ লুকান',
    'weather.temperature': 'তাপমাত্রা',
    'weather.today': 'আজ',

    // ── My choice page ───────────────────────────────────────────────────
    'my_choice.empty_home': 'আপনি এখনো কিছু নির্বাচন করেননি — আপনার প্রোফাইল থেকে নির্বাচন করুন।',
    'my_choice.add_new': 'নতুন যোগ',
    'my_choice.add_new_title': 'নতুন যোগ করুন',
    'my_choice.add_new_subtitle': 'নতুন বিষয় যোগ করতে তথ্য দিন',
    'my_choice.category': 'বিভাগ',
    'my_choice.select_category': 'বিভাগ নির্বাচন করুন',
    'my_choice.item': 'বিষয়',
    'my_choice.select_item': 'বিষয় নির্বাচন করুন',
    'my_choice.select_category_first': 'প্রথমে একটি বিভাগ নির্বাচন করুন',
    'my_choice.add_button': 'নতুন যোগ করুন',
    'my_choice.add_success': 'আমার পছন্দে যোগ হয়েছে',
    'my_choice.add_failed': 'যোগ করা যায়নি',
    'my_choice.remove': 'মুছে ফেলুন',
    'my_choice.remove_confirm': 'আমার পছন্দ থেকে @item মুছে ফেলবেন?',
    'my_choice.remove_failed': 'মুছে ফেলা যায়নি',
    'my_choice.pick_both': 'অনুগ্রহ করে একটি বিভাগ এবং একটি বিষয় নির্বাচন করুন।',
    'my_choice.already_added_title': 'ইতিমধ্যে যোগ করা হয়েছে',
    'my_choice.already_added': 'এই বিষয়টি ইতিমধ্যে আপনার পছন্দ তালিকায় রয়েছে।',

    // ── Profile ──────────────────────────────────────────────────────────
    'profile.favorite_locations': 'পছন্দের অবস্থান',
    'profile.add_new_location': 'নতুন অবস্থান যোগ করুন',
    'profile.edit_profile': 'প্রোফাইল সম্পাদনা করুন',
    'profile.logout': 'লগ আউট',
    'profile.name': 'নাম',
    'profile.profession': 'পেশা',
    'profile.select_profession': 'পেশা নির্বাচন করুন',
    'profile.update_success': 'প্রোফাইল আপডেট হয়েছে',
    'profile.update_failed': 'প্রোফাইল আপডেট করা যায়নি',
    'profile.change_photo': 'ছবি পরিবর্তন করুন',
    'profile.take_photo': 'ছবি তুলুন',
    'profile.choose_from_gallery': 'গ্যালারি থেকে নির্বাচন করুন',
    'profile.picture_unsupported_format': 'শুধুমাত্র PNG, JPEG বা WebP ছবি সমর্থিত।',
    'profile.picture_too_large': 'ছবিটি ২ এমবি-র নিচে আনা যায়নি — অনুগ্রহ করে ছোট আকারের ছবি নির্বাচন করুন।',
    'profile.picture_update_failed': 'প্রোফাইল ছবি আপডেট করা যায়নি',
    'profile.picture_update_success': 'প্রোফাইল ছবি আপডেট হয়েছে',

    // ── Menu ─────────────────────────────────────────────────────────────
    'menu.title': 'মেনু আইটেম',
    'menu.barc_fertilizer': 'বার্ক সার সুপারিশ',
    'menu.ipm_booklist': 'আইপিএম বুকলিস্ট',
    'menu.user_feedback': 'ব্যবহারকারীর মতামত',
    'menu.other_apps': 'অন্যান্য অ্যাপ',

    // ── Pest advisory (crop-select demo) ──────────────────────────────────
    'pest_advisory.select_crop_title': 'পরামর্শের জন্য একটি ফসল নির্বাচন করুন',

    // ── Advisory items (generic item grid, any category) ───────────────────
    'advisory_items.select_item_title': 'পরামর্শের জন্য একটি আইটেম নির্বাচন করুন',
    'advisory_items.select_item_title_for': '@category-এর জন্য একটি আইটেম নির্বাচন করুন',
    'advisory_items.title_crop': 'পরামর্শ পেতে ফসল বাছুন',
    'advisory_items.title_livestock': 'পরামর্শ পেতে প্রাণী বাছুন',
    'advisory_items.title_aquaculture': 'পরামর্শ পেতে মাছ বাছুন',
    'advisory_items.disease_title': 'রোগের পরামর্শ',
    'advisory_items.select_category_label': 'বিভাগ নির্বাচন করুন',
    'advisory_items.retry': 'আবার চেষ্টা করুন',
    'advisory_items.empty': 'এই মুহূর্তে কোনো আইটেম পাওয়া যায়নি।',
    'advisory_items.empty_for': 'এই মুহূর্তে @category-এর জন্য কোনো আইটেম পাওয়া যায়নি।',

    // ── Advisory stages (generic stage list, any item) ──────────────────────
    'advisory_stages.select_stage_title': 'পরামর্শের জন্য একটি ধাপ নির্বাচন করুন',
    'advisory_stages.select_stage_title_for': '@category পরামর্শের জন্য একটি ধাপ নির্বাচন করুন',
    'advisory_stages.title_crop': 'পরামর্শ পেতে ফসলের পর্যায় বাছুন',
    'advisory_stages.title_livestock': 'পরামর্শ পেতে প্রাণীর পর্যায় বাছুন',
    'advisory_stages.title_aquaculture': 'পরামর্শ পেতে মাছের পর্যায় বাছুন',
    'advisory_stages.disease_title_for': 'রোগের পরামর্শ / @item',
    'advisory_stages.card_subtitle': 'প্রাসঙ্গিক পরামর্শ দেখতে একটি ধাপ নির্বাচন করুন',
    'advisory_stages.retry': 'আবার চেষ্টা করুন',
    'advisory_stages.empty_for': 'এই মুহূর্তে @item-এর জন্য কোনো ধাপ পাওয়া যায়নি।',

    // ── Advisory content (the stage's full advisory body) ───────────────────
    'advisory_content.heading': 'ফসল পরামর্শ',
    'advisory_content.retry': 'আবার চেষ্টা করুন',
    'advisory_content.share': 'শেয়ার করুন',
    'advisory_content.download_pdf': 'পিডিএফ ডাউনলোড করুন',
    'advisory_content.error': 'এই পরামর্শটি লোড করা যায়নি।',

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
    'auth.enter_name': 'অনুগ্রহ করে আপনার নাম লিখুন',
    'auth.enter_otp_code': '@length-সংখ্যার কোডটি লিখুন',
    'auth.otp_resent': 'একটি নতুন ওটিপি পাঠানো হয়েছে',
    'auth.verification_failed': 'যাচাই ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',

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
    'notifications.empty': 'এখনো কোনো বিজ্ঞপ্তি নেই।',
    'notifications.mark_all_read': 'সব পড়া হয়েছে চিহ্নিত করুন',
    'common.settings': 'সেটিংস',
    'common.language': 'ভাষা',
    'common.retry': 'আবার চেষ্টা করুন',
    'common.no_internet': 'ইন্টারনেট সংযোগ নেই',
    'common.save': 'সংরক্ষণ করুন',
    'common.cancel': 'বাতিল',
    'common.error': 'ত্রুটি',

    // ── Errors (network/API — NetworkExceptions, ApiClient, services) ──────
    'error.no_internet': 'ইন্টারনেট সংযোগ নেই। অনুগ্রহ করে আপনার নেটওয়ার্ক পরীক্ষা করুন।',
    'error.timeout': 'সংযোগের সময় শেষ হয়ে গেছে। সার্ভার সাড়া দিতে অনেক সময় নিয়েছে।',
    'error.invalid_response': 'সার্ভার থেকে পাওয়া তথ্যের ফরম্যাট সঠিক নয়।',
    'error.server_connection': 'সার্ভার সংযোগে ত্রুটি হয়েছে।',
    'error.unexpected_network': 'একটি অপ্রত্যাশিত নেটওয়ার্ক ত্রুটি ঘটেছে।',
    'error.login_again': 'অনুগ্রহ করে আবার লগ ইন করুন।',
    'error.session_expired': 'আপনার সেশনের মেয়াদ শেষ হয়ে গেছে। অনুগ্রহ করে আবার লগ ইন করুন।',
    'error.request_failed': 'অনুরোধ ব্যর্থ হয়েছে (@code)',
    'error.select_location_first': 'অনুগ্রহ করে প্রথমে একটি অবস্থান নির্বাচন করুন।',
    'error.no_advisory_yet': 'এই ধাপের জন্য এখনো কোনো পরামর্শ পাওয়া যায়নি।',
    'error.could_not_save_location': 'লোকেশন সংরক্ষণ করা যায়নি',

    // ── Settings ─────────────────────────────────────────────────────────
    'settings.dark_mode': 'ডার্ক মোড',
  };
}
