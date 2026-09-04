import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
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
          return Center(child: Text(AppStrings.of(context, 'no_duas_found')));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: duas.length,
          itemBuilder: (context, i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DuaCard(
                dua: duas[i],
                onTap: () => DuaDetailScreen.open(context, duas[i]),
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

  /// [situation]/[emotion] arrive as plain English keys (from By Situation/
  /// By Emotion, which group/navigate by the English value - see
  /// browse_screen.dart). The AppBar title, being pure display, instead
  /// shows the localized text: it loads the same list DuaListView will
  /// render and takes the label straight off its first dua, so the two
  /// never disagree on what a translation looks like.
  Future<String> _title(BuildContext context) async {
    if (situation == null && emotion == null) return AppStrings.of(context, 'all_duas');
    final lang = Localizations.localeOf(context).languageCode;
    final duas = situation != null
        ? await DuaRepository.instance.bysituation(situation!)
        : await DuaRepository.instance.byEmotion(emotion!);
    if (duas.isEmpty) return situation ?? emotion!;
    final sample = duas.first;
    if (situation != null) return sample.localizedSituation(lang);
    final idx = sample.emotion.indexOf(emotion!);
    if (idx < 0) return emotion!;
    final translated = sample.localizedEmotion(lang);
    return idx < translated.length ? translated[idx] : emotion!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _title(context),
          builder: (context, snapshot) => Text(snapshot.data ?? ''),
        ),
      ),
      body: GradientBackground(
        child: DuaListView(situation: situation, emotion: emotion, preloaded: preloaded),
      ),
    );
  }
}
