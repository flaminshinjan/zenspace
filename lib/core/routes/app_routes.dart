import 'package:flutter/material.dart';
import '../../features/journal/presentation/screens/journal_screen.dart';
import '../../features/journal/presentation/screens/ai_journal_screen.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/journal/five_whys':
        return MaterialPageRoute(
          builder: (_) => const AIJournalScreen(mode: 'five_whys'),
        );
      case '/journal/suggestions':
        return MaterialPageRoute(
          builder: (_) => const AIJournalScreen(mode: 'suggestions'),
        );
      case '/journal/mood':
        return MaterialPageRoute(
          builder: (_) => const AIJournalScreen(mode: 'mood'),
        );
      case '/journal/empty':
        return MaterialPageRoute(
          builder: (_) => const AIJournalScreen(mode: 'empty'),
        );
      case '/journal/custom':
        return MaterialPageRoute(
          builder: (_) => const AIJournalScreen(mode: 'custom'),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 