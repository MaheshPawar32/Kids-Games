import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/core/assets/kids_games_3d_assets.dart';

void main() {
  group('KidsGames3DAssets', () {
    test('contains 13 unique independently loadable 3D icons', () {
      expect(KidsGames3DAssets.icons, hasLength(13));
      expect(
        KidsGames3DAssets.icons.values.toSet(),
        hasLength(KidsGames3DAssets.icons.length),
      );
    });

    test('catalogs all educational 3D asset groups', () {
      expect(KidsGames3DAssets.numbers, hasLength(21));
      expect(KidsGames3DAssets.letters, hasLength(26));
      expect(KidsGames3DAssets.shapes, hasLength(10));
      expect(KidsGames3DAssets.props, hasLength(11));
      expect(KidsGames3DAssets.environments, hasLength(3));
      expect(
        KidsGames3DAssets.numbers['20'],
        'assets/models/numbers/number_20.glb',
      );
      expect(
        KidsGames3DAssets.letters['z'],
        'assets/models/letters/letter_z.glb',
      );
    });

    test('resolves the trophy icon path', () {
      expect(
        KidsGames3DAssets.iconPath('trophy'),
        'assets/models/icons/trophy.glb',
      );
    });

    test('rejects unknown icon identifiers', () {
      expect(
        () => KidsGames3DAssets.iconPath('not-an-icon'),
        throwsArgumentError,
      );
    });
  });
}
