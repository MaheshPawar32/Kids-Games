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
