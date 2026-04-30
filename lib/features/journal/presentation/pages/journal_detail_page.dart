import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';

class JournalDetailPage extends StatefulWidget {
  final String entryId;
  final JournalRepository journalRepository;

  const JournalDetailPage({
    Key? key,
    required this.entryId,
    required this.journalRepository,
  }) : super(key: key);

  @override
  State<JournalDetailPage> createState() => _JournalDetailPageState();
}

class _JournalDetailPageState extends State<JournalDetailPage> {
  bool _isLoading = true;
  bool _showConversation = false;
  JournalEntry? _entry;

  @override
  void initState() {
    super.initState();
    _loadEntryDetails();
  }

  Future<void> _loadEntryDetails() async {
    try {
      print('🔄 Fetching journal entry details: ${widget.entryId}');
      final entry = await widget.journalRepository.getJournalEntry(widget.entryId);
      
      if (mounted) {
        setState(() {
          _entry = entry;
          _isLoading = false;
        });
        
        print('✅ Entry loaded with ${entry.conversation.length} conversation messages');
      }
    } catch (e) {
      print('❌ Error loading entry: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _getActualMessageCount() {
    if (_entry == null || _entry!.conversation.isEmpty) return 0;
    
    // Filter out initial system prompt
    int count = _entry!.conversation.length;
    final firstMessage = _entry!.conversation[0];
    final firstContent = firstMessage['content'] ?? '';
    
    if (firstContent.contains('My mood is') && 
        (firstContent.contains('Please provide') || 
         firstContent.contains('Help me'))) {
      count--;
    }
    
    return count;
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'excited':
      case 'very happy':
        return '😊';
      case 'calm':
      case 'peaceful':
        return '😌';
      case 'sad':
      case 'very sad':
        return '😢';
      case 'anxious':
      case 'worried':
        return '😰';
      case 'angry':
        return '😠';
      case 'neutral':
        return '😐';
      default:
        return '😊';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white.withOpacity(0.9),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Journal Entry',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.9),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : _entry == null
              ? Center(
                  child: Text(
                    'Entry not found',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with date and mood
                      Row(
                        children: [
                          // Date
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('MMM d, yyyy').format(_entry!.createdAt),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Mood
                          if (_entry!.mood != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getMoodEmoji(_entry!.mood!),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _entry!.mood!.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        _entry!.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          _entry!.content,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Conversation Section
                      if (_entry!.conversation.isNotEmpty) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showConversation = !_showConversation;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.purple.withOpacity(0.6),
                                                Colors.blue.withOpacity(0.6),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.chat_bubble,
                                            color: Colors.white.withOpacity(0.9),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'AI Conversation',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                               Text(
                                                 '${_getActualMessageCount()} messages',
                                                 style: GoogleFonts.poppins(
                                                   color: Colors.white.withOpacity(0.5),
                                                   fontSize: 12,
                                                 ),
                                               ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          _showConversation
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (_showConversation) ...[
                                Divider(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                Container(
                                  constraints: const BoxConstraints(maxHeight: 400),
                                   child: ListView.builder(
                                     shrinkWrap: true,
                                     padding: const EdgeInsets.all(16),
                                     itemCount: _entry!.conversation.length,
                                     itemBuilder: (context, index) {
                                       final message = _entry!.conversation[index];
                                       final role = message['role']?.toLowerCase() ?? '';
                                       final isUser = role == 'user';
                                       final content = message['content'] ?? '';
                                       
                                       // Skip empty messages
                                       if (content.isEmpty) return const SizedBox.shrink();
                                       
                                       // Skip initial system prompt (first message with mood)
                                       if (index == 0 && content.contains('My mood is') && 
                                           (content.contains('Please provide') || 
                                            content.contains('Help me'))) {
                                         return const SizedBox.shrink();
                                       }
                                       
                                       return Padding(
                                         padding: const EdgeInsets.only(bottom: 12),
                                         child: _buildChatBubble(content, isUser),
                                       );
                                     },
                                   ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildChatBubble(String content, bool isUser) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.blue.withOpacity(0.3),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              size: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUser
                    ? Colors.blue.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              content,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ],
    );
  }
}

