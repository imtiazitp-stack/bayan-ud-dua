import 'package:flutter/material.dart';
import '../models/dua.dart';
import '../services/dua_repository.dart';
import '../services/favorites_service.dart';
import '../widgets/gradient_background.dart';
import 'dua_list_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // This screen stays alive inside an IndexedStack, so it never
    // naturally rebuilds on tab switch - listen so a heart tapped
    // anywhere else in the app shows up here right away.
    FavoritesService.instance.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    FavoritesService.instance.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() => setState(() {});

  Future<List<Dua>> _loadFavorites() async {
    final ids = await FavoritesService.instance.getAll();
    final all = await DuaRepository.instance.loadAll();
    return all.where((d) => ids.contains(d.appId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: GradientBackground(
        child: FutureBuilder<List<Dua>>(
          future: _loadFavorites(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Tap the heart on any dua to save it here for quick access.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return DuaListView(preloaded: snapshot.data!);
          },
        ),
      ),
    );
  }
}
