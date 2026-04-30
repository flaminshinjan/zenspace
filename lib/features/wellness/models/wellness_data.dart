/// Psycho-physiological data model from Apple Watch
/// Used for AI-powered wellness insights
class WellnessData {
  final double heartRateBpm;
  final double heartRateVariabilityMs;
  final int sleepHours;
  final int sleepQuality; // 1-100
  final int stepsCount;
  final double stressLevel; // 0-10 scale
  final double respiratoryRate; // breaths per minute
  final int activeMinutes;
  final DateTime collectedAt;

  WellnessData({
    required this.heartRateBpm,
    required this.heartRateVariabilityMs,
    required this.sleepHours,
    required this.sleepQuality,
    required this.stepsCount,
    required this.stressLevel,
    required this.respiratoryRate,
    required this.activeMinutes,
    required this.collectedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'heart_rate_bpm': heartRateBpm,
      'heart_rate_variability_ms': heartRateVariabilityMs,
      'sleep_hours': sleepHours,
      'sleep_quality': sleepQuality,
      'steps_count': stepsCount,
      'stress_level': stressLevel,
      'respiratory_rate': respiratoryRate,
      'active_minutes': activeMinutes,
      'collected_at': collectedAt.toIso8601String(),
    };
  }

  factory WellnessData.fromJson(Map<String, dynamic> json) {
    return WellnessData(
      heartRateBpm: (json['heart_rate_bpm'] ?? json['heartRateBpm'] ?? 72).toDouble(),
      heartRateVariabilityMs: (json['heart_rate_variability_ms'] ?? json['heartRateVariabilityMs'] ?? 45).toDouble(),
      sleepHours: json['sleep_hours'] ?? json['sleepHours'] ?? 7,
      sleepQuality: json['sleep_quality'] ?? json['sleepQuality'] ?? 75,
      stepsCount: json['steps_count'] ?? json['stepsCount'] ?? 5000,
      stressLevel: (json['stress_level'] ?? json['stressLevel'] ?? 4).toDouble(),
      respiratoryRate: (json['respiratory_rate'] ?? json['respiratoryRate'] ?? 14).toDouble(),
      activeMinutes: json['active_minutes'] ?? json['activeMinutes'] ?? 45,
      collectedAt: json['collected_at'] != null
          ? DateTime.parse(json['collected_at'])
          : DateTime.now(),
    );
  }
}

/// AI-generated wellness suggestion
class WellnessSuggestion {
  final String id;
  final String title;
  final String description;
  final String category; // emotional, physical, sleep, stress, general
  final int priority; // 1-5, 1 being highest
  final String? actionStep;
  final String? duration; // e.g., "5 min", "10 min"

  WellnessSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.priority = 3,
    this.actionStep,
    this.duration,
  });

  factory WellnessSuggestion.fromJson(Map<String, dynamic> json) {
    return WellnessSuggestion(
      id: json['id'] ?? json['title'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Wellness tip',
      description: json['description'] ?? json['content'] ?? '',
      category: json['category'] ?? 'general',
      priority: json['priority'] ?? 3,
      actionStep: json['action_step'] ?? json['actionStep'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'action_step': actionStep,
      'duration': duration,
    };
  }
}
