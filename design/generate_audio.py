"""Generates placeholder audio for Tap & Learn Kids:
  - one narration clip per word ("Apple", "Red", "Circle", ...)
  - feedback sound effects (correct / wrong)
  - a couple of short encouragement / celebration phrases

Everything is synthesized offline (espeak-ng for speech, numpy for tones)
so it needs no network access and no licensed sound packs. These are
meant as PLACEHOLDERS to make the game fully playable now; swap in
professional child-friendly voice-over and sound design before a real
Play Store launch.
"""
import os
import re
import subprocess
import numpy as np
from scipy.io import wavfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORDS_DIR = os.path.join(ROOT, "assets", "audio", "words")
SFX_DIR = os.path.join(ROOT, "assets", "audio", "sfx")
os.makedirs(WORDS_DIR, exist_ok=True)
os.makedirs(SFX_DIR, exist_ok=True)

VOICE = "en-us+f3"
SPEED = 140   # words per minute - slower & clearer for young kids
PITCH = 58

ALL_WORDS = {
    "fruits": ["Apple", "Banana", "Orange", "Grapes", "Watermelon", "Strawberry",
               "Mango", "Pineapple", "Pear", "Cherry", "Lemon", "Peach"],
    "animals": ["Dog", "Cat", "Lion", "Elephant", "Monkey", "Rabbit",
                "Horse", "Cow", "Tiger", "Bear", "Fox", "Pig"],
    "vehicles": ["Car", "Bus", "Bicycle", "Airplane", "Train", "Boat",
                 "Truck", "Helicopter", "Ambulance", "Motorcycle"],
    "colors": ["Red", "Blue", "Yellow", "Green", "Orange", "Purple",
               "Pink", "Brown", "Black", "White"],
    "shapes": ["Circle", "Square", "Triangle", "Rectangle", "Star",
               "Heart", "Diamond", "Oval"],
}

PHRASES = {
    "well_done": "Well done!",
    "great_job": "Great job!",
    "try_again": "Try again!",
    "lets_play": "Let's play!",
}


def slugify(word: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", word.lower()).strip("_")


def speak_to_mp3(text: str, out_path_no_ext: str):
    wav_path = out_path_no_ext + ".wav"
    mp3_path = out_path_no_ext + ".mp3"
    subprocess.run(
        ["espeak-ng", "-v", VOICE, "-s", str(SPEED), "-p", str(PITCH), "-w", wav_path, text],
        check=True, capture_output=True,
    )
    subprocess.run(
        ["ffmpeg", "-y", "-i", wav_path, "-ar", "44100", "-codec:a", "libmp3lame", "-qscale:a", "3", mp3_path],
        check=True, capture_output=True,
    )
    os.remove(wav_path)


def gen_words():
    seen = set()
    # Collect a de-duplicated slug -> word list (e.g. "Orange" appears in
    # both fruits and colors; the fruit word gets a distinct slug).
    for category, words in ALL_WORDS.items():
        for word in words:
            slug = slugify(word)
            if category == "colors":
                slug = f"color_{slug}"
            elif category == "shapes":
                slug = f"shape_{slug}"
            if slug in seen:
                continue
            seen.add(slug)
            speak_to_mp3(word, os.path.join(WORDS_DIR, slug))
    print(f"Generated {len(seen)} word narration clips.")


def gen_phrases():
    for slug, text in PHRASES.items():
        speak_to_mp3(text, os.path.join(WORDS_DIR, slug))
    print(f"Generated {len(PHRASES)} phrase clips.")


# ---------------- Sound effects (pure tone synthesis) ----------------

SR = 44100


def tone(freq, duration, vol=0.5, fade=0.015, shape="sine"):
    t = np.linspace(0, duration, int(SR * duration), endpoint=False)
    if shape == "sine":
        wave = np.sin(2 * np.pi * freq * t)
    elif shape == "square":
        wave = np.sign(np.sin(2 * np.pi * freq * t))
    else:
        wave = np.sin(2 * np.pi * freq * t)
    n_fade = int(SR * fade)
    if n_fade > 0 and n_fade * 2 < len(wave):
        env = np.ones_like(wave)
        env[:n_fade] = np.linspace(0, 1, n_fade)
        env[-n_fade:] = np.linspace(1, 0, n_fade)
        wave *= env
    return (wave * vol).astype(np.float64)


def save_wav_then_mp3(samples: np.ndarray, out_path_no_ext: str):
    samples = np.clip(samples, -1.0, 1.0)
    int_samples = (samples * 32767).astype(np.int16)
    wav_path = out_path_no_ext + ".wav"
    mp3_path = out_path_no_ext + ".mp3"
    wavfile.write(wav_path, SR, int_samples)
    subprocess.run(
        ["ffmpeg", "-y", "-i", wav_path, "-ar", "44100", "-codec:a", "libmp3lame", "-qscale:a", "3", mp3_path],
        check=True, capture_output=True,
    )
    os.remove(wav_path)


def gen_correct_sfx():
    # Cheerful ascending 3-note chime (C5, E5, G5)
    notes = [523.25, 659.25, 783.99]
    parts = []
    for f in notes:
        parts.append(tone(f, 0.14, vol=0.55))
        parts.append(np.zeros(int(SR * 0.02)))
    audio = np.concatenate(parts)
    save_wav_then_mp3(audio, os.path.join(SFX_DIR, "correct"))


def gen_wrong_sfx():
    # Short, gentle descending two-note "bonk" - not harsh, kid-friendly
    a = tone(330.0, 0.16, vol=0.45)
    b = tone(220.0, 0.22, vol=0.45)
    gap = np.zeros(int(SR * 0.02))
    audio = np.concatenate([a, gap, b])
    save_wav_then_mp3(audio, os.path.join(SFX_DIR, "wrong"))


def gen_win_sfx():
    # Little fanfare for the results screen
    notes = [523.25, 523.25, 659.25, 783.99, 1046.50]
    durs = [0.12, 0.12, 0.14, 0.14, 0.35]
    parts = []
    for f, d in zip(notes, durs):
        parts.append(tone(f, d, vol=0.5))
        parts.append(np.zeros(int(SR * 0.015)))
    audio = np.concatenate(parts)
    save_wav_then_mp3(audio, os.path.join(SFX_DIR, "win_fanfare"))


def gen_tap_sfx():
    # Very light UI tap click for category/button taps
    audio = tone(600, 0.05, vol=0.25, fade=0.005)
    save_wav_then_mp3(audio, os.path.join(SFX_DIR, "tap"))


if __name__ == "__main__":
    gen_words()
    gen_phrases()
    gen_correct_sfx()
    gen_wrong_sfx()
    gen_win_sfx()
    gen_tap_sfx()
    print("All audio assets generated.")
