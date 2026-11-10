import 'package:flutter/material.dart';

import 'app/kids_games_app.dart';
import 'core/persistence/kids_games_database.dart';
import 'data/repositories/game_session_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KidsGamesDatabase.initialize();
  runApp(
    KidsGamesApp(gameSessionRepository: HiveGameSessionRepository()),
  );
}
