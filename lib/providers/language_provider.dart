import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = 'vi';
  Locale _locale = const Locale('vi', 'VN');

  String get language => _language;
  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'vi';
    _language = lang;
    _locale = _getLocaleFromLanguage(lang);
    await initializeDateFormatting(_locale.toString(), null);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_language == language) return;
    
    _language = language;
    _locale = _getLocaleFromLanguage(language);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    
    await initializeDateFormatting(_locale.toString(), null);
    notifyListeners();
  }

  Locale _getLocaleFromLanguage(String language) {
    switch (language) {
      case 'en':
        return const Locale('en', 'US');
      case 'vi':
        return const Locale('vi', 'VN');
      default:
        return const Locale('vi', 'VN');
    }
  }

  String getLanguageName() {
    switch (_language) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return 'Tiếng Việt';
    }
  }
}




