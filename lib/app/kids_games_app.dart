import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../features/home/home_screen.dart';

class KidsGamesApp extends StatelessWidget {
  const KidsGamesApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Kids Games',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      );
}
