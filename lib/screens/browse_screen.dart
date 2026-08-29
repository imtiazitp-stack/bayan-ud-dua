import 'package:flutter/material.dart';
import '../models/dua.dart';
import '../services/dua_repository.dart';
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

/// Shows every dua in book order (by `duaNo`), for readers who already
/// know which number they're looking for.
class _NumberList extends StatelessWidget {
  const _NumberList();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Dua>>(
      future: DuaRepository.instance.loadAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final duas = snapshot.data!;
        return ListView.separated(
          itemCount: duas.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final d = duas[i];
            return ListTile(
              leading: CircleAvatar(child: Text(d.duaNo)),
              title: Text(d.title.isNotEmpty ? d.title : 'Dua ${d.duaNo}'),
              subtitle: Text(
                d.translation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DuaDetailScreen(dua: d)),
              ),
            );
          },
        );
      },
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
