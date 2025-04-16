import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/models/journal_entry.dart';

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

class _AIJournalScreenState extends State<AIJournalScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final List<Map<String, String>> _conversation = [];
  bool _isLoading = false;
  late bool _showMoodSelection;
  String? _selectedMood;
  int? _selectedMoodValue;
  late final GenerativeModel _model;
  late final ChatSession _chat;
  late final JournalRepository _journalRepository;
  List<JournalEntry> _journalEntries = [];
  String? _currentEntryId;

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
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );
    _chat = _model.startChat();
    _journalRepository = JournalRepository(Supabase.instance.client);
    
    // Initialize with a default value
    _showMoodSelection = true;

    // If we have an existing entry, load its data
    if (widget.entry != null) {
      _conversation.addAll(widget.entry!.conversation);
      _selectedMood = widget.entry!.mood;
      _selectedMoodValue = widget.entry!.moodValue;
      _currentEntryId = widget.entry!.id;
      
      // Initialize chat history with existing conversation
      for (final message in widget.entry!.conversation) {
        if (message['role'] == 'user') {
          _chat.sendMessage(Content.text(message['content']!));
        }
      }
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
    await scrollController?.animateTo(
      scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final responseText = response.text;
      
      if (mounted) {
        setState(() {
          _conversation.add({
            'role': 'assistant',
            'content': _cleanAIResponse(responseText ?? 'No response generated. Please try again.'),
            'timestamp': DateTime.now().toIso8601String(),
          });
          _isLoading = false;
        });
      }

      // Scroll to bottom after receiving response
      await scrollController?.animateTo(
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
    print('Debug: _saveJournalEntry called');
    
    // Don't save if there's no conversation
    if (_conversation.isEmpty) {
      print('Debug: No conversation to save');
      return;
    }

    // Get all user messages for content summary
    final userMessages = _conversation
        .where((msg) => msg['role'] == 'user')
        .map((msg) => msg['content'] as String)
        .where((content) => content.isNotEmpty)
        .toList();

    final content = _controller.text.trim().isNotEmpty
        ? _controller.text
        : userMessages.join(' | ');

    try {
      print('Debug: Creating/updating journal entry');
      
      final entry = await _journalRepository.createJournalEntry(
        title: _titleController.text,
        content: content,
        mood: _selectedMood,
        moodValue: _selectedMoodValue ?? 3,
        conversation: _conversation,
      );
      
      print('Debug: Entry saved successfully with ID: ${entry.id}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry saved')),
        );
      }
    } catch (e) {
      print('Debug: Error in _saveJournalEntry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
      }
      rethrow;
    }
  }

  void _selectMood(String mood, int value) {
    // Don't allow mood selection for existing entries
    if (widget.entry != null) return;
    
    if (_conversation.isNotEmpty) return; // Prevent multiple initial prompts
    
    setState(() {
      _selectedMood = mood;
      _selectedMoodValue = value;
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
      final prompt = _getPromptForMode(widget.mode);
      final response = await _chat.sendMessage(Content.text('My mood is $_selectedMood. $prompt'));
      final responseText = response.text;
      
      if (mounted) {
        setState(() {
          _conversation.add({
            'role': 'assistant',
            'content': _cleanAIResponse(responseText ?? 'No response generated. Please try again.'),
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
        return '''You are a supportive and empathetic journaling guide. Provide 5 short, thoughtful prompts in this format:
1. [Now] What's on your mind right now?
2. [Growth] What made you proud today?
3. [Future] One small goal for tomorrow?
4. [Learn] A lesson from today?
5. [Feel] Current mood in three words?

Keep responses under 50 words. No greetings or explanations.''';

      case 'five_whys':
        return '''You are a supportive and empathetic guide for the Five Whys technique. Your role is to help the user explore their thoughts and feelings with gentle, open-ended questions. Never be confrontational or judgmental. Keep responses under 30 words. Start with: "What's on your mind today?"''';

      case 'mood':
        return '''You are a supportive and empathetic emotional wellness guide. Help users explore their feelings with gentle, understanding responses. Keep responses under 30 words. Start with: "How are you feeling today?"''';

      default:
        return '''You are a supportive and empathetic journaling companion. Help users explore their thoughts with gentle, understanding responses. Keep responses under 30 words. Start with: "What's on your mind?"''';
    }
  }

  String _cleanAIResponse(String response) {
    return response
      .replaceAll('**', '')
      .replaceAll('*', '')
      .replaceAll('__', '')
      .trim();
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
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: Colors.white70,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.02),
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.02),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  tileMode: TileMode.mirror,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptList(String content) {
    if (!content.contains('1. [')) return Text(
      content,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    );

    final prompts = content.split('\n')
        .where((line) => line.trim().startsWith(RegExp(r'\d\.')))
        .map((line) => line.trim())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: prompts.map((prompt) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              final promptText = prompt.replaceFirst(RegExp(r'\d\.\s*\[[^\]]+\]\s*'), '');
              setState(() {
                final firstPrompt = _conversation.first;
                _conversation.clear();
                _conversation.add(firstPrompt);
              });
              _sendMessage('''I would like to reflect on this: $promptText''');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      prompt,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildJournalEntries() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _journalEntries.length,
      itemBuilder: (context, index) {
        final entry = _journalEntries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Navigate to detail view
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat('MMM d, y').format(entry.createdAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          if (entry.mood != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                entry.mood!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = DateFormat('EEEE, MMMM d, y').format(now);

    // Override mood selection visibility for existing entries
    final shouldShowMoodSelection = widget.entry == null && _showMoodSelection;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                print('Debug: Back button pressed');
                                try {
                                  print('Debug: Attempting to save on back button');
                                  await _saveJournalEntry();
                                  if (mounted) {
                                    // Pop back to the main screen and switch to journal tab
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/',
                                      (route) => false,
                                      arguments: {'initialTab': 2}, // 2 is the journal tab index
                                    );
                                  }
                                } catch (e) {
                                  print('Debug: Error saving on back button: $e');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error saving entry: $e')),
                                    );
                                    // Still navigate back even if save fails
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/',
                                      (route) => false,
                                      arguments: {'initialTab': 2},
                                    );
                                  }
                                }
                              },
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          filled: true,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        cursorColor: Colors.white38,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // AI Prompt Card
                      if (_conversation.isNotEmpty)
                        Container(
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
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.psychology_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: widget.mode == 'suggestions'
                                    ? _buildPromptList(_conversation.first['content']!)
                                    : Text(
                                        _conversation.first['content']!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      // Conversation Messages
                      ..._conversation.skip(1).map((message) {
                        final isUser = message['role'] == 'user';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isUser) ...[
                                Container(
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
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.psychology_outlined,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          message['content']!,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  message['content']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                      if (_isLoading) ...[
                        const SizedBox(height: 16),
                        _buildLoadingIndicator(),
                      ],
                      const SizedBox(height: 20),
                      // Journal Text Area
                      Container(
                        constraints: const BoxConstraints(
                          minHeight: 56,
                          maxHeight: 200,
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              controller: _controller,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(16, 16, 56, 16),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                filled: true,
                                hintText: 'Write your thoughts...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 16,
                                ),
                              ),
                              minLines: 1,
                              maxLines: 6,
                              textAlignVertical: TextAlignVertical.top,
                              onSubmitted: _sendMessage,
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.send_rounded,
                                    size: 20,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  onPressed: () {
                                    _sendMessage(_controller.text);
                                    _saveJournalEntry();
                                  },
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (shouldShowMoodSelection)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 200),
                    const Text(
                      'How are you feeling?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Date: ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat('d MMMM y').format(now),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            ' at ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat('h:mma').format(now).toLowerCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _moods.map((mood) {
                        return GestureDetector(
                          onTap: () => _selectMood(mood['label'], mood['value']),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              mood['icon'],
                              color: Colors.white.withOpacity(0.7),
                              size: 32,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }
} 