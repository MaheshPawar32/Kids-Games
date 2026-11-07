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

  static const numbers = <String, String>{
    '0': 'assets/models/numbers/number_00.glb',
    '1': 'assets/models/numbers/number_01.glb',
    '2': 'assets/models/numbers/number_02.glb',
    '3': 'assets/models/numbers/number_03.glb',
    '4': 'assets/models/numbers/number_04.glb',
    '5': 'assets/models/numbers/number_05.glb',
    '6': 'assets/models/numbers/number_06.glb',
    '7': 'assets/models/numbers/number_07.glb',
    '8': 'assets/models/numbers/number_08.glb',
    '9': 'assets/models/numbers/number_09.glb',
    '10': 'assets/models/numbers/number_10.glb',
    '11': 'assets/models/numbers/number_11.glb',
    '12': 'assets/models/numbers/number_12.glb',
    '13': 'assets/models/numbers/number_13.glb',
    '14': 'assets/models/numbers/number_14.glb',
    '15': 'assets/models/numbers/number_15.glb',
    '16': 'assets/models/numbers/number_16.glb',
    '17': 'assets/models/numbers/number_17.glb',
    '18': 'assets/models/numbers/number_18.glb',
    '19': 'assets/models/numbers/number_19.glb',
    '20': 'assets/models/numbers/number_20.glb',
  };

  static const letters = <String, String>{
    'a': 'assets/models/letters/letter_a.glb',
    'b': 'assets/models/letters/letter_b.glb',
    'c': 'assets/models/letters/letter_c.glb',
    'd': 'assets/models/letters/letter_d.glb',
    'e': 'assets/models/letters/letter_e.glb',
    'f': 'assets/models/letters/letter_f.glb',
    'g': 'assets/models/letters/letter_g.glb',
    'h': 'assets/models/letters/letter_h.glb',
    'i': 'assets/models/letters/letter_i.glb',
    'j': 'assets/models/letters/letter_j.glb',
    'k': 'assets/models/letters/letter_k.glb',
    'l': 'assets/models/letters/letter_l.glb',
    'm': 'assets/models/letters/letter_m.glb',
    'n': 'assets/models/letters/letter_n.glb',
    'o': 'assets/models/letters/letter_o.glb',
    'p': 'assets/models/letters/letter_p.glb',
    'q': 'assets/models/letters/letter_q.glb',
    'r': 'assets/models/letters/letter_r.glb',
    's': 'assets/models/letters/letter_s.glb',
    't': 'assets/models/letters/letter_t.glb',
    'u': 'assets/models/letters/letter_u.glb',
    'v': 'assets/models/letters/letter_v.glb',
    'w': 'assets/models/letters/letter_w.glb',
    'x': 'assets/models/letters/letter_x.glb',
    'y': 'assets/models/letters/letter_y.glb',
    'z': 'assets/models/letters/letter_z.glb',
  };

  static const shapes = <String, String>{
    'cube': 'assets/models/shapes/cube.glb',
    'sphere': 'assets/models/shapes/sphere.glb',
    'cone': 'assets/models/shapes/cone.glb',
    'cylinder': 'assets/models/shapes/cylinder.glb',
    'triangular_prism': 'assets/models/shapes/triangular_prism.glb',
    'star': 'assets/models/shapes/star.glb',
    'heart': 'assets/models/shapes/heart.glb',
    'oval': 'assets/models/shapes/oval.glb',
    'rectangle': 'assets/models/shapes/rectangle.glb',
    'diamond': 'assets/models/shapes/diamond.glb',
  };

  static const props = <String, String>{
    'ball': 'assets/models/props/ball.glb',
    'treasure_chest': 'assets/models/props/treasure_chest.glb',
    'coin': 'assets/models/props/coin.glb',
    'reward_star': 'assets/models/props/reward_star.glb',
    'puzzle_piece': 'assets/models/props/puzzle_piece.glb',
    'tree': 'assets/models/props/tree.glb',
    'bush': 'assets/models/props/bush.glb',
    'rock': 'assets/models/props/rock.glb',
    'flower': 'assets/models/props/flower.glb',
    'cloud': 'assets/models/props/cloud.glb',
    'platform': 'assets/models/props/platform.glb',
  };

  static const environments = <String, String>{
    'playground_island': 'assets/models/environments/playground_island.glb',
    'animal_habitat': 'assets/models/environments/animal_habitat.glb',
    'learning_island': 'assets/models/environments/learning_island.glb',
  };

  static String iconPath(String id) {
    final path = icons[id];
    if (path == null) {
      throw ArgumentError.value(id, 'id', 'Unknown Kids Games 3D icon');
    }
    return path;
  }
}
