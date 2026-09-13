import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'core/services/localization_string.dart';
import 'core/services/notification_service.dart';
import 'core/services/user_pref_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/utils/firebase_option.dart';
import 'database_helper/db_service.dart';
import 'features/settings/domen/controllers/settings_controller.dart';
import 'features/settings/presentation/pages/splash_screen.dart';
final Completer<void> dbServiceReady = Completer<void>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // ── CRITICAL PATH — first frame depends on these ──────────────────────────
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kReleaseMode
          ? const AndroidPlayIntegrityProvider()
          : const AndroidDebugProvider(),
      providerApple: kReleaseMode
          ? const AppleAppAttestProvider()
          : const AppleDebugProvider(),
    );
  } catch (e, stack) {
    debugPrint('🔥 FATAL FIREBASE ERROR: $e');
    debugPrint(stack.toString());
  }

  await UserPrefService().init();
  final savedLang = UserPrefService().appLanguage;

  // Lightweight synchronous registrations — no I/O.
  Get.put(SettingsController());
  Get.put(ThemeController());

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Pin scheduled notifications to Bangladesh time regardless of device tz.
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

  runApp(AgviselyApp(savedLang));

  // ── DEFERRED — after first frame ──────────────────────────────────────────
  WidgetsBinding.instance.addPostFrameCallback((_) => _deferredInit());
}

Future<void> _deferredInit() async {
  // Notification channels must exist before any notification is posted.
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('NotificationService init failed: $e');
  }

  // Offline DB (Floor) — non-critical for first frame.
  try {
    final db = await DBService().init();
    Get.put<DBService>(db, permanent: true);
    if (!dbServiceReady.isCompleted) dbServiceReady.complete();
  } catch (e) {
    debugPrint('DBService init failed: $e');
    if (!dbServiceReady.isCompleted) dbServiceReady.complete();
  }

  await initializeDateFormatting('bn', null);
}

class AgviselyApp extends StatelessWidget {
  final String savedLang;
  const AgviselyApp(this.savedLang, {super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      minTextAdapt: true,
      builder: (context, child) => Obx(
        () => GetMaterialApp(
          title: 'Agvisely',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.themeMode.value,
          translations: LocalizationString(),
          locale: Locale(savedLang),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
