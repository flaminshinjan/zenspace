import 'package:flutter/material.dart';

@immutable
class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? mood;
  final int? moodValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Map<String, String>> conversation;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.mood,
    this.moodValue,
    required this.createdAt,
    required this.updatedAt,
    required this.conversation,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    // Helper function to parse timestamps (handles both ISO strings and Firebase Timestamps)
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else if (timestamp is Map) {
        // Firebase Timestamp: { "_seconds": 1234567890, "_nanoseconds": 123000000 }
        final seconds = timestamp['_seconds'] ?? timestamp['seconds'];
        final nanoseconds = timestamp['_nanoseconds'] ?? timestamp['nanoseconds'] ?? 0;
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            (seconds * 1000) + (nanoseconds / 1000000).round(),
          );
        }
      } else if (timestamp is int) {
        // Unix timestamp in milliseconds
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      
      return DateTime.now();
    }

    // Parse conversation with detailed logging
    List<Map<String, String>> conversation = [];
    
    // Check for chat_conversation object (from detail API)
    if (json.containsKey('chat_conversation') && json['chat_conversation'] != null) {
      final chatConversation = json['chat_conversation'];
      print('🗨️ Parsing chat_conversation for entry ${json['id']}');
      
      if (chatConversation is Map && chatConversation.containsKey('messages')) {
        final messages = chatConversation['messages'];
        if (messages is List) {
          print('📊 Chat conversation has ${messages.length} messages');
          conversation = messages
              .map((msg) {
                if (msg is Map) {
                  // Map sender -> role and extract content
                  final sender = msg['sender']?.toString() ?? '';
                  final content = msg['content']?.toString() ?? '';
                  return {
                    'role': sender, // 'user' or 'ai'
                    'content': content,
                  };
                }
                return <String, String>{};
              })
              .toList();
        }
      }
    }
    // Check for conversation array (from list API)
    else if (json.containsKey('conversation') && json['conversation'] != null) {
      final conversationData = json['conversation'];
      print('🗨️ Parsing conversation array for entry ${json['id']}');
      
      if (conversationData is List) {
        print('📊 Conversation has ${conversationData.length} messages');
        conversation = conversationData
            .map((e) {
              if (e is Map) {
                // Handle both 'sender' and 'role' keys
                final role = e['role']?.toString() ?? e['sender']?.toString() ?? '';
                final content = e['content']?.toString() ?? '';
                return {
                  'role': role,
                  'content': content,
                };
              }
              return <String, String>{};
            })
            .toList();
      }
    } else {
      print('⚠️ No conversation field for entry ${json['id']}');
    }

    return JournalEntry(
      id: json['id'] as String,
      userId: (json['user_id'] ?? json['userId']) as String,
      title: json['title'] as String? ?? 'Journal Entry',
      content: json['content'] as String,
      mood: json['mood'] as String?,
      moodValue: json['mood_value'] as int?,
      createdAt: parseTimestamp(json['created_at'] ?? json['createdAt']),
      updatedAt: parseTimestamp(json['updated_at'] ?? json['updatedAt']),
      conversation: conversation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'mood': mood,
      'mood_value': moodValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'conversation': conversation,
    };
  }

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? mood,
    int? moodValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, String>>? conversation,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      moodValue: moodValue ?? this.moodValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      conversation: conversation ?? this.conversation,
    );
  }
} 