import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/journal_entry.dart';

class JournalRepository {
  final SupabaseClient _supabase;
  late final GenerativeModel _model;

  JournalRepository(this._supabase) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );
  }

  Future<List<JournalEntry>> getJournalEntries() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('journal_entries')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response
          .map<JournalEntry>((json) => JournalEntry.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch journal entries: $e');
    }
  }

  String summarizeConversation(List<Map<String, String>> conversation) {
    if (conversation.isEmpty) return '';

    // Get user messages only
    final userMessages = conversation
        .where((msg) => msg['role'] == 'user')
        .map((msg) => msg['content'])
        .where((content) => content != null && content.isNotEmpty)
        .toList();

    if (userMessages.isEmpty) return '';

    // If there's only one message, return it
    if (userMessages.length == 1) return userMessages.first!;

    // If there are multiple messages, combine them
    return userMessages.join(' | ');
  }

  Future<String> _generateSummary(List<Map<String, String>> conversation) async {
    try {
      // Convert conversation to a readable format
      final conversationText = conversation.map((msg) {
        final role = msg['role'] == 'user' ? 'Me' : 'AI';
        return '$role: ${msg['content']}';
      }).join('\n');

      // Create the prompt for summary generation
      final prompt = '''
Summarize this journal conversation in 2-3 lines, focusing on the key emotions, thoughts, and insights:

$conversationText

Summary:''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final summary = response.text?.trim() ?? '';
      
      // Ensure summary is not too long
      if (summary.length > 200) {
        return summary.substring(0, 197) + '...';
      }
      return summary;
    } catch (e) {
      print('Debug: Error generating summary: $e');
      // Fall back to basic summary if Gemini fails
      return summarizeConversation(conversation);
    }
  }

  Future<JournalEntry> createJournalEntry({
    required String title,
    required String content,
    required String? mood,
    required int? moodValue,
    required List<Map<String, String>> conversation,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Debug: User not authenticated');
        throw Exception('User not authenticated');
      }

      // Generate summary using Gemini
      final summary = await _generateSummary(conversation);
      print('Debug: Generated summary: $summary');

      // Check if there's already an entry with the same timestamp (within the last minute)
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
      
      final existingEntries = await _supabase
          .from('journal_entries')
          .select()
          .eq('user_id', user.id)
          .gte('created_at', oneMinuteAgo.toIso8601String())
          .order('created_at', ascending: false);

      if (existingEntries.isNotEmpty) {
        // Update the existing entry instead of creating a new one
        final existingEntry = existingEntries.first;
        print('Debug: Updating existing entry: ${existingEntry['id']}');

        final response = await _supabase
            .from('journal_entries')
            .update({
              'content': summary, // Use the generated summary as content
              'conversation': conversation,
              'updated_at': now.toIso8601String(),
            })
            .eq('id', existingEntry['id'])
            .select()
            .single();

        return JournalEntry.fromJson(response);
      }

      // Create new entry if no recent entry exists
      print('Debug: Creating new journal entry');
      final response = await _supabase
          .from('journal_entries')
          .insert({
            'user_id': user.id,
            'title': title.trim(),
            'content': summary.trim(), // Use the generated summary as content
            'mood': mood,
            'mood_value': moodValue ?? 3,
            'conversation': conversation,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .select()
          .single();

      return JournalEntry.fromJson(response);
    } catch (e) {
      print('Debug: Error in createJournalEntry: $e');
      throw Exception('Failed to create/update journal entry: $e');
    }
  }

  Future<JournalEntry> updateJournalEntry({
    required String id,
    String? title,
    String? content,
    String? mood,
    int? moodValue,
    List<Map<String, String>>? conversation,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final Map<String, dynamic> updates = {
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (mood != null) 'mood': mood,
        if (moodValue != null) 'mood_value': moodValue,
        if (conversation != null) 'conversation': conversation,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('journal_entries')
          .update(updates)
          .eq('id', id)
          .eq('user_id', user.id) // Ensure user can only update their own entries
          .select()
          .single();

      return JournalEntry.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update journal entry: $e');
    }
  }

  Future<void> deleteJournalEntry(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('journal_entries')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id); // Ensure user can only delete their own entries
    } catch (e) {
      throw Exception('Failed to delete journal entry: $e');
    }
  }

  Stream<List<JournalEntry>> streamJournalEntries() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _supabase
        .from('journal_entries')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .map((response) => response
            .map<JournalEntry>((json) => JournalEntry.fromJson(json))
            .toList());
  }
} 