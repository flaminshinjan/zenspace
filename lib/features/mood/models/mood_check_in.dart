/// Model class for mood check-in
class MoodCheckIn {
  final String id;
  final String userId;
  final String mood;
  final String? notes;
  final DateTime createdAt;

  MoodCheckIn({
    required this.id,
    required this.userId,
    required this.mood,
    this.notes,
    required this.createdAt,
  });

  factory MoodCheckIn.fromJson(Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else if (timestamp is Map) {
        final seconds = timestamp['_seconds'] ?? timestamp['seconds'];
        final nanoseconds = timestamp['_nanoseconds'] ?? timestamp['nanoseconds'] ?? 0;
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            (seconds * 1000) + (nanoseconds / 1000000).round(),
          );
        }
      } else if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      
      return DateTime.now();
    }

    return MoodCheckIn(
      id: json['id'] as String,
      userId: json['user_id'] ?? json['userId'] ?? '',
      mood: json['mood'] as String,
      notes: json['notes'] as String?,
      createdAt: parseTimestamp(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mood': mood,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Model class for mood statistics
class MoodStats {
  final int totalCheckIns;
  final String? dominantMood;
  final Map<String, int> moodDistribution;
  final List<MoodTrend> trends;

  MoodStats({
    required this.totalCheckIns,
    this.dominantMood,
    required this.moodDistribution,
    required this.trends,
  });

  factory MoodStats.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing MoodStats from JSON: $json');
    
    final distributionData = json['mood_distribution'] ?? json['moodDistribution'] ?? {};
    final trendsData = json['mood_trend'] ?? json['trends'] ?? [];

    Map<String, int> parsedDistribution = {};
    int calculatedTotal = 0;
    
    if (distributionData is Map) {
      try {
        distributionData.forEach((key, value) {
          final count = (value is int) ? value : int.parse(value.toString());
          parsedDistribution[key.toString()] = count;
          calculatedTotal += count;
        });
      } catch (e) {
        print('⚠️ Error parsing mood distribution: $e');
      }
    }

    // Backend sends 'most_common_mood' instead of 'dominant_mood'
    final dominantMood = json['most_common_mood'] ?? 
                         json['dominant_mood'] ?? 
                         json['dominantMood'];
    
    // Calculate total from distribution if not provided
    final totalCheckIns = json['total_check_ins'] ?? 
                          json['totalCheckIns'] ?? 
                          calculatedTotal;
    
    print('✅ Parsed stats: total=$totalCheckIns, dominant=$dominantMood, distribution=$parsedDistribution');

    return MoodStats(
      totalCheckIns: totalCheckIns is int ? totalCheckIns : int.parse(totalCheckIns.toString()),
      dominantMood: dominantMood?.toString(),
      moodDistribution: parsedDistribution,
      trends: (trendsData as List)
          .map((trend) => MoodTrend.fromJson(trend as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Model class for mood trend data
class MoodTrend {
  final String date;
  final String mood;
  final int count;

  MoodTrend({
    required this.date,
    required this.mood,
    required this.count,
  });

  factory MoodTrend.fromJson(Map<String, dynamic> json) {
    return MoodTrend(
      date: json['date'] as String,
      mood: json['mood'] as String,
      count: json['count'] as int? ?? 1,
    );
  }
}

