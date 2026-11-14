import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';

/// Short sound effects used across games.
enum GameSound {
  tap('tap.wav'),
  correct('correct.wav'),
  wrong('wrong.wav'),
  star('star.wav'),
  levelComplete('level_complete.wav');

  const GameSound(this.file);

  final String file;
}

abstract interface class SoundPlayer {
  Future<void> play(GameSound sound);
}

/// Plays bundled, original WAV effects through Flame Audio pools.
///
/// Pools reuse a fixed number of native players, so rapid taps never create
/// unbounded players. [isEnabled] is read on every call so the parent's
/// sound setting applies immediately; nothing loads while sound is off.
class FlameSoundPlayer implements SoundPlayer {
  FlameSoundPlayer({required this.isEnabled, this.volume = 0.7});

  final bool Function() isEnabled;
  final double volume;
  final Map<GameSound, Future<AudioPool>> _pools = {};

  @override
  Future<void> play(GameSound sound) async {
    if (!isEnabled()) return;
    try {
      final pool = await (_pools[sound] ??= FlameAudio.createPool(
        sound.file,
        maxPlayers: 2,
      ));
      await pool.start(volume: volume);
    } on Object {
      // Audio is optional feedback; a device without audio output must
      // never interrupt play.
      _pools.remove(sound);
    }
  }

  Future<void> dispose() async {
    for (final pool in _pools.values) {
      try {
        await (await pool).dispose();
      } on Object {
        // Already released.
      }
    }
    _pools.clear();
  }
}

class SilentSoundPlayer implements SoundPlayer {
  const SilentSoundPlayer();

  @override
  Future<void> play(GameSound sound) async {}
}

/// App-wide services and child-facing settings chosen by a parent.
class AppServices extends InheritedWidget {
  const AppServices({
    required this.sounds,
    required this.reducedMotion,
    required super.child,
    super.key,
  });

  final SoundPlayer sounds;

  /// Parent setting; the platform "remove animations" flag also applies.
  final bool reducedMotion;

  static const _fallback = AppServices(
    sounds: SilentSoundPlayer(),
    reducedMotion: false,
    child: SizedBox.shrink(),
  );

  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppServices>() ?? _fallback;

  /// True when animations should be minimised.
  static bool reduceMotion(BuildContext context) =>
      of(context).reducedMotion ||
      (MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  @override
  bool updateShouldNotify(AppServices oldWidget) =>
      sounds != oldWidget.sounds || reducedMotion != oldWidget.reducedMotion;
}
