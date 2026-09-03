import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's current display language, persisted on-device.
///
/// `supported` intentionally lists only languages that actually have
/// content translated - Telugu today. Arabic, Hindi, and Urdu are planned
/// (the Dua model and JSON schema already support any language code via
/// their `*Translations` maps - see lib/models/dua.dart) but are left out
/// of this list, and so out of the language picker, until their content is
/// ready: Hindi/Urdu from source PDFs the team has, Arabic AI-drafted like
/// Telugu. Add a code here (and to MaterialApp.supportedLocales in
/// main.dart) once its content lands.
///
/// Extends ChangeNotifier, same pattern as FavoritesService/ReminderService,
/// so the app rebuilds immediately when the language changes.
class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const _prefsKey = 'app_locale';
  static const supported = ['en', 'te'];

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && supported.contains(code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(String code) async {
    if (!supported.contains(code)) return;
    _locale = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
    notifyListeners();
  }
}
