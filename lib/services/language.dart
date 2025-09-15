import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saru/screens/Splash/splash.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  // Current locale
  Rx<Locale> currentLocale = const Locale('en').obs;

  // Available locales
  final List<Locale> supportedLocales = const [
    Locale('en'), // English
    Locale('ar'), // Arabic
  ];

  // Language names for display
  final Map<String, String> languageNames = {
    'en': 'English',
    'ar': 'العربية',
  };

  @override
  void onInit() {
    super.onInit();
    // Initialize with device locale if supported, otherwise default to English
    final deviceLocale = Get.deviceLocale;
    if (deviceLocale != null && supportedLocales.contains(deviceLocale)) {
      currentLocale.value = deviceLocale;
    }
  }

  // Change language
  void changeLanguage(String languageCode) {
    final locale = Locale(languageCode);
    if (supportedLocales.contains(locale)) {
      currentLocale.value = locale;
      Get.updateLocale(locale);

      Get.offAll(
        () => const SplashScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Toggle between English and Arabic
  void toggleLanguage() {
    if (currentLocale.value.languageCode == 'en') {
      changeLanguage('ar');
    } else {
      changeLanguage('en');
    }
  }

  // Get current language name
  String get currentLanguageName {
    return languageNames[currentLocale.value.languageCode] ?? 'English';
  }

  // Check if current language is RTL
  bool get isRTL {
    return currentLocale.value.languageCode == 'ar';
  }
}
