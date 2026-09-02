import 'package:flutter/material.dart';
import '../models/dua.dart';
import '../services/dua_repository.dart';
import '../widgets/dua_card.dart';
import '../widgets/gradient_background.dart';
import 'dua_detail_screen.dart';

/// Loads a list of duas from whichever source is given, then renders them
/// as cards - no Scaffold/AppBar of its own. [DuaListScreen] wraps this in
/// one for standalone navigation (By Situation/By Emotion), while screens
/// that already have their own top bar (Favorites, Search) embed this
/// directly instead, so the two app bars don't nest.
class DuaListView extends StatelessWidget {
  final String? situation;
  final String? emotion;
  final List<Dua>? preloaded; // used by search/favorites screens

  const DuaListView({
    super.key,
    this.situation,
    this.emotion,
    this.preloaded,
  });

  Future<List<Dua>> _load() async {
    if (preloaded != null) return preloaded!;
    if (situation != null) return DuaRepository.instance.bysituation(situation!);
    if (emotion != null) return DuaRepository.instance.byEmotion(emotion!);
    return DuaRepository.instance.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Dua>>(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final duas = snapshot.data!;
        if (duas.isEmpty) {
          return const Center(child: Text('No duas found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: duas.length,
          itemBuilder: (context, i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DuaCard(
                dua: duas[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DuaDetailScreen(duas: duas, initialIndex: i),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Standalone screen with its own AppBar, used when navigating here
/// directly (e.g. from By Situation/By Emotion) rather than embedding
/// inside another screen that already has a top bar.
class DuaListScreen extends StatelessWidget {
  final String? situation;
  final String? emotion;
  final List<Dua>? preloaded;

  const DuaListScreen({
    super.key,
    this.situation,
    this.emotion,
    this.preloaded,
  });

  @override
  Widget build(BuildContext context) {
    final title = situation ?? emotion ?? 'All Duas';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GradientBackground(
        child: DuaListView(situation: situation, emotion: emotion, preloaded: preloaded),
      ),
    );
  }
}
