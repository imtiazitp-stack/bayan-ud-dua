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
    // A warm, restrained palette — replace seedColor with your brand
    // color from the Figma file once it's exported.
    const seed = Color(0xFF2F6F5E);

    return MaterialApp(
      title: 'Bayan-udh-Dua',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const HomeScreen(),
    );
  }
}
