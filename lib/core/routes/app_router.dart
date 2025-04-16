import 'package:flutter/material.dart';
import '../../features/main/presentation/pages/main_page.dart';
import '../../features/journal/presentation/screens/journal_screen.dart';
import '../../features/journal/presentation/screens/ai_journal_screen.dart';
import '../../features/journal/data/models/journal_entry.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract the tab index from the route name if it exists
    final uri = Uri.parse(settings.name ?? '/');
    final isJournalTab = uri.queryParameters['tab'] == '2'; // Journal tab index is 2

    switch (uri.path) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainPage());
        
      // Journal routes - only accessible from journal tab
      case '/journal':
        return isJournalTab
            ? MaterialPageRoute(builder: (_) => const JournalScreen())
            : _errorRoute('Journal can only be accessed from the journal tab');
            
      case '/journal/five_whys':
        return isJournalTab
            ? MaterialPageRoute(builder: (_) => const AIJournalScreen(mode: 'five_whys'))
            : _errorRoute('Five Whys can only be accessed from the journal tab');
            
      case '/journal/suggestions':
        return isJournalTab
            ? MaterialPageRoute(builder: (_) => const AIJournalScreen(mode: 'suggestions'))
            : _errorRoute('Journaling suggestions can only be accessed from the journal tab');
            
      case '/journal/mood':
        return isJournalTab
            ? MaterialPageRoute(builder: (_) => const AIJournalScreen(mode: 'mood'))
            : _errorRoute('Mood check-in can only be accessed from the journal tab');
            
      case '/journal/empty':
        return isJournalTab
            ? MaterialPageRoute(builder: (_) => const AIJournalScreen(mode: 'empty'))
            : _errorRoute('Empty journal can only be accessed from the journal tab');
            
      case '/journal/custom':
        final args = settings.arguments as Map<String, dynamic>?;
        return isJournalTab
            ? MaterialPageRoute(
                builder: (_) => AIJournalScreen(
                  mode: 'custom',
                  entry: args?['entry'] as JournalEntry?,
                ),
              )
            : _errorRoute('Custom journal can only be accessed from the journal tab');
            
      default:
        return _errorRoute('Route not found');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(_).pushNamedAndRemoveUntil('/', (route) => false),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 