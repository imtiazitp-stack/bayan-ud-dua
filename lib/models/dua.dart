/// A single Dua entry, loaded from assets/data/duas.json.
///
/// This mirrors the "Master Data" sheet in BUD_Content_Structure_v6.1.xlsx
/// so the app's data model stays in sync with how the team already thinks
/// about the content (situation + emotion tagging, page reference, etc).
///
/// Localization: every translatable field keeps its original English value
/// (used exactly as before for grouping/lookup/search - see `situation`/
/// `emotion` below) plus a parallel `*Translations` map keyed by language
/// code ('ar'/'hi'/'ur'/'te' - English needs no entry since the base field
/// already is English). `localizedX(lang)` returns the translation for that
/// language, falling back to the English value when missing, so content can
/// roll in dua-by-dua and language-by-language without ever breaking.
/// `arabic` (the actual dua recitation text) is never translated - it's the
/// same Arabic regardless of the app's selected language.
class Dua {
  final int appId; // stable, unique internal id — always use this for keys/favorites
  final String duaNo; // display number as printed in the book (e.g. "5a")
  final String arabic;
  final String page; // page number(s) in the original book
  final String title;
  final String situation;
  final String transliteration;
  final String translation;
  final String tafsir; // hadith/tafsir context, may be empty
  final List<String> emotion; // tags, e.g. ["Guilt", "remorse", "shame"]
  final String audio; // relative asset path, e.g. "audio/dua_001.mp3"

  // Localized text, keyed by language code. Deliberately kept separate from
  // the English fields above rather than replacing them - `situation` and
  // `emotion` in particular are used as grouping/lookup keys throughout the
  // app (DuaRepository.bysituation/byEmotion, browse_screen's
  // _groupBySituation), and swapping their value for a translation would
  // silently break every one of those call sites. Grouping/lookup always
  // uses the plain English field; only display goes through localizedX().
  final Map<String, String> titleTranslations;
  final Map<String, String> situationTranslations;
  final Map<String, String> transliterationTranslations;
  final Map<String, String> translationTranslations;
  final Map<String, String> tafsirTranslations;
  final Map<String, List<String>> emotionTranslations; // same order/length as `emotion`

  const Dua({
    required this.appId,
    required this.duaNo,
    required this.arabic,
    required this.page,
    required this.title,
    required this.situation,
    required this.transliteration,
    required this.translation,
    required this.tafsir,
    required this.emotion,
    required this.audio,
    this.titleTranslations = const {},
    this.situationTranslations = const {},
    this.transliterationTranslations = const {},
    this.translationTranslations = const {},
    this.tafsirTranslations = const {},
    this.emotionTranslations = const {},
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    Map<String, String> stringMap(String key) {
      final raw = json[key] as Map<String, dynamic>?;
      if (raw == null) return const {};
      return raw.map((k, v) => MapEntry(k, v.toString()));
    }

    return Dua(
      appId: json['appId'] as int,
      duaNo: json['duaNo'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      page: json['page'] as String? ?? '',
      title: json['title'] as String? ?? '',
      situation: json['situation'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      tafsir: json['tafsir'] as String? ?? '',
      emotion: (json['emotion'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      audio: json['audio'] as String? ?? '',
      titleTranslations: stringMap('titleTranslations'),
      situationTranslations: stringMap('situationTranslations'),
      transliterationTranslations: stringMap('transliterationTranslations'),
      translationTranslations: stringMap('translationTranslations'),
      tafsirTranslations: stringMap('tafsirTranslations'),
      emotionTranslations: (json['emotionTranslations'] as Map<String, dynamic>? ?? {})
          .map((lang, list) => MapEntry(
                lang,
                (list as List<dynamic>).map((e) => e.toString()).toList(),
              )),
    );
  }

  String localizedTitle(String lang) => lang == 'en' ? title : (titleTranslations[lang] ?? title);
  String localizedSituation(String lang) =>
      lang == 'en' ? situation : (situationTranslations[lang] ?? situation);
  String localizedTransliteration(String lang) =>
      lang == 'en' ? transliteration : (transliterationTranslations[lang] ?? transliteration);
  String localizedTranslation(String lang) =>
      lang == 'en' ? translation : (translationTranslations[lang] ?? translation);
  String localizedTafsir(String lang) => lang == 'en' ? tafsir : (tafsirTranslations[lang] ?? tafsir);

  /// The emotion tags in [lang], falling back to the English tag for any
  /// index that has no translation yet (e.g. a dua only partly translated).
  List<String> localizedEmotion(String lang) {
    if (lang == 'en') return emotion;
    final translated = emotionTranslations[lang];
    if (translated == null) return emotion;
    return List.generate(
      emotion.length,
      (i) => i < translated.length && translated[i].isNotEmpty ? translated[i] : emotion[i],
    );
  }

  /// Cheap text used for search-as-you-type, in [lang] (defaults to
  /// English). Always includes the English fields too, so a dua only
  /// partly translated is still findable by its original English text.
  String searchBlob([String lang = 'en']) => [
        duaNo,
        title,
        situation,
        transliteration,
        translation,
        emotion.join(' '),
        if (lang != 'en') ...[
          localizedTitle(lang),
          localizedSituation(lang),
          localizedTransliteration(lang),
          localizedTranslation(lang),
          localizedEmotion(lang).join(' '),
        ],
      ].join(' ').toLowerCase();
}
