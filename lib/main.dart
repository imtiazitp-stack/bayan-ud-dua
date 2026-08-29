import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BayanUdhDuaApp());
}

class BayanUdhDuaApp extends StatelessWidget {
  const BayanUdhDuaApp({super.key});

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
      themeMode: ThemeMode.system,
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
      home: const HomeScreen(),
    );
  }
}
