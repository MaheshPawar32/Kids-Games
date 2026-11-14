import 'package:flutter/material.dart';

import 'app/kids_games_app.dart';
import 'core/persistence/kids_games_database.dart';
import 'core/services/app_services.dart';
import 'data/repositories/game_session_repository.dart';
import 'data/repositories/level_progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KidsGamesDatabase.initialize();
  runApp(
    KidsGamesApp(
      gameSessionRepository: HiveGameSessionRepository(),
      levelProgressRepository: HiveLevelProgressRepository(),
      soundPlayerFactory: (isEnabled) => FlameSoundPlayer(isEnabled: isEnabled),
    ),
  );
}
