import 'dart:math';
import '../models/wellness_data.dart';

/// Generates realistic dummy Apple Watch psycho-physiological data
/// for development and demo purposes
class WellnessDummyData {
  static final Random _random = Random();

  /// Get today's wellness data with slight variation
  static WellnessData getTodayData() {
    final now = DateTime.now();
    return WellnessData(
      heartRateBpm: _randomDouble(62, 88),
      heartRateVariabilityMs: _randomDouble(35.0, 65.0),
      sleepHours: _randomInt(5, 9),
      sleepQuality: _randomInt(55, 95),
      stepsCount: _randomInt(3000, 12000),
      stressLevel: _randomDouble(2.0, 7.0),
      respiratoryRate: _randomDouble(12.0, 18.0),
      activeMinutes: _randomInt(20, 90),
      collectedAt: now,
    );
  }

  /// Get wellness data with configurable "profile" (good, average, stressed)
  static WellnessData getProfileData(String profile) {
    final now = DateTime.now();
    switch (profile.toLowerCase()) {
      case 'stressed':
        return WellnessData(
          heartRateBpm: _randomDouble(78, 95),
          heartRateVariabilityMs: _randomDouble(25.0, 40.0),
          sleepHours: _randomInt(4, 6),
          sleepQuality: _randomInt(40, 60),
          stepsCount: _randomInt(2000, 5000),
          stressLevel: _randomDouble(6.0, 9.0),
          respiratoryRate: _randomDouble(16.0, 22.0),
          activeMinutes: _randomInt(10, 35),
          collectedAt: now,
        );
      case 'balanced':
        return WellnessData(
          heartRateBpm: _randomDouble(65, 78),
          heartRateVariabilityMs: _randomDouble(45.0, 60.0),
          sleepHours: _randomInt(6, 8),
          sleepQuality: _randomInt(70, 85),
          stepsCount: _randomInt(6000, 10000),
          stressLevel: _randomDouble(3.0, 5.0),
          respiratoryRate: _randomDouble(13.0, 16.0),
          activeMinutes: _randomInt(40, 65),
          collectedAt: now,
        );
      default: // 'good' or default
        return WellnessData(
          heartRateBpm: _randomDouble(58, 72),
          heartRateVariabilityMs: _randomDouble(50.0, 75.0),
          sleepHours: _randomInt(7, 9),
          sleepQuality: _randomInt(80, 98),
          stepsCount: _randomInt(8000, 15000),
          stressLevel: _randomDouble(1.5, 3.5),
          respiratoryRate: _randomDouble(12.0, 15.0),
          activeMinutes: _randomInt(50, 90),
          collectedAt: now,
        );
    }
  }

  /// Get 7 days of wellness data for trend visualization
  static List<WellnessData> getWeekData() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return WellnessData(
        heartRateBpm: _randomDouble(60, 90),
        heartRateVariabilityMs: _randomDouble(30.0, 70.0),
        sleepHours: _randomInt(5, 9),
        sleepQuality: _randomInt(50, 95),
        stepsCount: _randomInt(2500, 14000),
        stressLevel: _randomDouble(2.0, 8.0),
        respiratoryRate: _randomDouble(12.0, 18.0),
        activeMinutes: _randomInt(15, 85),
        collectedAt: date,
      );
    });
  }

  static int _randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  static double _randomDouble(num min, num max) {
    return min + _random.nextDouble() * (max - min);
  }
}
