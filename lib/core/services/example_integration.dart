/// Example Integration
/// 
/// This file demonstrates how to integrate the API services
/// with your existing ZenSpace app.

import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'journal_service_api.dart';
import 'chat_service_api.dart';
import 'meditation_service_api.dart';
import 'user_service_api.dart';

/// ============================================================================
/// EXAMPLE 1: Authentication Integration
/// ============================================================================

class AuthExample {
  final authService = AuthService();

  /// Login with email and password
  Future<void> loginExample(BuildContext context) async {
    final response = await authService.login(
      email: 'user@example.com',
      password: 'password123',
    );

    if (response.success) {
      // Success - tokens are automatically saved
      print('Login successful!');
      print('User: ${response.data}');
      
      // Navigate to main page
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } else {
      // Error
      print('Login failed: ${response.error?.message}');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error?.message ?? 'Login failed')),
        );
      }
    }
  }

  /// Register new user
  Future<void> registerExample(BuildContext context) async {
    final response = await authService.register(
      email: 'newuser@example.com',
      password: 'password123',
      fullName: 'John Doe',
    );

    if (response.success) {
      print('Registration successful!');
      // Navigate to onboarding or main page
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } else {
      print('Registration failed: ${response.error?.message}');
    }
  }

  /// OAuth Login (Google)
  Future<void> googleLoginExample(BuildContext context) async {
    // First, get Google credentials using google_sign_in package
    // final GoogleSignIn googleSignIn = GoogleSignIn();
    // final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    // final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    
    // Then use our API service
    final response = await authService.oauthLogin(
      provider: 'google',
      idToken: 'google-id-token', // Use googleAuth.idToken
      accessToken: 'google-access-token', // Use googleAuth.accessToken
    );

    if (response.success) {
      print('Google login successful!');
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  /// Logout
  Future<void> logoutExample(BuildContext context) async {
    final response = await authService.logout();
    
    // Clear local data
    // Navigate to login page
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

/// ============================================================================
/// EXAMPLE 2: Journal Integration
/// ============================================================================

class JournalExample {
  final journalApi = JournalServiceApi();

  /// Create a journal entry
  Future<void> createEntryExample() async {
    final response = await journalApi.createEntry(
      content: 'Today was a great day! I felt accomplished and happy.',
      mood: 'happy',
      mode: 'reflection',
      tags: ['gratitude', 'productivity'],
      isPrivate: true,
    );

    if (response.success) {
      print('Entry created: ${response.data}');
      final entryId = response.data!['id'];
      print('Entry ID: $entryId');
    } else {
      print('Error: ${response.error?.message}');
    }
  }

  /// Get journal entries with pagination
  Future<List<Map<String, dynamic>>> getEntriesExample() async {
    final response = await journalApi.getEntries(
      page: 1,
      limit: 20,
    );

    if (response.success && response.data != null) {
      final entries = response.data!['entries'] as List;
      print('Loaded ${entries.length} entries');
      
      return entries.cast<Map<String, dynamic>>();
    }
    
    return [];
  }

  /// Get AI-powered journal suggestions
  Future<void> getAiSuggestionsExample() async {
    final response = await journalApi.getAiSuggestions(
      mode: 'reflection',
      mood: 'anxious',
      context: 'Had a stressful day at work with difficult meetings',
    );

    if (response.success && response.data != null) {
      print('AI Suggestions:');
      final suggestions = response.data!['suggestions'] as List;
      for (var suggestion in suggestions) {
        print('- $suggestion');
      }
      
      final prompt = response.data!['prompt'];
      print('Opening Prompt: $prompt');
    }
  }

  /// Update an existing entry
  Future<void> updateEntryExample(String entryId) async {
    final response = await journalApi.updateEntry(
      entryId: entryId,
      content: 'Updated content with more details...',
      mood: 'calm',
      tags: ['updated', 'reflection', 'growth'],
    );

    if (response.success) {
      print('Entry updated successfully');
    }
  }

  /// Delete an entry
  Future<void> deleteEntryExample(String entryId) async {
    final response = await journalApi.deleteEntry(entryId);

    if (response.success) {
      print('Entry deleted successfully');
    }
  }

  /// Get mood analytics
  Future<void> getMoodAnalyticsExample() async {
    final response = await journalApi.getMoodAnalytics(
      startDate: '2024-01-01',
      endDate: '2024-01-31',
    );

    if (response.success && response.data != null) {
      print('Mood Analytics:');
      print(response.data);
    }
  }
}

/// ============================================================================
/// EXAMPLE 3: AI Chat Integration
/// ============================================================================

class ChatExample {
  final chatApi = ChatServiceApi();

  /// Get available companions
  Future<void> getCompanionsExample() async {
    final response = await chatApi.getCompanions();

    if (response.success && response.data != null) {
      final companions = response.data!['companions'] as List;
      print('Available companions:');
      for (var companion in companions) {
        print('- ${companion['name']}: ${companion['description']}');
      }
    }
  }

  /// Start a chat session
  Future<String?> startChatSessionExample() async {
    // First, get companions
    final companionsResponse = await chatApi.getCompanions();
    if (!companionsResponse.success) return null;
    
    final companions = companionsResponse.data!['companions'] as List;
    final companionId = companions.first['id'];

    // Create session
    final response = await chatApi.createSession(
      companionId: companionId,
      sessionType: 'text',
    );

    if (response.success && response.data != null) {
      final sessionId = response.data!['session_id'];
      print('Chat session created: $sessionId');
      return sessionId;
    }
    
    return null;
  }

  /// Send message and get AI response
  Future<void> sendMessageExample(String sessionId) async {
    final response = await chatApi.sendMessage(
      sessionId: sessionId,
      message: 'I\'m feeling anxious about my presentation tomorrow',
    );

    if (response.success && response.data != null) {
      final aiResponse = response.data!['ai_response'];
      final responseTime = response.data!['response_time_ms'];
      
      print('AI Response: $aiResponse');
      print('Response time: ${responseTime}ms');
    }
  }

  /// End chat session (gets AI summary)
  Future<void> endChatSessionExample(String sessionId) async {
    final response = await chatApi.endSession(sessionId);

    if (response.success && response.data != null) {
      print('Session ended');
      print('Duration: ${response.data!['duration_minutes']} minutes');
      print('Messages: ${response.data!['message_count']}');
      print('Summary: ${response.data!['summary']}');
    }
  }
}

/// ============================================================================
/// EXAMPLE 4: Meditation Integration
/// ============================================================================

class MeditationExample {
  final meditationApi = MeditationServiceApi();

  /// Get meditation sessions
  Future<void> getMeditationSessionsExample() async {
    final response = await meditationApi.getSessions(
      category: 'Mindfulness',
      page: 1,
      limit: 10,
    );

    if (response.success && response.data != null) {
      final sessions = response.data!['sessions'] as List;
      print('Found ${sessions.length} meditation sessions');
      
      for (var session in sessions) {
        print('${session['title']} - ${session['duration']}');
      }
    }
  }

  /// Complete a meditation session
  Future<void> completeMeditationExample(String sessionId) async {
    // Start session
    await meditationApi.startSession(sessionId);
    
    // ... user meditates ...
    
    // Complete session
    final response = await meditationApi.completeSession(
      sessionId: sessionId,
      durationCompleted: 600, // 10 minutes in seconds
      rating: 5,
    );

    if (response.success && response.data != null) {
      print('Session completed!');
      print('Total minutes: ${response.data!['total_meditation_minutes']}');
      print('Streak: ${response.data!['streak_days']} days');
      
      // Check for achievements
      if (response.data!.containsKey('achievement_unlocked')) {
        print('Achievement unlocked: ${response.data!['achievement_unlocked']}');
      }
    }
  }

  /// Get meditation history
  Future<void> getMeditationHistoryExample() async {
    final response = await meditationApi.getHistory(
      page: 1,
      limit: 20,
    );

    if (response.success && response.data != null) {
      final history = response.data!['history'] as List;
      final stats = response.data!['stats'];
      
      print('Meditation Stats:');
      print('Total sessions: ${stats['total_sessions']}');
      print('Total minutes: ${stats['total_minutes']}');
      print('Current streak: ${stats['current_streak']} days');
    }
  }
}

/// ============================================================================
/// EXAMPLE 5: User Profile Integration
/// ============================================================================

class UserProfileExample {
  final userApi = UserServiceApi();

  /// Get user profile
  Future<void> getProfileExample() async {
    final response = await userApi.getProfile();

    if (response.success && response.data != null) {
      print('User Profile:');
      print('Name: ${response.data!['full_name']}');
      print('Email: ${response.data!['email']}');
      print('Bio: ${response.data!['bio']}');
    }
  }

  /// Update user profile
  Future<void> updateProfileExample() async {
    final response = await userApi.updateProfile(
      fullName: 'John Doe Updated',
      bio: 'Mental health enthusiast and daily journaler',
    );

    if (response.success) {
      print('Profile updated successfully');
    }
  }

  /// Get user statistics
  Future<void> getUserStatsExample() async {
    final response = await userApi.getStats();

    if (response.success && response.data != null) {
      print('User Statistics:');
      
      final journal = response.data!['journal'];
      print('Journal entries: ${journal['total_entries']}');
      print('Most common mood: ${journal['most_common_mood']}');
      
      final meditation = response.data!['meditation'];
      print('Meditation sessions: ${meditation['total_sessions']}');
      print('Total minutes: ${meditation['total_minutes']}');
      
      final streaks = response.data!['streaks'];
      print('Current streak: ${streaks['current_daily_streak']} days');
      print('Longest streak: ${streaks['longest_daily_streak']} days');
    }
  }
}

/// ============================================================================
/// EXAMPLE 6: Complete Integration in a Widget
/// ============================================================================

class JournalPageExample extends StatefulWidget {
  const JournalPageExample({super.key});

  @override
  State<JournalPageExample> createState() => _JournalPageExampleState();
}

class _JournalPageExampleState extends State<JournalPageExample> {
  final journalApi = JournalServiceApi();
  List<Map<String, dynamic>> entries = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => isLoading = true);

    final response = await journalApi.getEntries(
      page: 1,
      limit: 20,
    );

    if (response.success && response.data != null) {
      setState(() {
        entries = (response.data!['entries'] as List).cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error?.message ?? 'Failed to load entries')),
        );
      }
    }
  }

  Future<void> _createEntry() async {
    final response = await journalApi.createEntry(
      content: 'New journal entry content',
      mood: 'happy',
      mode: 'reflection',
    );

    if (response.success) {
      // Reload entries
      await _loadEntries();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry created successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  title: Text(entry['content']),
                  subtitle: Text('Mood: ${entry['mood']}'),
                  trailing: Text(entry['created_at']),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}

