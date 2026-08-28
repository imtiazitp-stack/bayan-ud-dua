import 'package:flutter/material.dart';
import 'browse_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

/// Root screen: three tabs mirroring how the team already organizes
/// content (Browse by situation/emotion, Search, Favorites).
/// This is deliberately shallow — the book's own chapter structure
/// (from the Content sheet) drives the "Browse" tab.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _screens = [
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
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Browse'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Favorites'),
        ],
      ),
    );
  }
}
