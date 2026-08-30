import 'package:flutter/material.dart';
import '../models/dua.dart';
import '../services/dua_repository.dart';
import '../widgets/dua_card.dart';
import '../widgets/gradient_background.dart';
import 'dua_detail_screen.dart';
import 'dua_list_screen.dart';

/// Lets the person browse by "Situation" (e.g. Travel, Sleep, Illness),
/// by "Emotion" (e.g. Guilt, Fear, Gratitude), or "By Number" — the
/// duas in the same order they're printed in the book. The first two
/// taxonomies already exist in the team's spreadsheet, so this reuses
/// them directly instead of inventing a new structure.
class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bayan-udh-Dua'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'By Number'),
              Tab(text: 'By Situation'),
              Tab(text: 'By Emotion'),
            ],
          ),
        ),
        body: GradientBackground(
          child: TabBarView(
            children: [
              const _NumberList(),
              _CategoryList(
                loader: () => DuaRepository.instance.loadSituations(),
                onTap: (value) => _openList(context, situation: value),
              ),
              _CategoryList(
                loader: () => DuaRepository.instance.loadEmotions(),
                onTap: (value) => _openList(context, emotion: value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openList(BuildContext context, {String? situation, String? emotion}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DuaListScreen(situation: situation, emotion: emotion),
    ));
  }
}

/// Shows every dua grouped the way the physical book is laid out.
///
/// These appId boundaries are fixed by the book's structure (confirmed
/// against the printed page numbers), not derived from `duaNo` — the
/// duaNo string restarts at "1" inside each section (Istighfar has its
/// own "1".."14", then the numbered chapters restart at "1/1" again),
/// so appId (which is a single continuously increasing sequence across
/// the whole book) is the only reliable way to tell the sections apart.
class _NumberList extends StatelessWidget {
  const _NumberList();

  List<Dua> _range(List<Dua> duas, int from, int to) =>
      duas.where((d) => d.appId >= from && d.appId <= to).toList();

  /// Groups duas by their `situation` tag, in first-appearance order — this
  /// is how the old app split "First Chapter"/"Second Chapter" into named
  /// sub-sections (Entering Home, After Eating, Istikhara, ...) instead of
  /// one flat list. Duas whose situation is unique to them use their own
  /// title as the label instead of the (often long) situation text, since
  /// a one-off dua reads better under its own name.
  Map<String, List<Dua>> _groupBySituation(List<Dua> duas) {
    final groups = <String, List<Dua>>{};
    for (final d in duas) {
      final key = d.situation.isNotEmpty ? d.situation : (d.title.isNotEmpty ? d.title : 'Dua ${d.duaNo}');
      groups.putIfAbsent(key, () => []).add(d);
    }
    final result = <String, List<Dua>>{};
    groups.forEach((key, list) {
      final useTitle = list.length == 1 && list.first.title.isNotEmpty && key == list.first.situation;
      result[useTitle ? list.first.title : key] = list;
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Dua>>(
      future: DuaRepository.instance.loadAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final duas = snapshot.data!;
        final istighfar = _range(duas, 1, 15);
        final morningEvening = _range(duas, 16, 28);
        final afterSalah = _range(duas, 29, 39);
        final otherDuas = _range(duas, 40, 93);
        final muwaqqat = _range(duas, 94, 140);
        final otherGroups = _groupBySituation(otherDuas);
        final muwaqqatGroups = _groupBySituation(muwaqqat);

        return ListView(
          children: [
            _NumberCategory(title: 'Istighfar', duas: istighfar),
            ExpansionTile(
              title: const Text('First Chapter — Ghair Muwaqqat (1–70)'),
              subtitle: const Text('Duas read daily and at all times'),
              children: [
                _NumberCategory(title: 'Morning & Evening Duas', duas: morningEvening, indent: true),
                _NumberCategory(title: 'Dua after Salah', duas: afterSalah, indent: true),
                for (final entry in otherGroups.entries)
                  _NumberCategory(title: entry.key, duas: entry.value, indent: true),
              ],
            ),
            ExpansionTile(
              title: const Text('Second Chapter — Muwaqqat (71–110)'),
              subtitle: const Text(
                'In this chapter, those duas are mentioned which are read at times of sickness, calamities and other such occasions',
              ),
              children: [
                for (final entry in muwaqqatGroups.entries)
                  _NumberCategory(title: entry.key, duas: entry.value, indent: true),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// A collapsible section of duas within the "By Number" tab. Swiping in
/// the detail view moves between duas within this same category, since
/// that's the list the reader actually navigated from.
class _NumberCategory extends StatelessWidget {
  final String title;
  final List<Dua> duas;
  final bool indent;

  const _NumberCategory({required this.title, required this.duas, this.indent = false});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.only(left: indent ? 32 : 16, right: 16),
      title: Text(title),
      subtitle: Text('${duas.length} duas'),
      children: [
        for (var i = 0; i < duas.length; i++)
          Padding(
            padding: EdgeInsets.fromLTRB(indent ? 32 : 16, 0, 16, 10),
            child: DuaCard(
              dua: duas[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DuaDetailScreen(duas: duas, initialIndex: i),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryList extends StatelessWidget {
  final Future<List<String>> Function() loader;
  final void Function(String value) onTap;

  const _CategoryList({required this.loader, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: loader(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Center(child: Text('Nothing here yet'));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) => ListTile(
            title: Text(items[i]),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onTap(items[i]),
          ),
        );
      },
    );
  }
}
