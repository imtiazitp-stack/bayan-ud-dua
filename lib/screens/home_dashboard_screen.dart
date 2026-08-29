import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dua.dart';
import '../services/dua_repository.dart';
import '../widgets/dua_card.dart';
import '../widgets/gradient_background.dart';
import 'browse_screen.dart';
import 'dua_detail_screen.dart';
import 'favorites_screen.dart';

/// Landing tab matching the Figma "Home & search" screen: a greeting,
/// a hero banner leading into the book, then a couple of dua card
/// carousels. The banner reuses the same open-book illustration as the
/// app icon so the two stay visually tied together.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: FutureBuilder<List<Dua>>(
            future: DuaRepository.instance.loadAll(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final duas = snapshot.data!;
              final popular = duas.take(5).toList();
              final recommended = duas.length > 15
                  ? duas.sublist(10, 15)
                  : duas.skip(5).take(5).toList();
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  const _Greeting(),
                  const SizedBox(height: 20),
                  const _HeroBanner(),
                  const SizedBox(height: 28),
                  Text('Popular duas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  for (var i = 0; i < popular.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: DuaCard(
                        dua: popular[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DuaDetailScreen(duas: popular, initialIndex: i),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Text('Recommended duas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  for (var i = 0; i < recommended.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: DuaCard(
                        dua: recommended[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DuaDetailScreen(duas: recommended, initialIndex: i),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  void _shareApp() {
    Share.share(
      'Check out Bayan-udh-Dua — a collection of authentic duas, azkar and istighfar for daily recitation.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.share_outlined, color: primary),
          onPressed: _shareApp,
        ),
        IconButton(
          icon: Icon(Icons.favorite_outline, color: primary),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.7)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enhance Your\nSpiritual Journey',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Connect, Reflect, and Renew',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.75),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BrowseScreen()),
                  ),
                  child: const Text('Open book'),
                ),
              ],
            ),
          ),
          Image.asset('assets/images/open_book_icon.png', width: 84, height: 84),
        ],
      ),
    );
  }
}
