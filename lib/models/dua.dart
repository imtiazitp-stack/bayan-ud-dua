/// A single Dua entry, loaded from assets/data/duas.json.
///
/// This mirrors the "Master Data" sheet in BUD_Content_Structure_v6.1.xlsx
/// so the app's data model stays in sync with how the team already thinks
/// about the content (situation + emotion tagging, page reference, etc).
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
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
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
    );
  }

  /// Cheap text used for search-as-you-type.
  String get searchBlob => [
        duaNo,
        title,
        situation,
        transliteration,
        translation,
        emotion.join(' '),
      ].join(' ').toLowerCase();
}
