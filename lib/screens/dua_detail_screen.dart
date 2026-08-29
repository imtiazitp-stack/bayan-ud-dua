import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../models/dua.dart';
import '../services/favorites_service.dart';

class DuaDetailScreen extends StatefulWidget {
  final Dua dua;
  const DuaDetailScreen({super.key, required this.dua});

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen> {
  final _player = AudioPlayer();
  bool _isFavorite = false;
  bool _audioReady = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
    _prepareAudio();
  }

  Future<void> _loadFavoriteState() async {
    final fav = await FavoritesService.instance.isFavorite(widget.dua.appId);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _prepareAudio() async {
    try {
      await _player.setAsset('assets/${widget.dua.audio}');
      if (mounted) setState(() => _audioReady = true);
    } catch (_) {
      // Audio file missing for this dua — button stays disabled below.
      // Drop the matching mp3 into assets/audio/ using the filename
      // in dua.audio (see assets/data/duas.json) to enable it.
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dua;
    return Scaffold(
      appBar: AppBar(
        title: Text('Dua ${d.duaNo}'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_outline),
            onPressed: () async {
              await FavoritesService.instance.toggle(d.appId);
              _loadFavoriteState();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (d.title.isNotEmpty)
            Text(d.title, style: Theme.of(context).textTheme.titleMedium),
          if (d.situation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                d.situation,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            d.arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(fontSize: 26, height: 1.9),
          ),
          const SizedBox(height: 20),
          if (d.transliteration.isNotEmpty) ...[
            Text('Transliteration', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(d.transliteration, style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
          ],
          if (d.translation.isNotEmpty) ...[
            Text('Translation', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(d.translation),
            const SizedBox(height: 16),
          ],
          if (d.tafsir.isNotEmpty) ...[
            Text('Tafsir / Hadith', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(d.tafsir),
            const SizedBox(height: 16),
          ],
          Text(
            'Page ${d.page} in Bayan-udh-Dua',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _audioReady
            ? () => _player.playing ? _player.pause() : _player.play()
            : null,
        icon: StreamBuilder<bool>(
          stream: _player.playingStream,
          builder: (context, snap) => Icon(
            snap.data == true ? Icons.pause : Icons.play_arrow,
          ),
        ),
        label: Text(_audioReady ? 'Play recitation' : 'Audio unavailable'),
      ),
    );
  }
}
