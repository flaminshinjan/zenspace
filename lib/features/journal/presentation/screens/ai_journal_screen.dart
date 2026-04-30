import 'package:flutter/material.dart';
import '../../data/models/journal_entry.dart';
import '../../../../core/services/chat_service_api.dart';
import '../../../../core/services/journal_service_api.dart';

class AIJournalScreen extends StatefulWidget {
  final String mode;
  final JournalEntry? entry;
  
  const AIJournalScreen({
    super.key,
    required this.mode,
    this.entry,
  });

  @override
  State<AIJournalScreen> createState() => _AIJournalScreenState();
}

class _AIJournalScreenState extends State<AIJournalScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final List<Map<String, String>> _conversation = [];
  bool _isLoading = false;
  bool _isSaving = false;
  late bool _showMoodSelection;
  String? _selectedMood;
  late final ChatServiceApi _chatService;
  String? _currentSessionId;
  bool _hasBeenSaved = false;
  late final AnimationController _typingAnim;

  final List<Map<String, dynamic>> _moods = [
    {'icon': Icons.sentiment_very_dissatisfied_outlined, 'label': 'Very Sad', 'value': 1},
    {'icon': Icons.sentiment_dissatisfied_outlined, 'label': 'Sad', 'value': 2},
    {'icon': Icons.sentiment_neutral_outlined, 'label': 'Neutral', 'value': 3},
    {'icon': Icons.sentiment_satisfied_outlined, 'label': 'Happy', 'value': 4},
    {'icon': Icons.sentiment_very_satisfied_outlined, 'label': 'Very Happy', 'value': 5},
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.entry?.title ?? "Today's Thoughts";
    _chatService = ChatServiceApi();
    _typingAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    
    // Initialize with a default value
    _showMoodSelection = true;

    // If we have an existing entry, load its data
    if (widget.entry != null) {
      _conversation.addAll(widget.entry!.conversation);
      _selectedMood = widget.entry!.mood;
      _showMoodSelection = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get the isExisting flag from the route arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isExisting = args?['isExisting'] ?? false;

    // Update _showMoodSelection based on both widget.entry and isExisting flag
    if (mounted) {
      setState(() {
        _showMoodSelection = !(widget.entry != null || isExisting);
      });
    }
  }

  Future<void> _initializeChatSession() async {
    if (_currentSessionId != null) return;
    
    try {
      print('🔄 Creating chat session...');
      final response = await _chatService.createSession(
        companionId: 'journal-assistant',
        sessionType: 'text',
      );
      
      print('📦 Create session response success: ${response.success}');
      print('📦 Create session response data: ${response.data}');
      
      if (response.success && response.data != null) {
        // Try different possible response structures
        dynamic sessionData = response.data;
        
        // Check if data has 'session' key
        if (sessionData is Map && sessionData.containsKey('session')) {
          sessionData = sessionData['session'];
        }
        
        // Get session ID
        if (sessionData is Map && sessionData.containsKey('id')) {
          _currentSessionId = sessionData['id'].toString();
          print('✅ Chat session created: $_currentSessionId');
        } else if (sessionData is Map && sessionData.containsKey('session_id')) {
          _currentSessionId = sessionData['session_id'].toString();
          print('✅ Chat session created: $_currentSessionId');
        } else {
          print('❌ Could not find session ID in response: $sessionData');
          throw Exception('Session ID not found in response');
        }
      } else {
        print('❌ Session creation failed: ${response.error?.message}');
        throw Exception(response.error?.message ?? 'Failed to create session');
      }
    } catch (e, stackTrace) {
      print('❌ Error creating chat session: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  void _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // If we're viewing an existing entry, don't show mood selection
    if (widget.entry != null) {
      _showMoodSelection = false;
    }

    final scrollController = PrimaryScrollController.of(context);
    
    setState(() {
      _conversation.add({
        'role': 'user',
        'content': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _isLoading = true;
    });
    _controller.clear();

    // Scroll to bottom after adding message
    await scrollController.animateTo(
      scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    try {
      // Initialize session if needed
      if (_currentSessionId == null) {
        await _initializeChatSession();
      }

      // Send message to backend
      final response = await _chatService.sendMessage(
        sessionId: _currentSessionId!,
        message: message,
      );
      
      print('📦 Send message response: ${response.data}');
      
      String responseText = 'No response generated. Please try again.';
      if (response.success && response.data != null) {
        final data = response.data!;
        
        // Backend returns: { "ai_response": "...", "message_id": "...", ... }
        if (data.containsKey('ai_response')) {
          responseText = data['ai_response'].toString();
        } else if (data.containsKey('message')) {
          final messageData = data['message'];
          if (messageData is Map && messageData.containsKey('content')) {
            responseText = messageData['content'].toString();
          } else if (messageData is String) {
            responseText = messageData;
          }
        } else if (data.containsKey('content')) {
          responseText = data['content'].toString();
        } else if (data.containsKey('response')) {
          responseText = data['response'].toString();
        }
      }
      
      if (mounted) {
        setState(() {
          _conversation.add({
            'role': 'assistant',
            'content': responseText,
            'timestamp': DateTime.now().toIso8601String(),
          });
          _isLoading = false;
        });
      }

      // Scroll to bottom after receiving response
      await scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveJournalEntry() async {
    if (_isSaving) return;
    
    print('Debug: _saveJournalEntry called');
    
    // Don't save if there's no conversation
    if (_conversation.isEmpty) {
      print('Debug: No conversation to save');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Start a conversation first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Don't save if no session ID (shouldn't happen)
    if (_currentSessionId == null) {
      print('Debug: No session ID');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat session not initialized'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      print('Debug: Creating journal entry from chat session: $_currentSessionId');
      
      // Create entry from chat session
      final journalService = JournalServiceApi();
      final response = await journalService.createEntryFromChat(
        sessionId: _currentSessionId!,
        mood: _selectedMood,
        mode: widget.mode,
        tags: ['from-chat', widget.mode],
      );

      if (response.success && response.data != null) {
        print('✅ Journal entry created from chat');
        
        setState(() {
          _hasBeenSaved = true;
          _isSaving = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Journal entry saved!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Navigate back after a short delay with success result
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop(true); // Return true to indicate success
            }
          });
        }
      } else {
        throw Exception(response.error?.message ?? 'Failed to save entry');
      }
    } catch (e) {
      print('❌ Error saving journal entry: $e');
      setState(() => _isSaving = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectMood(String mood, int value) {
    // Don't allow mood selection for existing entries
    if (widget.entry != null) return;
    
    if (_conversation.isNotEmpty) return; // Prevent multiple initial prompts
    
    setState(() {
      _selectedMood = mood;
      _showMoodSelection = false;
    });
    _getInitialPrompt();
  }

  Future<void> _getInitialPrompt() async {
    // Don't get initial prompt for existing entries
    if (widget.entry != null) return;
    
    if (_conversation.isNotEmpty) return; // Prevent duplicate prompts
    
    setState(() => _isLoading = true);
    try {
      // Initialize session
      await _initializeChatSession();
      
      final prompt = _getPromptForMode(widget.mode);
      final message = _selectedMood != null
          ? 'My mood is $_selectedMood. $prompt'
          : prompt;
      
      final response = await _chatService.sendMessage(
        sessionId: _currentSessionId!,
        message: message,
      );
      
      print('📦 Get initial prompt response: ${response.data}');
      
      String responseText = 'No response generated. Please try again.';
      if (response.success && response.data != null) {
        final data = response.data!;
        
        // Backend returns: { "ai_response": "...", "message_id": "...", ... }
        if (data.containsKey('ai_response')) {
          responseText = data['ai_response'].toString();
        } else if (data.containsKey('message')) {
          final messageData = data['message'];
          if (messageData is Map && messageData.containsKey('content')) {
            responseText = messageData['content'].toString();
          } else if (messageData is String) {
            responseText = messageData;
          }
        } else if (data.containsKey('content')) {
          responseText = data['content'].toString();
        } else if (data.containsKey('response')) {
          responseText = data['response'].toString();
        }
      }
      
      if (mounted) {
        setState(() {
          _conversation.add({
            'role': 'assistant',
            'content': responseText,
            'timestamp': DateTime.now().toIso8601String(),
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  String _getPromptForMode(String mode) {
    switch (mode) {
      case 'suggestions':
        return 'Please provide 5 short, thoughtful journaling prompts to help me reflect on my day.';

      case 'five_whys':
        return 'Please help me explore my thoughts using the Five Whys technique. Start with: "What\'s on your mind today?"';

      case 'mood':
        return 'Help me explore my current mood and feelings. Start with: "How are you feeling today?"';

      default:
        return 'Help me with journaling. Start with: "What\'s on your mind?"';
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI is thinking...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _typingAnim,
                  builder: (context, _) {
                    return Row(
                      children: List.generate(3, (i) {
                        final t = (_typingAnim.value * 3 - i).clamp(0.0, 1.0);
                        final scale = 0.6 + 0.4 * (1 - (t * 2 - 1).abs());
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 5),
                          transform: Matrix4.identity()..scale(scale),
                          transformAlignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25 + 0.55 * scale),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _titleController.text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!_showMoodSelection && _conversation.length >= 2 && !_hasBeenSaved)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSaving ? null : _saveJournalEntry,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isSaving)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          const Icon(
                            Icons.book_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _isSaving ? 'Saving...' : 'Save as Journal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_hasBeenSaved)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade300,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Saved',
                    style: TextStyle(
                      color: Colors.green.shade300,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Mood Selection
          if (_showMoodSelection) ...[
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'How are you feeling?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const SizedBox(height: 4),
                      Text(
                        'Tap a mood to start, or skip below.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: _moods.map((mood) {
                          return GestureDetector(
                            onTap: () => _selectMood(
                              mood['label'] as String,
                              mood['value'] as int,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    mood['icon'] as IconData,
                                    size: 48,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    mood['label'] as String,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedMood = null;
                            _showMoodSelection = false;
                          });
                          _getInitialPrompt();
                        },
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withOpacity(0.6),
                          size: 18,
                        ),
                        label: Text(
                          'Skip and start writing',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            // Conversation
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _conversation.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _conversation.length) {
                    return _buildLoadingIndicator();
                  }
                  
                  final message = _conversation[index];
                  final isUser = message['role'] == 'user';
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.smart_toy_outlined,
                              color: Colors.white.withOpacity(0.7),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              message['content'] ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Input Field
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _typingAnim.dispose();
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
