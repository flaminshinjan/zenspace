import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenspace/core/theme/app_colors.dart';
import 'package:zenspace/features/wellness/data/wellness_dummy_data.dart';
import 'package:zenspace/features/wellness/models/wellness_data.dart';
import 'package:zenspace/features/wellness/presentation/pages/wellness_insights_page.dart';

class WellnessOverviewPage extends StatefulWidget {
  const WellnessOverviewPage({super.key});

  @override
  State<WellnessOverviewPage> createState() => _WellnessOverviewPageState();
}

class _WellnessOverviewPageState extends State<WellnessOverviewPage> {
  static const Color _darkGray2 = Color(0xFF222222);
  static const Color _darkGray3 = Color(0xFF2A2A2A);

  late WellnessData _wellnessData;
  List<WellnessData> _weekData = [];
  String _selectedProfile = 'today';
  final TextEditingController _contextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _wellnessData = WellnessDummyData.getTodayData();
    _weekData = WellnessDummyData.getWeekData();
  }

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _wellnessData = _selectedProfile == 'today'
          ? WellnessDummyData.getTodayData()
          : WellnessDummyData.getProfileData(_selectedProfile);
      _weekData = WellnessDummyData.getWeekData();
    });
  }

  void _selectProfile(String profile) {
    setState(() {
      _selectedProfile = profile;
      _wellnessData = profile == 'today'
          ? WellnessDummyData.getTodayData()
          : WellnessDummyData.getProfileData(profile);
    });
  }

  void _navigateToInsights() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WellnessInsightsPage(
          wellnessData: _wellnessData,
          additionalContext: _contextController.text.trim().isEmpty
              ? null
              : _contextController.text.trim(),
        ),
      ),
    );
  }

  int _getReadinessScore() {
    double score = 100;
    if (_wellnessData.heartRateBpm > 85) score -= 15;
    else if (_wellnessData.heartRateBpm > 75) score -= 5;
    if (_wellnessData.heartRateVariabilityMs < 40) score -= 15;
    else if (_wellnessData.heartRateVariabilityMs < 50) score -= 5;
    if (_wellnessData.sleepHours < 6) score -= 20;
    else if (_wellnessData.sleepHours < 7) score -= 10;
    if (_wellnessData.sleepQuality < 60) score -= 15;
    if (_wellnessData.stressLevel > 7) score -= 20;
    else if (_wellnessData.stressLevel > 5) score -= 10;
    return score.clamp(0, 100).round();
  }

  String _getReadinessLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 65) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs rest';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildReadinessCard(),
                    const SizedBox(height: 20),
                    _buildDataProfileSelector(),
                    const SizedBox(height: 20),
                    _buildWeekTrendStrip(),
                    const SizedBox(height: 24),
                    _buildContextInput(),
                    const SizedBox(height: 20),
                    _buildInsightsCta(),
                    const SizedBox(height: 24),
                    _buildDataGrid(),
                    const SizedBox(height: 24),
                    _buildMetricGuides(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wellness Insights',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'From your Apple Watch',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 22),
          tooltip: 'Refresh data',
        ),
      ],
    );
  }

  Widget _buildReadinessCard() {
    final score = _getReadinessScore();
    final label = _getReadinessLabel(score);
    final color = score >= 80
        ? const Color(0xFF81C784)
        : score >= 65
            ? const Color(0xFF64B5F6)
            : score >= 50
                ? const Color(0xFFFFB74D)
                : const Color(0xFFE57373);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkGray2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _darkGray3, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$score',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Readiness Score',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on HR, HRV, sleep & stress',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataProfileSelector() {
    final profiles = [
      ('today', 'Today', Icons.today),
      ('balanced', 'Balanced', Icons.balance),
      ('stressed', 'Stressed', Icons.warning_amber_rounded),
      ('good', 'Optimal', Icons.emoji_emotions),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data profile',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: profiles.map((p) {
              final isSelected = _selectedProfile == p.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => _selectProfile(p.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF7C9A92).withValues(alpha: 0.25)
                          : _darkGray2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF7C9A92) : _darkGray3,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(p.$3, size: 18, color: isSelected ? const Color(0xFF7C9A92) : AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          p.$2,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekTrendStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '7-day trend',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _darkGray2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _darkGray3, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekData.asMap().entries.map((e) {
              const minHr = 50.0;
              const maxHr = 100.0;
              final normalized = ((e.value.heartRateBpm - minHr) / (maxHr - minHr)).clamp(0.0, 1.0);
              final height = 24 + normalized * 40;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: height,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C9A92).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][e.key],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add context (optional)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contextController,
          maxLines: 2,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g. "Had a stressful meeting", "Feeling tired"...',
            hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 13),
            filled: true,
            fillColor: _darkGray2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _darkGray3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsCta() {
    return GestureDetector(
      onTap: _navigateToInsights,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C9A92), Color(0xFF9BB8B3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C9A92).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              'Get AI Wellness Insights',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Physiological Data',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _buildMetricCard(
              icon: Icons.favorite,
              label: 'Heart Rate',
              value: '${_wellnessData.heartRateBpm.round()} bpm',
              color: const Color(0xFFE57373),
            ),
            _buildMetricCard(
              icon: Icons.show_chart,
              label: 'HRV',
              value: '${_wellnessData.heartRateVariabilityMs.round()} ms',
              color: const Color(0xFF81C784),
            ),
            _buildMetricCard(
              icon: Icons.bedtime,
              label: 'Sleep',
              value: '${_wellnessData.sleepHours}h',
              subtitle: '${_wellnessData.sleepQuality}% quality',
              color: const Color(0xFF64B5F6),
            ),
            _buildMetricCard(
              icon: Icons.directions_walk,
              label: 'Steps',
              value: _wellnessData.stepsCount.toString(),
              color: const Color(0xFFBA68C8),
            ),
            _buildMetricCard(
              icon: Icons.psychology,
              label: 'Stress',
              value: '${_wellnessData.stressLevel.toStringAsFixed(1)}/10',
              color: const Color(0xFFFFB74D),
            ),
            _buildMetricCard(
              icon: Icons.fitness_center,
              label: 'Active',
              value: '${_wellnessData.activeMinutes} min',
              color: const Color(0xFF4DB6AC),
            ),
            _buildMetricCard(
              icon: Icons.air,
              label: 'Respiratory',
              value: '${_wellnessData.respiratoryRate.toStringAsFixed(1)}/min',
              color: const Color(0xFF90A4AE),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricGuides() {
    final guides = [
      ('Heart Rate', '60–100 bpm at rest', Icons.favorite),
      ('HRV', 'Higher = more recovered', Icons.show_chart),
      ('Sleep', '7–9h for adults', Icons.bedtime),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick reference',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...guides.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _darkGray2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _darkGray3, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(g.$3, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.$1,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            g.$2,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _darkGray2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _darkGray3, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
