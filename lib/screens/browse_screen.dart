import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
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
          bottom: TabBar(
            tabs: [
              Tab(text: AppStrings.of(context, 'by_number')),
              Tab(text: AppStrings.of(context, 'by_situation')),
              Tab(text: AppStrings.of(context, 'by_emotion')),
            ],
          ),
        ),
        body: GradientBackground(
          child: TabBarView(
            children: [
              const _NumberList(),
              _CategoryList(
                byEmotion: false,
                onTap: (value) => _openList(context, situation: value),
              ),
              _CategoryList(
                byEmotion: true,
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
  /// a one-off dua reads better under its own name — prefixed with its
  /// number (e.g. "22 - Jameih Dua"), matching the old app's numbering.
  ///
  /// Grouping itself always keys off the plain English `situation`/`title`
  /// (so it can't drift between languages) - only the returned `label` is
  /// localized, from a representative ("sample") dua of each group.
  List<({String label, List<Dua> duas})> _groupBySituation(List<Dua> duas, String lang) {
    final groups = <String, List<Dua>>{};
    for (final d in duas) {
      final key = d.situation.isNotEmpty ? d.situation : (d.title.isNotEmpty ? d.title : 'Dua ${d.duaNo}');
      groups.putIfAbsent(key, () => []).add(d);
    }
    final result = <({String label, List<Dua> duas})>[];
    groups.forEach((key, list) {
      final sample = list.first;
      final useTitle = list.length == 1 && sample.title.isNotEmpty && key == sample.situation;
      final label = useTitle
          ? '${sample.duaNo} - ${sample.localizedTitle(lang)}'
          : key == sample.situation && sample.situation.isNotEmpty
              ? sample.localizedSituation(lang)
              : key == sample.title && sample.title.isNotEmpty
                  ? sample.localizedTitle(lang)
                  : key;
      result.add((label: label, duas: list));
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
        final lang = Localizations.localeOf(context).languageCode;
        final duas = snapshot.data!;
        final istighfar = _range(duas, 1, 15);
        final durood = duas.where((d) => d.appId == 141).toList();
        final morningEvening = _range(duas, 16, 28);
        final afterSalah = _range(duas, 29, 39);
        final otherDuas = _range(duas, 40, 93);
        final muwaqqat = _range(duas, 94, 140);
        final otherGroups = _groupBySituation(otherDuas, lang);
        final muwaqqatGroups = _groupBySituation(muwaqqat, lang);

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          children: [
            _NumberCategory(title: AppStrings.of(context, 'istighfar'), duas: istighfar),
            // Sits between Istighfar and the First Chapter's own numbered
            // duas — it's read once before the chapter's duas begin, not
            // filed under any of them.
            if (durood.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: DuaCard(
                  dua: durood.first,
                  onTap: () => DuaDetailScreen.open(context, durood.first),
                ),
              ),
            _SectionTile(
              title: AppStrings.of(context, 'first_chapter_title'),
              subtitle: AppStrings.of(context, 'first_chapter_subtitle'),
              children: [
                _NumberCategory(title: AppStrings.of(context, 'morning_evening_duas'), duas: morningEvening, indent: true),
                _NumberCategory(title: AppStrings.of(context, 'dua_after_salah'), duas: afterSalah, indent: true),
                for (final group in otherGroups)
                  _NumberCategory(title: group.label, duas: group.duas, indent: true),
              ],
            ),
            _SectionTile(
              title: AppStrings.of(context, 'second_chapter_title'),
              subtitle: AppStrings.of(context, 'second_chapter_subtitle'),
              children: [
                for (final group in muwaqqatGroups)
                  _NumberCategory(title: group.label, duas: group.duas, indent: true),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// The rounded, icon-badged expandable row shared by every level of the
/// "By Number" tab (top-level chapters and their nested sub-sections), so
/// the whole index reads as one consistent list of pills instead of bare
/// Material list tiles.
///
/// Only the header row is an opaque pill — the expanded body sits directly
/// on the screen's real gradient background instead of on another
/// translucent card. [ExpansionTile]'s `backgroundColor` tints the whole
/// tile including its children, so a nested [_SectionTile] inside another
/// one was getting double- (or triple-) diluted white layered on top of
/// white, washing the gradient out to a pale, inconsistent green in the
/// gaps between nested sections. Rendering the body as a transparent
/// [Column] instead keeps that gap the same true green at every nesting
/// depth, matching the flat "By Situation"/"By Emotion" lists.
class _SectionTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool indent;
  final List<Widget> children;

  const _SectionTile({
    required this.title,
    this.subtitle,
    this.indent = false,
    required this.children,
  });

  @override
  State<_SectionTile> createState() => _SectionTileState();
}

class _SectionTileState extends State<_SectionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Theme.of(context).colorScheme.surfaceContainer : Colors.white.withValues(alpha: 0.85);
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.indent ? 28 : 16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: primary.withValues(alpha: 0.15),
                      child: Icon(Icons.spa_outlined, size: 16, color: primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (widget.subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(widget.subtitle!, style: Theme.of(context).textTheme.bodySmall),
                            ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(children: widget.children),
            ),
        ],
      ),
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

  /// e.g. "11-21 | 11 duas" — the duaNo span plus the total, so a reader
  /// scanning the collapsed index already knows which numbers live inside
  /// before expanding it. Falls back to a single number when there's only
  /// one dua (and count wouldn't add anything to a plain range).
  String _rangeLabel(BuildContext context) {
    if (duas.isEmpty) return AppStrings.duasCount(context, 0);
    final first = duas.first.duaNo;
    final last = duas.last.duaNo;
    final range = first == last ? first : '$first-$last';
    // Plain ASCII separator only — a "·" here got mangled to "Â·" by the
    // GitHub paste pipeline the same way the em-dash in the chapter titles
    // did (see note above _NumberList), and a line-count check doesn't
    // catch that kind of single-character corruption.
    return '$range | ${AppStrings.duasCount(context, duas.length)}';
  }

  @override
  Widget build(BuildContext context) {
    return _SectionTile(
      title: title,
      subtitle: _rangeLabel(context),
      indent: indent,
      children: [
        for (var i = 0; i < duas.length; i++)
          Padding(
            padding: EdgeInsets.fromLTRB(indent ? 16 : 4, 0, 4, 10),
            child: DuaCard(
              dua: duas[i],
              onTap: () => DuaDetailScreen.open(context, duas[i]),
            ),
          ),
      ],
    );
  }
}

/// "By Situation" / "By Emotion" tabs, styled to match "By Number"'s
/// rounded pill rows instead of a plain divided list — the whole
/// Browse screen should read as one consistent index. Each row still
/// navigates to a filtered [DuaListScreen] on tap rather than
/// expanding in place, since (unlike the book-order groups) these
/// categories aren't mutually exclusive — a dua can carry several
/// emotion tags — so there's no single place to inline its duas.
class _CategoryList extends StatelessWidget {
  final bool byEmotion;
  final void Function(String value) onTap;

  const _CategoryList({required this.byEmotion, required this.onTap});

  /// Counts, plus a representative ("sample") dua per English situation/
  /// emotion key to localize the *display* label from - navigation
  /// (`onTap`) always uses the plain English key below, matching
  /// `DuaRepository.bysituation`/`byEmotion`, so grouping/lookup never
  /// depends on the active language.
  Map<String, ({int count, Dua sample})> _counts(List<Dua> duas) {
    final counts = <String, int>{};
    final samples = <String, Dua>{};
    for (final d in duas) {
      if (byEmotion) {
        for (final e in d.emotion) {
          if (e.isNotEmpty) {
            counts[e] = (counts[e] ?? 0) + 1;
            samples.putIfAbsent(e, () => d);
          }
        }
      } else if (d.situation.isNotEmpty) {
        counts[d.situation] = (counts[d.situation] ?? 0) + 1;
        samples.putIfAbsent(d.situation, () => d);
      }
    }
    return {for (final key in counts.keys) key: (count: counts[key]!, sample: samples[key]!)};
  }

  /// The localized label for [englishKey], derived from [sample] - a
  /// situation string localizes directly, an emotion tag localizes by
  /// looking up its position in `sample.emotion` (emotionTranslations is
  /// index-aligned with it).
  String _label(String englishKey, Dua sample, String lang) {
    if (!byEmotion) return sample.localizedSituation(lang);
    final idx = sample.emotion.indexOf(englishKey);
    if (idx < 0) return englishKey;
    final translated = sample.localizedEmotion(lang);
    return idx < translated.length ? translated[idx] : englishKey;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return FutureBuilder<List<Dua>>(
      future: DuaRepository.instance.loadAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final counts = _counts(snapshot.data!);
        if (counts.isEmpty) {
          return Center(child: Text(AppStrings.of(context, 'nothing_here_yet')));
        }
        final keys = counts.keys.toList()
          ..sort((a, b) => _label(a, counts[a]!.sample, lang).compareTo(_label(b, counts[b]!.sample, lang)));
        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          children: [
            for (final key in keys)
              _CategoryTile(
                title: _label(key, counts[key]!.sample, lang),
                count: counts[key]!.count,
                icon: byEmotion ? Icons.favorite_border : Icons.spa_outlined,
                onTap: () => onTap(key),
              ),
          ],
        );
      },
    );
  }
}

/// A non-expanding row sharing the same rounded pill look as
/// [_SectionTile], for lists that navigate away on tap instead of
/// revealing children inline.
class _CategoryTile extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Theme.of(context).colorScheme.surfaceContainer : Colors.white.withValues(alpha: 0.85);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: primary.withValues(alpha: 0.15),
                  child: Icon(icon, size: 16, color: primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text(AppStrings.duasCount(context, count), style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
