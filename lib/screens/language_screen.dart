import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/locale_service.dart';
import '../widgets/gradient_background.dart';

/// Simple radio-style list of the app's supported display languages.
/// Reached from the overflow menu on the Home tab (see
/// home_dashboard_screen.dart's _Greeting). Only languages with real
/// content are offered - see LocaleService.supported for why Arabic/
/// Hindi/Urdu aren't listed yet.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const _labels = {
    'en': 'English',
    'te': 'తెలుగు',
  };

  @override
  Widget build(BuildContext context) {
    final current = LocaleService.instance.locale.languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context, 'select_language'))),
      body: GradientBackground(
        child: RadioGroup<String>(
          groupValue: current,
          onChanged: (value) async {
            if (value == null) return;
            await LocaleService.instance.setLocale(value);
            if (mounted) setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              for (final code in LocaleService.supported)
                RadioListTile<String>(
                  title: Text(_labels[code] ?? code),
                  value: code,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
