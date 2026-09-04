import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';

/// The same four destinations as HomeScreen's own bottom nav bar, shown
/// on every screen reached by pushing further in (a dua's detail page,
/// a By Situation/By Emotion list, ...) so the reader can always jump
/// straight to a top-level tab without backing out of everything first.
///
/// Unlike HomeScreen's bar, none of these ever show as "selected" - this
/// page isn't one of the four tabs, so there's nothing honest to
/// highlight. Home/Browse/Favorites replace the whole navigation stack
/// with a fresh HomeScreen open on that tab (a shortcut back to the tab,
/// not a persisted per-tab back-stack). Search is different - it's a
/// look-something-up-then-continue action, not a tab to jump to, so it's
/// pushed as its own route instead: back from it returns to exactly
/// whatever page (this one) the reader was on.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  void _go(BuildContext context, int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: index)),
      (route) => false,
    );
  }

  void _search(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Expanded(
              child: _NavIcon(
                icon: Icons.home_outlined,
                label: AppStrings.of(context, 'nav_home'),
                onTap: () => _go(context, 0),
              ),
            ),
            Expanded(
              child: _NavIcon(
                icon: Icons.menu_book_outlined,
                label: AppStrings.of(context, 'nav_browse'),
                onTap: () => _go(context, 1),
              ),
            ),
            Expanded(
              child: _NavIcon(
                icon: Icons.search,
                label: AppStrings.of(context, 'nav_search'),
                onTap: () => _search(context),
              ),
            ),
            Expanded(
              child: _NavIcon(
                icon: Icons.favorite_outline,
                label: AppStrings.of(context, 'nav_favorites'),
                onTap: () => _go(context, 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
