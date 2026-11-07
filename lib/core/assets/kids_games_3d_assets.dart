/// Canonical paths for original Kids Games 3D source assets.
class KidsGames3DAssets {
  KidsGames3DAssets._();

  static const babyLion = 'assets/models/characters/baby_lion.glb';

  static const icons = <String, String>{
    'star': 'assets/models/icons/star.glb',
    'trophy': 'assets/models/icons/trophy.glb',
    'gift': 'assets/models/icons/gift.glb',
    'heart': 'assets/models/icons/heart.glb',
    'home': 'assets/models/icons/home.glb',
    'book': 'assets/models/icons/book.glb',
    'settings': 'assets/models/icons/settings.glb',
    'sound': 'assets/models/icons/sound.glb',
    'play': 'assets/models/icons/play.glb',
    'pause': 'assets/models/icons/pause.glb',
    'lock': 'assets/models/icons/lock.glb',
    'medal': 'assets/models/icons/medal.glb',
    'puzzle_piece': 'assets/models/icons/puzzle_piece.glb',
  };

  static String iconPath(String id) {
    final path = icons[id];
    if (path == null) {
      throw ArgumentError.value(id, 'id', 'Unknown Kids Games 3D icon');
    }
    return path;
  }
}
