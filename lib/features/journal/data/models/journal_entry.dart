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
    return JournalEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      mood: json['mood'] as String?,
      moodValue: json['mood_value'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      conversation: (json['conversation'] as List?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList() ?? [],
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