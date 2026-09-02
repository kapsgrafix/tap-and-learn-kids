# Tap & Learn Kids — Phase 1

A tap-to-recognize early-learning game for kids, built with Flutter so it can
be packaged as a real installable Android app for the Play Store.

## What's in phase 1

One game: **Recognition**. The child picks a category (Fruits, Animals,
Colors, Vehicles, Shapes), then for 10 questions sees/hears a word (e.g.
"Apple" shown on screen + spoken aloud) and taps the matching picture out
of a 2x2 grid. Correct = green tick + cheerful chime, auto-advances. Wrong
= red cross + gentle buzz, they try again. After question 10, a "Well
Done!" screen with confetti offers **Play Again** or **Home**.

- Mascot: **Ollie the Owl**, drawn as vector art (`design/gen_icon.py`),
  used for the app icon and on the Home/Results screens.
- Word narration and the correct/wrong/win sound effects are all
  synthesized offline (`design/generate_audio.py`) as **placeholders** —
  fully playable today, meant to be swapped for real voice-over/sound
  design before a public launch (see "Before you publish" below).
- Categories/words live in one place: `lib/data/categories_data.dart`.
  Adding a new item to an existing category is just adding one line
  there (plus generating its audio clip).

## Project layout

```
lib/
  main.dart                 - app entry point, portrait lock, theme
  theme/app_theme.dart       - brand colors, shared styling constants
  models/                    - GameItem, GameCategory data classes
  data/categories_data.dart  - the 5 categories and their words
  services/audio_service.dart - narration + sfx playback
  screens/                   - Home, CategorySelect, Game, Result
  widgets/                   - OptionCard, ShapeIcon, mascot, buttons, confetti
assets/
  audio/words/  - one narration clip per word
  audio/sfx/    - correct.mp3, wrong.mp3, win_fanfare.mp3, tap.mp3
  images/       - mascot_ollie.png
design/
  gen_icon.py         - regenerates the mascot/app icon artwork
  generate_audio.py   - regenerates all placeholder audio
android/            - standard Flutter Android project (Gradle)
store/              - 512x512 Play Store listing icon + 1024 master
```

## Running it locally

This was built in a sandboxed environment without access to
`storage.googleapis.com` / `dl.google.com` / `pub.dev`, so it could not be
`flutter pub get` / built / tested in that environment. On a normal
machine with the Flutter SDK installed:

```
flutter pub get
flutter analyze
flutter test
flutter run            # on a connected device/emulator
flutter build apk --release      # a real installable APK
flutter build appbundle --release  # the .aab Play Store wants for upload
```

If `flutter` isn't installed yet: https://docs.flutter.dev/get-started/install

### Or: build via GitHub Actions (no local install needed)

`.github/workflows/build-apk.yml` builds a release APK on every push to
`main` (and on manual trigger) and uploads it as a downloadable workflow
artifact — useful for getting a testable APK without installing Flutter
yourself. It's signed with the Flutter debug key (fine for sideloading
onto your own phone to test; not what you'd use for the actual Play
Store upload — see "Before you publish" below).

## Before you publish to the Play Store

This phase-1 build is functionally complete but there are real business/
legal steps outside of code that still need doing:

1. **Package name.** Currently `com.kapsgrafix.taplearnkids`
   (`android/app/build.gradle`, `AndroidManifest.xml`,
   `MainActivity.kt`). This is permanent once you publish — decide the
   final one first.
2. **Release signing key.** Copy `android/key.properties.example` to
   `android/key.properties`, generate a keystore (command is in that
   file), and fill it in before running `flutter build appbundle
   --release`. Keep that keystore file safe — losing it means you can
   never update the app again under the same listing.
3. **Replace placeholder audio.** The current word narration and sound
   effects are synthesized (robotic TTS + simple tones) so the game is
   playable now. Swap in real, warm, child-friendly voice-over and sound
   design before launch — this matters a lot for a kids' app.
4. **Play Store "Designed for Families" / target-audience requirements.**
   Since this targets children, Google requires: a privacy policy URL
   (the app itself collects no data and needs no permissions, which
   makes this easier, but the policy page is still required), completing
   the **Data safety** form, declaring the target age group in Play
   Console, and following the Families Policy content guidelines. No ads
   or third-party trackers are included in phase 1, which keeps this
   simple — keep it that way unless you review the policy implications
   first.
5. **Store listing assets.** `store/play_store_icon_512.png` is ready to
   use as the app icon. You'll still need: a feature graphic (1024x500),
   at least 2 phone screenshots, a short and full description, and a
   content rating questionnaire completed in Play Console.
6. **App name/branding.** "Tap & Learn Kids" and Ollie the Owl are
   placeholders — rename freely (search for "Tap & Learn Kids" and
   "Ollie" across the project).

## Roadmap (future phases)

This app is planned to grow into multiple games. `lib/models` and
`lib/data` are deliberately generic (a category is just a name + a list
of recognizable items) so a second game mode can reuse the same data
instead of duplicating it.
