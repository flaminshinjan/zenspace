import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenspace/features/wellness/models/wellness_data.dart';

class WellnessInsightsCacheEntry {
  final WellnessData wellnessData;
  final List<WellnessSuggestion> suggestions;
  final String? additionalContext;
  final DateTime fetchedAt;

  WellnessInsightsCacheEntry({
    required this.wellnessData,
    required this.suggestions,
    this.additionalContext,
    required this.fetchedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'wellness_data': wellnessData.toJson(),
      'suggestions': suggestions.map((s) => s.toJson()).toList(),
      'additional_context': additionalContext,
      'fetched_at': fetchedAt.toIso8601String(),
    };
  }

  factory WellnessInsightsCacheEntry.fromJson(Map<String, dynamic> json) {
    final suggestionsJson = (json['suggestions'] as List<dynamic>? ?? []);
    return WellnessInsightsCacheEntry(
      wellnessData: WellnessData.fromJson(
        (json['wellness_data'] as Map<String, dynamic>? ?? {}),
      ),
      suggestions: suggestionsJson
          .map((item) => WellnessSuggestion.fromJson(item as Map<String, dynamic>))
          .toList(),
      additionalContext: json['additional_context'] as String?,
      fetchedAt: json['fetched_at'] != null
          ? DateTime.parse(json['fetched_at'] as String)
          : DateTime.now(),
    );
  }
}

class WellnessInsightsCache {
  static const String _cacheKey = 'wellness_insights_cache_v1';

  Future<void> save(WellnessInsightsCacheEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(entry.toJson()));
  }

  Future<WellnessInsightsCacheEntry?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return WellnessInsightsCacheEntry.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
