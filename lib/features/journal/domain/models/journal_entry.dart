import 'package:equatable/equatable.dart';

enum JournalMood {
  happy,
  sad,
  angry,
  anxious,
  calm,
  excited,
  tired,
  grateful,
  neutral;

  String get emoji {
    switch (this) {
      case JournalMood.happy:
        return '😊';
      case JournalMood.sad:
        return '😢';
      case JournalMood.angry:
        return '😠';
      case JournalMood.anxious:
        return '😰';
      case JournalMood.calm:
        return '😌';
      case JournalMood.excited:
        return '🤩';
      case JournalMood.tired:
        return '😴';
      case JournalMood.grateful:
        return '🙏';
      case JournalMood.neutral:
        return '😐';
    }
  }

  String get label {
    switch (this) {
      case JournalMood.happy:
        return 'Happy';
      case JournalMood.sad:
        return 'Sad';
      case JournalMood.angry:
        return 'Angry';
      case JournalMood.anxious:
        return 'Anxious';
      case JournalMood.calm:
        return 'Calm';
      case JournalMood.excited:
        return 'Excited';
      case JournalMood.tired:
        return 'Tired';
      case JournalMood.grateful:
        return 'Grateful';
      case JournalMood.neutral:
        return 'Neutral';
    }
  }
}

class JournalEntry extends Equatable {
  final String id;
  final String userId;
  final String content;
  final JournalMood mood;
  final DateTime createdAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.content,
    required this.mood,
    required this.createdAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      mood: JournalMood.values.firstWhere(
        (e) => e.toString() == 'JournalMood.${json['mood']}',
        orElse: () => JournalMood.neutral,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'mood': mood.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, content, mood, createdAt];
} 