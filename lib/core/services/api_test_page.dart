import 'package:flutter/material.dart';
import 'package:zenspace/core/services/auth_service.dart';
import 'package:zenspace/core/services/journal_service_api.dart';
import 'package:zenspace/core/services/chat_service_api.dart';
import 'package:zenspace/core/services/meditation_service_api.dart';
import 'package:zenspace/core/services/user_service_api.dart';
import 'package:zenspace/core/constants/api_constants.dart';

/// API Test Page
/// 
/// This page helps you test all API endpoints
/// Access it by navigating to this page in your app
class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final _authService = AuthService();
  final _journalApi = JournalServiceApi();
  final _chatApi = ChatServiceApi();
  final _meditationApi = MeditationServiceApi();
  final _userApi = UserServiceApi();

  String _output = 'Ready to test APIs...\n\nBase URL: ${ApiConstants.baseUrl}';
  bool _isLoading = false;

  void _log(String message) {
    setState(() {
      _output += '\n$message';
    });
    debugPrint(message);
  }

  void _clearLog() {
    setState(() {
      _output = 'Log cleared.\n\nBase URL: ${ApiConstants.baseUrl}';
    });
  }

  Future<void> _testAuth() async {
    setState(() => _isLoading = true);
    _log('\n🔐 Testing Authentication...');

    try {
      // Test registration
      _log('Testing registration...');
      final registerResponse = await _authService.register(
        email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'password123',
        fullName: 'Test User',
      );

      if (registerResponse.success) {
        _log('✅ Registration successful!');
        _log('User: ${registerResponse.data}');
      } else {
        _log('❌ Registration failed: ${registerResponse.error?.message}');
      }

      // Test login
      _log('\nTesting login...');
      final loginResponse = await _authService.login(
        email: 'user@example.com',
        password: 'password123',
      );

      if (loginResponse.success) {
        _log('✅ Login successful!');
        _log('Token saved automatically');
      } else {
        _log('❌ Login failed: ${loginResponse.error?.message}');
        _log('This is expected if backend is not running');
      }
    } catch (e) {
      _log('❌ Error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testJournal() async {
    setState(() => _isLoading = true);
    _log('\n📝 Testing Journal APIs...');

    try {
      // Test create entry
      _log('Creating journal entry...');
      final createResponse = await _journalApi.createEntry(
        content: 'This is a test journal entry created at ${DateTime.now()}',
        mood: 'happy',
        mode: 'reflection',
        tags: ['test', 'api'],
      );

      if (createResponse.success) {
        _log('✅ Entry created!');
        _log('Entry ID: ${createResponse.data!['id']}');

        // Test get entries
        _log('\nGetting journal entries...');
        final getResponse = await _journalApi.getEntries(page: 1, limit: 5);

        if (getResponse.success) {
          _log('✅ Got ${getResponse.data!['entries'].length} entries');
        } else {
          _log('❌ Failed to get entries: ${getResponse.error?.message}');
        }
      } else {
        _log('❌ Failed to create entry: ${createResponse.error?.message}');
        _log('This is expected if backend is not running or not authenticated');
      }

      // Test AI suggestions
      _log('\nTesting AI suggestions...');
      final aiResponse = await _journalApi.getAiSuggestions(
        mode: 'reflection',
        mood: 'anxious',
        context: 'Feeling stressed about work',
      );

      if (aiResponse.success) {
        _log('✅ Got AI suggestions!');
        _log('Suggestions: ${aiResponse.data!['suggestions']}');
      } else {
        _log('❌ AI suggestions failed: ${aiResponse.error?.message}');
      }
    } catch (e) {
      _log('❌ Error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testChat() async {
    setState(() => _isLoading = true);
    _log('\n💬 Testing Chat APIs...');

    try {
      // Test get companions
      _log('Getting AI companions...');
      final companionsResponse = await _chatApi.getCompanions();

      if (companionsResponse.success) {
        _log('✅ Got companions!');
        _log('Companions: ${companionsResponse.data!['companions']}');

        // Test create session
        if (companionsResponse.data!['companions'].isNotEmpty) {
          final companionId = companionsResponse.data!['companions'][0]['id'];
          _log('\nCreating chat session...');
          
          final sessionResponse = await _chatApi.createSession(
            companionId: companionId,
            sessionType: 'text',
          );

          if (sessionResponse.success) {
            _log('✅ Session created!');
            final sessionId = sessionResponse.data!['session_id'];
            _log('Session ID: $sessionId');

            // Test send message
            _log('\nSending message...');
            final messageResponse = await _chatApi.sendMessage(
              sessionId: sessionId,
              message: 'Hello! This is a test message.',
            );

            if (messageResponse.success) {
              _log('✅ Message sent!');
              _log('AI Response: ${messageResponse.data!['ai_response']}');
            } else {
              _log('❌ Failed to send message: ${messageResponse.error?.message}');
            }
          } else {
            _log('❌ Failed to create session: ${sessionResponse.error?.message}');
          }
        }
      } else {
        _log('❌ Failed to get companions: ${companionsResponse.error?.message}');
      }
    } catch (e) {
      _log('❌ Error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testMeditation() async {
    setState(() => _isLoading = true);
    _log('\n🧘 Testing Meditation APIs...');

    try {
      // Test get sessions
      _log('Getting meditation sessions...');
      final sessionsResponse = await _meditationApi.getSessions(
        page: 1,
        limit: 5,
      );

      if (sessionsResponse.success) {
        _log('✅ Got meditation sessions!');
        _log('Sessions: ${sessionsResponse.data!['sessions'].length}');
      } else {
        _log('❌ Failed to get sessions: ${sessionsResponse.error?.message}');
      }

      // Test get categories
      _log('\nGetting meditation categories...');
      final categoriesResponse = await _meditationApi.getCategories();

      if (categoriesResponse.success) {
        _log('✅ Got categories!');
        _log('Categories: ${categoriesResponse.data!['categories']}');
      } else {
        _log('❌ Failed to get categories: ${categoriesResponse.error?.message}');
      }
    } catch (e) {
      _log('❌ Error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testUserProfile() async {
    setState(() => _isLoading = true);
    _log('\n👤 Testing User Profile APIs...');

    try {
      // Test get profile
      _log('Getting user profile...');
      final profileResponse = await _userApi.getProfile();

      if (profileResponse.success) {
        _log('✅ Got profile!');
        _log('Profile: ${profileResponse.data}');
      } else {
        _log('❌ Failed to get profile: ${profileResponse.error?.message}');
      }

      // Test get stats
      _log('\nGetting user stats...');
      final statsResponse = await _userApi.getStats();

      if (statsResponse.success) {
        _log('✅ Got stats!');
        _log('Stats: ${statsResponse.data}');
      } else {
        _log('❌ Failed to get stats: ${statsResponse.error?.message}');
      }
    } catch (e) {
      _log('❌ Error: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearLog,
            tooltip: 'Clear log',
          ),
        ],
      ),
      body: Column(
        children: [
          // Test buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              children: [
                Text(
                  'Base URL: ${ApiConstants.baseUrl}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testAuth,
                      icon: const Icon(Icons.lock),
                      label: const Text('Auth'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testJournal,
                      icon: const Icon(Icons.book),
                      label: const Text('Journal'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testChat,
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testMeditation,
                      icon: const Icon(Icons.self_improvement),
                      label: const Text('Meditation'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testUserProfile,
                      icon: const Icon(Icons.person),
                      label: const Text('Profile'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Output log
          Expanded(
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: SelectableText(
                  _output,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const LinearProgressIndicator(),
        ],
      ),
    );
  }
}

