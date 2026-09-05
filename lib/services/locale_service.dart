import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's current display language, persisted on-device.
///
/// `supported` intentionally lists only languages that actually have
/// content translated - English, Telugu, and now Urdu (sourced from the
/// original "Bayan-ul-Dua" Urdu book where the Arabic matched, and
/// carefully translated for the rest, reviewed and approved). Hindi and
/// Arabic are planned (the Dua model and JSON schema already support any
/// language code via their `*Translations` maps - see
/// lib/models/dua.dart) but are left out of this list, and so out of the
/// language picker, until their content is ready: Hindi from source PDFs
/// the team has, Arabic AI-drafted like Telugu/Urdu were. Add a code here
/// (and to MaterialApp.supportedLocales in main.dart) once its content
/// lands.
///
/// Urdu is RTL - Flutter derives Directionality automatically from the
/// active Locale via flutter_localizations, so selecting it mirrors the
/// whole app's layout with no extra code here. The UI chrome (buttons,
/// nav labels, etc. in lib/l10n/app_strings.dart) has no Urdu entries
/// yet, so it falls back to English for now while dua content displays
/// in Urdu - the same incremental-rollout fallback Telugu used before
/// its chrome strings were added.
///
/// Extends ChangeNotifier, same pattern as FavoritesService/ReminderService,
/// so the app rebuilds immediately when the language changes.
class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const _prefsKey = 'app_locale';
  static const supported = ['en', 'te', 'ur'];

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
