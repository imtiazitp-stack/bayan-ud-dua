import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import 'home_dashboard_screen.dart';
import 'browse_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

/// Root screen: four tabs mirroring how the team already organizes
/// content (a Home dashboard, Browse by situation/emotion/number,
/// Search, Favorites). This is deliberately shallow - the book's own
/// chapter structure (from the Content sheet) drives the "Browse" tab.
class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _index = widget.initialIndex;

  // Index 2 (Search) is never actually shown here - see
  // onDestinationSelected below, which pushes SearchScreen as its own
  // route instead of swapping to it as a tab.
  static const _screens = [
    HomeDashboardScreen(),
    BrowseScreen(),
    SizedBox.shrink(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          // Search is a look-something-up-then-continue action, not a
          // persistent tab like the other three - pushing it (rather than
          // swapping the IndexedStack) means the back button returns
          // exactly to whichever tab was open before, instead of losing
          // that place the way switching tabs would.
          if (i == 2) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
            return;
          }
          setState(() => _index = i);
        },
        destinations: [
          // tooltip: '' suppresses NavigationDestination's default
          // long-press tooltip (which just repeats the visible label) -
          // the tooltip that was actually asked for is on the Favorites
          // heart at the top of the Home screen, not down here.
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: AppStrings.of(context, 'nav_home'), tooltip: ''),
          NavigationDestination(icon: const Icon(Icons.menu_book_outlined), label: AppStrings.of(context, 'nav_browse'), tooltip: ''),
          NavigationDestination(icon: const Icon(Icons.search), label: AppStrings.of(context, 'nav_search'), tooltip: ''),
          NavigationDestination(icon: const Icon(Icons.favorite_outline), label: AppStrings.of(context, 'nav_favorites'), tooltip: ''),
        ],
      ),
    );
  }
}
