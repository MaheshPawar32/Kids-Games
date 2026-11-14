"""Synthesises the original Kids Games sound effects into assets/audio/.

All sounds are generated from sine partials with soft envelopes, so they are
original works with no third-party licence. Re-run after editing:

    python3 tool/generate_sounds.py
"""
import math
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parent.parent / "assets" / "audio"


def note(freq, start, length, volume=0.5, partials=(1.0, 0.35, 0.12)):
    """Bell-like tone: harmonics with a fast attack and exponential decay."""
    return (freq, start, length, volume, partials)


def render(notes, total):
    samples = [0.0] * int(RATE * total)
    for freq, start, length, volume, partials in notes:
        first = int(start * RATE)
        count = int(length * RATE)
        for i in range(count):
            t = i / RATE
            attack = min(1.0, t / 0.008)
            envelope = attack * math.exp(-4.5 * t / length)
            value = sum(
                amp * math.sin(2 * math.pi * freq * (k + 1) * t)
                for k, amp in enumerate(partials)
            )
            index = first + i
            if index < len(samples):
                samples[index] += value * envelope * volume
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = min(1.0, 0.8 / peak)
    # Short fade-out removes clicks at the end of the file.
    fade = int(0.01 * RATE)
    for i in range(fade):
        samples[-1 - i] *= i / fade
    return [s * scale for s in samples]


def save(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / name), "wb") as file:
        file.setnchannels(1)
        file.setsampwidth(2)
        file.setframerate(RATE)
        file.writeframes(
            b"".join(struct.pack("<h", int(s * 32767)) for s in samples)
        )


C5, E5, G5, C6, E6, G6 = 523.25, 659.25, 783.99, 1046.5, 1318.5, 1568.0

save("tap.wav", render([note(880, 0, 0.07, 0.4, (1.0, 0.2))], 0.08))
save(
    "correct.wav",
    render([note(C6, 0, 0.25), note(E6, 0.08, 0.25), note(G6, 0.16, 0.35)], 0.52),
)
save(
    "wrong.wav",
    render(
        [note(392, 0, 0.18, 0.35, (1.0, 0.1)), note(330, 0.15, 0.25, 0.35, (1.0, 0.1))],
        0.42,
    ),
)
save(
    "star.wav",
    render([note(1760 + i * 220, i * 0.04, 0.18, 0.25) for i in range(6)], 0.42),
)
save(
    "level_complete.wav",
    render(
        [
            note(C5, 0.0, 0.3),
            note(E5, 0.12, 0.3),
            note(G5, 0.24, 0.3),
            note(C6, 0.36, 0.9, 0.45),
            note(E5, 0.36, 0.9, 0.3),
            note(G5, 0.36, 0.9, 0.3),
        ],
        1.3,
    ),
)
print("Wrote", sorted(p.name for p in OUT.glob("*.wav")))
