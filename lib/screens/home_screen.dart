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
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _screens = [
    HomeDashboardScreen(),
    BrowseScreen(),
    SearchScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
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
