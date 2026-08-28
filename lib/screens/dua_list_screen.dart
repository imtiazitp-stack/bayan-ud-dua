import 'package:flutter/material.dart';
import '../models/dua.dart';
import '../services/dua_repository.dart';
import 'dua_detail_screen.dart';

class DuaListScreen extends StatelessWidget {
  final String? situation;
  final String? emotion;
  final List<Dua>? preloaded; // used by search/favorites screens

  const DuaListScreen({
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
    final title = situation ?? emotion ?? 'All Duas';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<Dua>>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final duas = snapshot.data!;
          if (duas.isEmpty) {
            return const Center(child: Text('No duas found'));
          }
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
      ),
    );
  }
}
