import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/locale_service.dart';

void main() {
  runApp(const BayanUdhDuaApp());
}

class BayanUdhDuaApp extends StatefulWidget {
  const BayanUdhDuaApp({super.key});

  @override
  State<BayanUdhDuaApp> createState() => _BayanUdhDuaAppState();
}

class _BayanUdhDuaAppState extends State<BayanUdhDuaApp> {
  @override
  void initState() {
    super.initState();
    LocaleService.instance.addListener(_onLocaleChanged);
    LocaleService.instance.load();
  }

  @override
  void dispose() {
    LocaleService.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    // Palette from the Figma style guide (BuD_All), Green theme.
    const primary = Color(0xFF51A3A1);
    const secondary = Color(0xFFEEE8A9);
    const lightBackground = Color(0xFFFBF9E2);
    const darkBackground = Color(0xFF161216);
    const darkCard = Color(0xFF272531);

    final lightScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(primary: primary, secondary: secondary, surface: lightBackground);

    final darkScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      surface: darkBackground,
      surfaceContainer: darkCard,
    );

    return MaterialApp(
      title: 'Bayan-udh-Dua',
      debugShowCheckedModeBanner: false,
      locale: LocaleService.instance.locale,
      supportedLocales: const [Locale('en'), Locale('te'), Locale('ur')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Every screen so far has been designed against the light Figma
      // palette only — always use it, regardless of the device's system
      // dark/light setting, so the app doesn't fall back to an unstyled
      // dark background on phones that default to dark mode.
      themeMode: ThemeMode.light,
      theme: ThemeData(
        colorScheme: lightScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: lightBackground,
        textTheme: GoogleFonts.outfitTextTheme(),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: lightBackground,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: darkScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: darkBackground,
        cardColor: darkCard,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: darkBackground,
        ),
      ),
      home: const _AppEntry(),
    );
  }
}

/// Shows the first-run onboarding walkthrough once, then always the
/// normal home screen after that (tracked via shared_preferences).
class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: OnboardingScreen.hasCompletedOnboarding(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data! ? const HomeScreen() : const OnboardingScreen();
      },
    );
  }
}
