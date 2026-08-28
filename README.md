# Bayan-udh-Dua — Flutter rebuild

This replaces the native Android app with one codebase that builds for
both **Android** and **iOS**.

## What's already done

- **Real content, wired in**: `assets/data/duas.json` — all 140 duas
  extracted directly from `BUD_Content_Structure_v6.1.xlsx` (Arabic,
  transliteration, translation, tafsir, situation + emotion tags, page
  reference in the book).
- **Two working taxonomies**: Browse by *Situation* (Travel, Sleep,
  Forgiveness, etc.) or by *Emotion* (Guilt, Fear, Gratitude, etc.) —
  both pulled straight from the team's own spreadsheet, not invented.
- **Screens**: Browse (tabs), Search (live filter), Favorites
  (on-device, no login), Dua detail (Arabic + transliteration +
  translation + tafsir + audio play button).
- **Offline by default**: everything is a bundled JSON asset — no
  server, no internet needed to use the app.

## What's NOT done yet (needs a developer)

1. **Audio files**: `assets/audio/` is empty. Drop in the mp3s from
   the Drive `BUD` folder, named to match `duas.json`'s `audio` field
   (e.g. `dua_001.mp3`, `dua_002.mp3`...). The Drive files use the
   *book's* dua number (`Dua No. 1.mp3`), which doesn't always match
   1-to-1 with `appId` because of sub-numbered duas (5a/5b, etc.) — the
   dev should map these by checking `duaNo` in duas.json against the
   Drive filenames.
2. **Visual design**: this scaffold uses default Material 3 styling.
   Apply the actual Figma (`BuD_All`) — colors, typography, spacing,
   icons — the file is in Drive.
3. **Onboarding screens**: the spreadsheet's "Onboarding" tab has 10
   rows of intro copy — not yet built into a screen.
4. **App icon, splash screen, store listings** for both platforms.
5. **Testing on real devices** and submission to Play Store + App
   Store (needs Apple Developer account for iOS, ~$99/year).

## How to run this (for the developer)

```bash
# 1. Install Flutter: https://docs.flutter.dev/get-started/install
flutter doctor        # confirms your setup is ready

# 2. From this project folder:
flutter pub get       # installs dependencies

# 3. Run on a connected device or simulator:
flutter run

# 4. Build a release Android app bundle:
flutter build appbundle

# 5. Build for iOS (requires a Mac + Xcode):
flutter build ios
```

## Project structure

```
lib/
  models/dua.dart              # the Dua data shape
  services/dua_repository.dart # loads & queries duas.json
  services/favorites_service.dart
  screens/                     # one file per screen
assets/data/duas.json          # the actual dua content
assets/data/situations.json    # situation taxonomy (114 entries)
assets/data/emotions.json      # emotion taxonomy (88 entries)
assets/audio/                  # mp3s go here (see above)
```

## Suggestion for your dev

If they haven't used Flutter before but know Kotlin, it's a very
comfortable jump — similar structure, statically typed, and this
codebase is intentionally kept simple (no state-management library,
no backend). Claude Code can also pair with them directly in their
own terminal to speed this up.
