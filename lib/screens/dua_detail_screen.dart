import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dua.dart';
import '../services/favorites_service.dart';
import '../widgets/gradient_background.dart';

/// Shows a dua with swipe-to-browse: swiping left/right moves to the
/// next/previous dua in whatever list the user came from (By Number,
/// By Situation, By Emotion, Search, Favorites, or a Home card list),
/// so people don't have to keep backing out to the list and tapping
/// the next one. Vertical swipe isn't used for this since the dua's
/// own text already scrolls vertically.
class DuaDetailScreen extends StatefulWidget {
  final List<Dua> duas;
  final int initialIndex;

  const DuaDetailScreen({
    super.key,
    required this.duas,
    required this.initialIndex,
  });

  /// Convenience for the rare case where only a single dua is known,
  /// with nothing to swipe to.
  factory DuaDetailScreen.single(Dua dua, {Key? key}) =>
      DuaDetailScreen(key: key, duas: [dua], initialIndex: 0);

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen> {
  late final _pageController = PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.duas.length,
      itemBuilder: (context, i) => _DuaDetailPage(
        key: ValueKey(widget.duas[i].appId),
        dua: widget.duas[i],
      ),
    );
  }
}

class _DuaDetailPage extends StatefulWidget {
  final Dua dua;
  const _DuaDetailPage({super.key, required this.dua});

  @override
  State<_DuaDetailPage> createState() => _DuaDetailPageState();
}

class _DuaDetailPageState extends State<_DuaDetailPage> {
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
      // just_audio leaves position at the end once playback completes, so a
      // second tap on play does nothing audible unless we rewind first.
      _player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          _player.pause();
          _player.seek(Duration.zero);
        }
      });
      if (mounted) setState(() => _audioReady = true);
    } catch (_) {
      // Audio file missing for this dua — bar stays disabled below.
      // Drop the matching mp3 into assets/audio/ using the filename
      // in dua.audio (see assets/data/duas.json) to enable it.
    }
  }

  Future<void> _togglePlay(bool playing) async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    if (playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _shareDua(Dua d) {
    final buffer = StringBuffer();
    if (d.title.isNotEmpty) buffer.writeln(d.title);
    buffer.writeln(d.arabic);
    if (d.transliteration.isNotEmpty) buffer.writeln(d.transliteration);
    if (d.translation.isNotEmpty) buffer.writeln(d.translation);
    buffer.write('\n— shared from Bayan-udh-Dua');
    Share.share(buffer.toString());
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
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareDua(d),
          ),
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_outline),
            onPressed: () async {
              await FavoritesService.instance.toggle(d.appId);
              _loadFavoriteState();
            },
          ),
        ],
      ),
      body: GradientBackground(
        child: ListView(
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
            // Leaves room so the audio bar doesn't cover the last line of text.
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: !_audioReady
              ? const ListTile(
                  leading: Icon(Icons.music_off),
                  title: Text('Audio unavailable'),
                )
              : StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return StreamBuilder<Duration>(
                      stream: _player.positionStream,
                      builder: (context, posSnapshot) {
                        final position = posSnapshot.data ?? Duration.zero;
                        final duration = _player.duration ?? Duration.zero;
                        final maxMs = duration.inMilliseconds > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0;
                        final valueMs = position.inMilliseconds
                            .clamp(0, maxMs.round())
                            .toDouble();
                        return Row(
                          children: [
                            IconButton(
                              iconSize: 40,
                              icon: Icon(
                                playing
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                              ),
                              onPressed: () => _togglePlay(playing),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                    ),
                                    child: Slider(
                                      value: valueMs,
                                      max: maxMs,
                                      onChanged: (value) {
                                        _player.seek(
                                          Duration(milliseconds: value.round()),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(position),
                                          style:
                                              Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          _formatDuration(duration),
                                          style:
                                              Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
