import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../data/repositories/game_session_repository.dart';

/// Initializes the app's local Hive CE database before the first screen.
class KidsGamesDatabase {
  const KidsGamesDatabase._();

  static Future<void> initialize() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(HiveGameSessionRepository.boxName)) {
      await Hive.openBox<dynamic>(HiveGameSessionRepository.boxName);
    }
  }
}
