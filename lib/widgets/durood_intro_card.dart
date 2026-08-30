import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dua.dart';

/// The durood recited before starting the book's duas (page 34). It isn't
/// itself a numbered dua, so it's shown as a static, non-tappable card
/// rather than forced into a swipeable dua list.
class DuroodIntroCard extends StatelessWidget {
  final Dua dua;
  const DuroodIntroCard({super.key, required this.dua});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dua.title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            Text(
              dua.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(fontSize: 19, height: 1.9),
            ),
            if (dua.transliteration.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(dua.transliteration, style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
            if (dua.translation.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(dua.translation),
            ],
            if (dua.tafsir.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(dua.tafsir, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
