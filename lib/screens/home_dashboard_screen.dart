import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dua.dart';
import '../services/dua_repository.dart';
import '../services/favorites_service.dart';
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
                  for (final d in popular)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _DuaCard(dua: d),
                    ),
                  const SizedBox(height: 14),
                  Text('Recommended duas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  for (final d in recommended)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _DuaCard(dua: d),
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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Bismillah hir Rahman nir Raheem',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
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

class _DuaCard extends StatefulWidget {
  final Dua dua;
  const _DuaCard({required this.dua});

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    FavoritesService.instance.isFavorite(widget.dua.appId).then((v) {
      if (mounted) setState(() => _isFavorite = v);
    });
  }

  Future<void> _toggleFavorite() async {
    await FavoritesService.instance.toggle(widget.dua.appId);
    final v = await FavoritesService.instance.isFavorite(widget.dua.appId);
    if (mounted) setState(() => _isFavorite = v);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dua;
    final tags = d.emotion.take(2).toList();
    final overflow = d.emotion.length - tags.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? Theme.of(context).colorScheme.surfaceContainer : Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DuaDetailScreen(dua: d)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      d.title.isNotEmpty ? d.title : 'Dua ${d.duaNo}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_outline, size: 20),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
              if (d.arabic.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    d.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.amiri(fontSize: 18),
                  ),
                ),
              Text(
                d.translation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in tags) _Tag(t),
                    if (overflow > 0) _Tag('+$overflow'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: primary),
      ),
    );
  }
}
