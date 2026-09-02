import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dua.dart';
import '../services/favorites_service.dart';

/// The rounded, translucent dua card from the Figma "Home & search"
/// screen â€” reused everywhere a dua shows up in a list (Home's Popular/
/// Recommended sections, By Number, By Situation, By Emotion, Search,
/// Favorites) so the whole app reads as one consistent design instead of
/// Home looking different from everything else.
class DuaCard extends StatefulWidget {
  final Dua dua;
  final VoidCallback onTap;

  const DuaCard({super.key, required this.dua, required this.onTap});

  @override
  State<DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<DuaCard> {
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
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    child: d.duaNo == 'Durood'
                        ? const Icon(Icons.menu_book_outlined, size: 16)
                        : Text(d.duaNo, style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
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
                    // Figma's "Body/Arabic dua" text style: Outfit 20/36 â€”
                    // Outfit has no Arabic glyphs, so Figma (and Flutter)
                    // both fall back to the platform's default Arabic font
                    // automatically. No separate calligraphic font was
                    // actually specified by the design.
                    style: GoogleFonts.outfit(fontSize: 20, height: 1.8),
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
