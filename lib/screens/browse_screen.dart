import 'package:flutter/material.dart';
import '../services/dua_repository.dart';
import 'dua_list_screen.dart';

/// Lets the person browse by "Situation" (e.g. Travel, Sleep, Illness)
/// or by "Emotion" (e.g. Guilt, Fear, Gratitude) — both taxonomies
/// already exist in the team's spreadsheet, so this reuses them
/// directly instead of inventing a new structure.
class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bayan-udh-Dua'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'By Situation'),
              Tab(text: 'By Emotion'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
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
    );
  }

  void _openList(BuildContext context, {String? situation, String? emotion}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DuaListScreen(situation: situation, emotion: emotion),
    ));
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
