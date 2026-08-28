import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/dua.dart';

/// Loads duas.json once and serves it to the rest of the app.
///
/// This is intentionally simple (no database) because the whole
/// collection is ~140 short entries — a JSON asset loaded into memory
/// is more than fast enough and keeps the app fully offline.
class DuaRepository {
  DuaRepository._();
  static final DuaRepository instance = DuaRepository._();

  List<Dua>? _cache;

  Future<List<Dua>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/duas.json');
    final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;
    _cache = jsonList
        .map((e) => Dua.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<List<String>> loadSituations() async {
    final all = await loadAll();
    final set = <String>{};
    for (final d in all) {
      if (d.situation.isNotEmpty) set.add(d.situation);
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<List<String>> loadEmotions() async {
    final all = await loadAll();
    final set = <String>{};
    for (final d in all) {
      for (final e in d.emotion) {
        if (e.isNotEmpty) set.add(e);
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<List<Dua>> bysituation(String situation) async {
    final all = await loadAll();
    return all.where((d) => d.situation == situation).toList();
  }

  Future<List<Dua>> byEmotion(String emotion) async {
    final all = await loadAll();
    return all.where((d) => d.emotion.contains(emotion)).toList();
  }

  Future<List<Dua>> search(String query) async {
    final all = await loadAll();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return all.where((d) => d.searchBlob.contains(q)).toList();
  }
}
