import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dua.dart';
import '../services/favorites_service.dart';
import '../services/reminder_service.dart';
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

class _DuaDetailPageState extends State<_DuaDetailPage> {
  final _player = AudioPlayer();
  bool _isFavorite = false;
  bool _audioReady = false;
  TimeOfDayValue? _reminderTime;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
    _loadReminderState();
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

  Future<void> _loadReminderState() async {
    final t = await ReminderService.instance.reminderFor(widget.dua.appId);
    if (mounted) setState(() => _reminderTime = t);
  }

  Future<void> _onReminderTap() async {
    if (_reminderTime != null) {
      final remove = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reminder'),
          content: Text('You have a daily reminder set for ${_reminderTime!.format()}.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Keep')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Remove reminder')),
          ],
        ),
      );
      if (remove == true) {
        await ReminderService.instance.cancelReminder(widget.dua.appId);
        await _loadReminderState();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder removed')));
        }
      }
      return;
    }
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null || !mounted) return;
    await ReminderService.instance.setReminder(
      appId: widget.dua.appId,
      duaLabel: 'Dua ${widget.dua.duaNo}',
      hour: time.hour,
      minute: time.minute,
    );
    await _loadReminderState();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily reminder set for ${time.format(context)}')),
      );
    }
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
    } catch (e) {
      // Audio file missing for this dua - play button stays disabled below.
      // Drop the matching mp3 into assets/audio/ using the filename
      // in dua.audio (see assets/data/duas.json) to enable it.
      //
      // TEMPORARY diagnostic: surface the actual exception so we can see
      // why setAsset() is failing on-device instead of guessing blind.
      // Remove this SnackBar once the real cause is found and fixed.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio error (${widget.dua.audio}): $e')),
        );
      }
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
    buffer.write('\n- shared from Bayan-udh-Dua');
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
    // The Istighfaar section (appId 1-15) is its own book chapter, so its
    // heading reads "Istighfar N" rather than the generic "Dua N".
    final heading = d.appId <= 15 ? 'Istighfar ${d.duaNo}' : 'Dua ${d.duaNo}';

    return Scaffold(
      appBar: AppBar(
        title: Text(heading),
      ),
      body: GradientBackground(
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  // Matches Figma's "Body/Arabic dua" style exactly (Outfit
                  // 20/36) - see dua_card.dart for why Outfit is correct
                  // here despite being a Latin font.
                  style: GoogleFonts.outfit(fontSize: 20, height: 1.8),
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
              // Leaves room so the bottom bar doesn't cover the last line.
              const SizedBox(height: 90),
            ],
          ),
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
              // One inline mini-player row - play button, elapsed time,
              // scrubber, total time, all on the same baseline - rather
              // than a button stacked next to a two-line seek bar, which
              // left the button's center fighting the slider's for
              // vertical alignment.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    _PlayButton(
                      audioReady: _audioReady,
                      player: _player,
                      onToggle: _togglePlay,
                    ),
                    if (_audioReady) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SeekBar(player: _player, formatDuration: _formatDuration),
                      ),
                    ],
                  ],
                ),
              ),
              // A little breathing room between the playback controls and
              // the action row below, so the two read as separate groups
              // instead of one dense block.
              const SizedBox(height: 6),
              // Each action gets an equal-width slot (rather than
              // MainAxisAlignment.spaceEvenly on raw children) so the
              // icons themselves land at evenly spaced points - spaceEvenly
              // divides free space around each child's full label width,
              // so "Reminder"/"Favourite" being wider than "Share" pulled
              // the icons off an even spacing.
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: _BottomBarAction(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onTap: () => _shareDua(d),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _BottomBarAction(
                        icon: _reminderTime != null ? Icons.notifications_active : Icons.notifications_outlined,
                        label: _reminderTime != null ? _reminderTime!.format() : 'Reminder',
                        onTap: _onReminderTap,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _BottomBarAction(
                        icon: _isFavorite ? Icons.favorite : Icons.favorite_outline,
                        label: 'Favourite',
                        onTap: _toggleFavorite,
                      ),
                    ),
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
        final timeStyle = Theme.of(context).textTheme.bodySmall;
        final primary = Theme.of(context).colorScheme.primary;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // No "00:00" at rest - the thumb's position already shows
            // progress, and a static zero here just added clutter before
            // playback starts.
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 1.5,
                  activeTrackColor: primary,
                  inactiveTrackColor: primary.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  value: valueMs,
                  max: maxMs,
                  onChanged: (value) => player.seek(Duration(milliseconds: value.round())),
                ),
              ),
            ),
            Text(formatDuration(duration), style: timeStyle),
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
    return Tooltip(
      message: label,
      child: InkWell(
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
      ),
    );
  }
}
