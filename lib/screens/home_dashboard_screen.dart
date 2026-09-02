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

  // Hand-picked by the team rather than derived from any usage data (the
  // app doesn't track that): Istighfar 10, and duas 42, 58, 69, 85, 89, 33.
  static const _popularAppIds = [11, 63, 81, 92, 110, 114, 52];

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
              final byAppId = {for (final d in duas) d.appId: d};
              final popular = [
                for (final id in _popularAppIds)
                  if (byAppId[id] != null) byAppId[id]!,
              ];
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
      'Check out Bayan-udh-Dua - a collection of authentic duas, azkar and istighfar for daily recitation.',
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
            // The Bismillah, written as \u escapes rather than literal
            // Arabic - the GitHub web editor's paste path has repeatedly
            // mangled non-ASCII bytes pushed through this pipeline (see
            // also the plain-ASCII "|" fix in browse_screen.dart), and a
            // line-count check doesn't catch that kind of corruption.
            // Escapes are pure ASCII, so they survive the same paste
            // round-trip unchanged.
            String.fromCharCodes(const [
              0x0628, 0x0650, 0x0633, 0x0652, 0x0645, 0x0650, 0x0020,
              0x0627, 0x0644, 0x0644, 0x064e, 0x0651, 0x0647, 0x0650, 0x0020,
              0x0627, 0x0644, 0x0631, 0x064e, 0x0651, 0x062d, 0x0652, 0x0645,
              0x064e, 0x0670, 0x0646, 0x0650, 0x0020,
              0x0627, 0x0644, 0x0631, 0x064e, 0x0651, 0x062d, 0x0650, 0x064a,
              0x0645, 0x0650,
            ]),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            // Matches Figma's "Body/Arabic dua" style (Outfit + automatic
            // glyph fallback) - see dua_card.dart for why Outfit is
            // correct here despite being a Latin font.
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
        ),
        PopupMenuButton<void>(
          icon: Icon(Icons.more_vert, color: primary),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: _shareApp,
              child: const Row(
                children: [
                  Icon(Icons.share_outlined),
                  SizedBox(width: 12),
                  Text('Share app'),
                ],
              ),
            ),
          ],
        ),
        Tooltip(
          message: 'Favorites',
          child: IconButton(
            icon: Icon(Icons.favorite_outline, color: primary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  // Exact gradient stops from the Figma banner component, not derived
  // from the app's teal theme color - Figma uses a distinct teal-to-lime
  // pairing here rather than a tint of the primary color.
  static const _gradientStart = Color(0xFF39AAAD);
  static const _gradientEnd = Color(0xFFBDD683);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradientStart, _gradientEnd],
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
                    backgroundColor: Colors.white,
                    foregroundColor: _gradientStart,
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
