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
        total: widget.duas.length,
      ),
    );
  }
}

class _DuaDetailPage extends StatefulWidget {
  final Dua dua;
  final int total;
  const _DuaDetailPage({super.key, required this.dua, required this.total});

  @override
  State<_DuaDetailPage> createState() => _DuaDetailPageState();
}

class _DuaDetailPageState extends State<_DuaDetailPage> with SingleTickerProviderStateMixin {
  static const _tabLabels = ['Dua', 'Closing notes', 'Introduction', 'Virtues of Dua', 'Types of Dua'];

  final _player = AudioPlayer();
  late final TabController _tabController;
  bool _isFavorite = false;
  bool _audioReady = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _loadFavoriteState();
    _prepareAudio();
  }

  Future<void> _loadFavoriteState() async {
    final fav = await FavoritesService.instance.isFavorite(widget.dua.appId);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    await FavoritesService.instance.toggle(widget.dua.appId);
    _loadFavoriteState();
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
      // Audio file missing for this dua — play button stays disabled below.
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

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  /// Which book section this dua belongs to, used both for the heading and
  /// as the label of the first tab (matching the Figma dua screen, where
  /// that tab is named after the current chapter rather than just "Dua").
  String _chapterLabel(int appId) {
    if (appId <= 15) return 'Istighfar';
    if (appId <= 93) return 'Chapter 1';
    return 'Chapter 2';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dua;
    final chapterLabel = _chapterLabel(d.appId);
    final tabLabels = [chapterLabel, ..._tabLabels.skip(1)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bayan-udh-Dua'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareDua(d),
          ),
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_outline),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: GradientBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Dua ${d.duaNo}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    '${d.appId} / ${widget.total}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (var i = 0; i < tabLabels.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tabLabels[i]),
                          selected: _tabController.index == i,
                          onSelected: (_) => setState(() => _tabController.index = i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                // The outer PageView already owns horizontal swipe (for
                // moving between duas) — disabling swipe here avoids the
                // two gestures fighting each other.
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _DuaTabContent(dua: d),
                  _PlaceholderTab(label: tabLabels[1]),
                  _PlaceholderTab(label: tabLabels[2]),
                  _PlaceholderTab(label: tabLabels[3]),
                  _PlaceholderTab(label: tabLabels[4]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_audioReady) _SeekBar(player: _player, formatDuration: _formatDuration),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BottomBarAction(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () => _shareDua(d),
                  ),
                  _BottomBarAction(
                    icon: Icons.download_outlined,
                    label: 'Download',
                    onTap: () => _comingSoon('Download'),
                  ),
                  _PlayButton(
                    audioReady: _audioReady,
                    player: _player,
                    onToggle: _togglePlay,
                  ),
                  _BottomBarAction(
                    icon: Icons.notifications_outlined,
                    label: 'Reminder',
                    onTap: () => _comingSoon('Reminder'),
                  ),
                  _BottomBarAction(
                    icon: _isFavorite ? Icons.favorite : Icons.favorite_outline,
                    label: 'Favourite',
                    onTap: _toggleFavorite,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The actual dua content — Arabic, transliteration, translation, tafsir —
/// each in its own icon-labelled card, matching the Figma dua screen.
class _DuaTabContent extends StatelessWidget {
  final Dua dua;
  const _DuaTabContent({required this.dua});

  @override
  Widget build(BuildContext context) {
    final d = dua;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        if (d.title.isNotEmpty)
          Text(d.title, style: Theme.of(context).textTheme.titleMedium),
        if (d.situation.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Text(
              d.situation,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          )
        else
          const SizedBox(height: 12),
        _SectionCard(
          icon: Icons.menu_book_outlined,
          label: 'Dua',
          child: Text(
            d.arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(fontSize: 24, height: 1.9),
          ),
        ),
        if (d.transliteration.isNotEmpty)
          _SectionCard(
            icon: Icons.translate_outlined,
            label: 'Transliteration',
            child: Text(d.transliteration, style: const TextStyle(fontStyle: FontStyle.italic)),
          ),
        if (d.translation.isNotEmpty)
          _SectionCard(
            icon: Icons.language_outlined,
            label: 'Translation',
            child: Text(d.translation),
          ),
        if (d.tafsir.isNotEmpty)
          _SectionCard(
            icon: Icons.info_outline,
            label: 'Tafseer',
            child: Text(d.tafsir),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  const _SectionCard({required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surfaceContainer : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: primary),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: primary)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Placeholder for the tabs whose content (closing notes, introduction
/// narrative, virtues of dua, types of dua) hasn't been written yet.
class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          '$label content coming soon.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
        ),
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  final AudioPlayer player;
  final String Function(Duration) formatDuration;
  const _SeekBar({required this.player, required this.formatDuration});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = player.duration ?? Duration.zero;
        final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
        final valueMs = position.inMilliseconds.clamp(0, maxMs.round()).toDouble();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              ),
              child: Slider(
                value: valueMs,
                max: maxMs,
                onChanged: (value) => player.seek(Duration(milliseconds: value.round())),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(position), style: Theme.of(context).textTheme.bodySmall),
                  Text(formatDuration(duration), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool audioReady;
  final AudioPlayer player;
  final void Function(bool playing) onToggle;
  const _PlayButton({required this.audioReady, required this.player, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    if (!audioReady) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: primary.withValues(alpha: 0.3),
        child: const Icon(Icons.music_off, color: Colors.white),
      );
    }
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;
        return InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => onToggle(playing),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: primary,
            child: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }
}

class _BottomBarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BottomBarAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
