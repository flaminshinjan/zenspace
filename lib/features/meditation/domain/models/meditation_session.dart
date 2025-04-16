class MeditationSession {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String category;
  final String audioUrl;
  final String imageUrl;
  final List<String> benefits;
  final String difficulty;

  const MeditationSession({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.audioUrl,
    required this.imageUrl,
    required this.benefits,
    required this.difficulty,
  });

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      duration: json['duration'] as String,
      category: json['category'] as String,
      audioUrl: json['audio_url'] as String,
      imageUrl: json['image_url'] as String,
      benefits: (json['benefits'] as List).map((e) => e as String).toList(),
      difficulty: json['difficulty'] as String,
    );
  }
} 