import 'package:flutter/material.dart';

/// UI chrome text (button labels, headings, hints, empty states) in every
/// supported language. Deliberately a plain hand-rolled lookup rather than
/// `flutter gen-l10n`/ARB - this project has repeatedly hit friction with
/// anything needing an extra build/codegen step only reachable via a slow
/// Codemagic round-trip, and this stays fully verifiable with a normal
/// `flutter analyze` and the local web preview.
///
/// This covers the app's *interface* only. A dua's own content (title,
/// situation, translation, tafseer, emotion tags) is localized separately
/// via `Dua.localizedX(lang)` in lib/models/dua.dart, since those values
/// also double as grouping/lookup keys and can't simply be swapped.
///
/// Only languages with real content are listed per key today (en, te, ur) -
/// see LocaleService for why Arabic/Hindi aren't wired in yet. Falls back
/// to English if the active language or the key itself is missing, so
/// adding a new language is just adding entries here, never a breaking
/// change.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _values = {
    // Home
    'popular_duas': {'en': 'Popular duas', 'te': 'ప్రజాదరణ పొందిన దుఆలు', 'ur': 'مقبول دعائیں'},
    'recommended_duas': {'en': 'Recommended duas', 'te': 'సిఫారసు చేయబడిన దుఆలు', 'ur': 'تجویز کردہ دعائیں'},
    'share_app': {'en': 'Share app', 'te': 'యాప్‌ను షేర్ చేయండి', 'ur': 'ایپ شیئر کریں'},
    'favorites': {'en': 'Favorites', 'te': 'ఇష్టమైనవి', 'ur': 'پسندیدہ'},
    'hero_title': {
      'en': 'Enhance Your\nSpiritual Journey',
      'te': 'మీ ఆధ్యాత్మిక ప్రయాణాన్ని\nమెరుగుపరచుకోండి',
      'ur': 'اپنے روحانی سفر\nکو بہتر بنائیں',
    },
    'hero_subtitle': {'en': 'Connect, Reflect, and Renew', 'te': 'అనుసంధానం, ఆత్మపరిశీలన, పునరుద్ధరణ', 'ur': 'تعلق، غور و فکر اور تجدید'},
    'open_book': {'en': 'Open book', 'te': 'పుస్తకం తెరవండి', 'ur': 'کتاب کھولیں'},
    'share_app_text': {
      'en': 'Check out Bayan-udh-Dua - a collection of authentic duas, azkar and istighfar for daily recitation.',
      'te': 'బయాన్-ఉద్-దుఆ చూడండి - రోజువారీ పఠనానికి ప్రామాణికమైన దుఆలు, అజ్కార్ మరియు ఇస్తిగ్‌ఫార్ సేకరణ.',
      'ur': 'بیان الدعا ملاحظہ کریں - روزانہ پڑھنے کے لیے مستند دعاؤں، اذکار اور استغفار کا مجموعہ۔',
    },

    // Browse
    'by_number': {'en': 'By Number', 'te': 'సంఖ్య ప్రకారం', 'ur': 'نمبر کے مطابق'},
    'by_situation': {'en': 'By Situation', 'te': 'సందర్భం ప్రకారం', 'ur': 'صورتحال کے مطابق'},
    'by_emotion': {'en': 'By Emotion', 'te': 'భావోద్వేగం ప్రకారం', 'ur': 'جذبات کے مطابق'},
    'istighfar': {'en': 'Istighfar', 'te': 'ఇస్తిగ్‌ఫార్', 'ur': 'استغفار'},
    'first_chapter_title': {
      'en': 'First Chapter - Ghair Muwaqqat (1-70)',
      'te': 'మొదటి అధ్యాయం - గైర్ మువఖ్ఖత్ (1-70)',
      'ur': 'پہلا باب - غیر موقت (1-70)',
    },
    'first_chapter_subtitle': {
      'en': 'Duas read daily and at all times',
      'te': 'ప్రతిరోజూ మరియు అన్ని సమయాల్లో పఠించే దుఆలు',
      'ur': 'وہ دعائیں جو روزانہ اور ہر وقت پڑھی جاتی ہیں',
    },
    'second_chapter_title': {
      'en': 'Second Chapter - Muwaqqat (71-110)',
      'te': 'రెండవ అధ్యాయం - మువఖ్ఖత్ (71-110)',
      'ur': 'دوسرا باب - موقت (71-110)',
    },
    'second_chapter_subtitle': {
      'en': 'In this chapter, those duas are mentioned which are read at times of sickness, calamities and other such occasions',
      'te': 'ఈ అధ్యాయంలో, అనారోగ్యం, ఆపదలు మరియు అలాంటి ఇతర సందర్భాలలో పఠించే దుఆలు పేర్కొనబడ్డాయి',
      'ur': 'اس باب میں وہ دعائیں بیان کی گئی ہیں جو بیماری، مصیبتوں اور ایسے دیگر مواقع پر پڑھی جاتی ہیں',
    },
    'morning_evening_duas': {'en': 'Morning & Evening Duas', 'te': 'ఉదయం & సాయంత్రం దుఆలు', 'ur': 'صبح و شام کی دعائیں'},
    'dua_after_salah': {'en': 'Dua after Salah', 'te': 'నమాజు తర్వాత దుఆ', 'ur': 'نماز کے بعد کی دعا'},
    'nothing_here_yet': {'en': 'Nothing here yet', 'te': 'ఇక్కడ ఇంకా ఏమీ లేదు', 'ur': 'ابھی یہاں کچھ نہیں'},

    // Search
    'search': {'en': 'Search', 'te': 'శోధించు', 'ur': 'تلاش کریں'},
    'search_hint': {
      'en': 'Search by dua number, situation or emotion',
      'te': 'దుఆ సంఖ్య, సందర్భం లేదా భావోద్వేగం ద్వారా శోధించండి',
      'ur': 'دعا نمبر، صورتحال یا جذبات کے ذریعے تلاش کریں',
    },
    'clear': {'en': 'Clear', 'te': 'తొలగించు', 'ur': 'صاف کریں'},
    'search_examples': {
      'en': 'Try "travel", "forgiveness", "sleep", or "anxious"',
      'te': '"ప్రయాణం", "క్షమాపణ", "నిద్ర", లేదా "ఆందోళన" అని ప్రయత్నించండి',
      'ur': '"سفر"، "بخشش"، "نیند"، یا "بے چینی" آزمائیں',
    },
    'no_duas_found': {'en': 'No duas found', 'te': 'దుఆలు కనుగొనబడలేదు', 'ur': 'کوئی دعا نہیں ملی'},
    'all_duas': {'en': 'All Duas', 'te': 'అన్ని దుఆలు', 'ur': 'تمام دعائیں'},

    // Favorites
    'favorites_empty': {
      'en': 'Tap the heart on any dua to save it here for quick access.',
      'te': 'త్వరిత యాక్సెస్ కోసం ఇక్కడ సేవ్ చేయడానికి ఏదైనా దుఆపై హృదయాన్ని నొక్కండి.',
      'ur': 'کسی بھی دعا پر دل کے نشان کو دبائیں تاکہ اسے یہاں فوری رسائی کے لیے محفوظ کیا جا سکے۔',
    },

    // Bottom nav
    'nav_home': {'en': 'Home', 'te': 'హోమ్', 'ur': 'ہوم'},
    'nav_browse': {'en': 'Browse', 'te': 'బ్రౌజ్', 'ur': 'براؤز'},
    'nav_search': {'en': 'Search', 'te': 'శోధించు', 'ur': 'تلاش'},
    'nav_favorites': {'en': 'Favorites', 'te': 'ఇష్టమైనవి', 'ur': 'پسندیدہ'},

    // Onboarding
    'skip': {'en': 'Skip', 'te': 'దాటవేయి', 'ur': 'نظرانداز کریں'},
    'finish': {'en': 'Finish', 'te': 'ముగించు', 'ur': 'ختم کریں'},
    'next': {'en': 'Next', 'te': 'తదుపరి', 'ur': 'اگلا'},
    'onboard_1_title': {'en': 'Over 100 Duas', 'te': '100కి పైగా దుఆలు', 'ur': '100 سے زائد دعائیں'},
    'onboard_1_subtitle': {
      'en': 'Recite from over 100 duas suited to your needs',
      'te': 'మీ అవసరాలకు తగిన 100కి పైగా దుఆల నుండి పఠించండి',
      'ur': 'اپنی ضرورت کے مطابق 100 سے زائد دعاؤں میں سے پڑھیں',
    },
    'onboard_2_title': {'en': 'Bookmarked Dua', 'te': 'బుక్‌మార్క్ చేసిన దుఆ', 'ur': 'محفوظ شدہ دعا'},
    'onboard_2_subtitle': {
      'en': 'Access your bookmarked duas from your favourites list',
      'te': 'మీ ఇష్టాంశాల జాబితా నుండి బుక్‌మార్క్ చేసిన దుఆలను యాక్సెస్ చేయండి',
      'ur': 'اپنی پسندیدہ فہرست سے محفوظ شدہ دعاؤں تک رسائی حاصل کریں',
    },
    'onboard_3_title': {'en': 'Set Reminder', 'te': 'రిమైండర్ సెట్ చేయండి', 'ur': 'یاد دہانی مقرر کریں'},
    'onboard_3_subtitle': {
      'en': 'Set reminders to recite your specific dua',
      'te': 'మీ నిర్దిష్ట దుఆను పఠించడానికి రిమైండర్‌లను సెట్ చేయండి',
      'ur': 'اپنی مخصوص دعا پڑھنے کے لیے یاد دہانیاں مقرر کریں',
    },
    'onboard_4_title': {'en': 'Download Dua', 'te': 'దుఆ డౌన్‌లోడ్ చేయండి', 'ur': 'دعا ڈاؤن لوڈ کریں'},
    'onboard_4_subtitle': {
      'en': 'Download dua to recite them at your convenience',
      'te': 'మీ అనుకూలత ప్రకారం పఠించడానికి దుఆను డౌన్‌లోడ్ చేయండి',
      'ur': 'اپنی سہولت کے مطابق پڑھنے کے لیے دعا ڈاؤن لوڈ کریں',
    },

    // Dua detail
    'dua_section': {'en': 'Dua', 'te': 'దుఆ', 'ur': 'دعا'},
    'transliteration': {'en': 'Transliteration', 'te': 'లిప్యంతరీకరణ', 'ur': 'تلفظ'},
    'translation': {'en': 'Translation', 'te': 'అనువాదం', 'ur': 'ترجمہ'},
    'tafseer': {'en': 'Tafseer', 'te': 'తఫ్సీర్', 'ur': 'تفسیر'},
    'share': {'en': 'Share', 'te': 'షేర్', 'ur': 'شیئر کریں'},
    'reminder': {'en': 'Reminder', 'te': 'రిమైండర్', 'ur': 'یاد دہانی'},
    'favourite': {'en': 'Favourite', 'te': 'ఇష్టం', 'ur': 'پسندیدہ'},
    'reminders_title': {'en': 'Reminders', 'te': 'రిమైండర్‌లు', 'ur': 'یاد دہانیاں'},
    'reminders_subtitle': {
      'en': 'Set one or more times to be reminded to recite this dua every day.',
      'te': 'ఈ దుఆను ప్రతిరోజూ పఠించమని గుర్తు చేయడానికి ఒకటి లేదా అంతకంటే ఎక్కువ సమయాలను సెట్ చేయండి.',
      'ur': 'اس دعا کو روزانہ پڑھنے کی یاد دہانی کے لیے ایک یا زیادہ اوقات مقرر کریں۔',
    },
    'no_reminders_yet': {'en': 'No reminders set yet.', 'te': 'ఇంకా రిమైండర్‌లు సెట్ చేయలేదు.', 'ur': 'ابھی تک کوئی یاد دہانی مقرر نہیں کی گئی۔'},
    'remove': {'en': 'Remove', 'te': 'తొలగించు', 'ur': 'ہٹائیں'},
    'add_reminder_time': {'en': 'Add a reminder time', 'te': 'రిమైండర్ సమయాన్ని జోడించండి', 'ur': 'یاد دہانی کا وقت شامل کریں'},
    'shared_from_app': {
      'en': '- shared from Bayan-udh-Dua',
      'te': '- బయాన్-ఉద్-దుఆ నుండి షేర్ చేయబడింది',
      'ur': '- بیان الدعا سے شیئر کیا گیا',
    },

    // Language picker
    'language': {'en': 'Language', 'te': 'భాష', 'ur': 'زبان'},
    'select_language': {'en': 'Select language', 'te': 'భాషను ఎంచుకోండి', 'ur': 'زبان منتخب کریں'},
  };

  static String of(BuildContext context, String key) {
    return forLang(Localizations.localeOf(context).languageCode, key);
  }

  /// Same lookup as [of], but for the rare place (e.g. DuaRepository's
  /// book-section labels) that needs a UI string without a BuildContext
  /// on hand - just the already-known active language code.
  static String forLang(String lang, String key) {
    return _values[key]?[lang] ?? _values[key]?['en'] ?? key;
  }

  /// "N dua(s)" - English pluralizes, Telugu uses one word for any count,
  /// Urdu pluralizes (دعا / دعائیں).
  static String duasCount(BuildContext context, int n) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'te') return '$n దుఆలు';
    if (lang == 'ur') return '$n ${n == 1 ? 'دعا' : 'دعائیں'}';
    return '$n ${n == 1 ? 'dua' : 'duas'}';
  }

  /// "N reminder(s)" - used only when 2+ (the 1-reminder case shows its
  /// time instead), but written to handle any count.
  static String remindersCount(BuildContext context, int n) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'te') return '$n రిమైండర్‌లు';
    if (lang == 'ur') return '$n ${n == 1 ? 'یاد دہانی' : 'یاد دہانیاں'}';
    return '$n ${n == 1 ? 'reminder' : 'reminders'}';
  }
}
