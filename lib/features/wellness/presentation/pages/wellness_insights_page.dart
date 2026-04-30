import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenspace/core/theme/app_colors.dart';
import 'package:zenspace/core/services/wellness_service_api.dart';
import 'package:zenspace/features/wellness/data/wellness_insights_cache.dart';
import 'package:zenspace/features/wellness/models/wellness_data.dart';
import 'package:zenspace/features/wellness/presentation/widgets/wellness_suggestion_card.dart';

class WellnessInsightsPage extends StatefulWidget {
  final WellnessData wellnessData;
  final String? additionalContext;

  const WellnessInsightsPage({
    super.key,
    required this.wellnessData,
    this.additionalContext,
  });

  @override
  State<WellnessInsightsPage> createState() => _WellnessInsightsPageState();
}

class _WellnessInsightsPageState extends State<WellnessInsightsPage> {
  static const Color _darkGray2 = Color(0xFF222222);

  final WellnessServiceApi _wellnessService = WellnessServiceApi();
  final WellnessInsightsCache _insightsCache = WellnessInsightsCache();
  bool _isLoading = true;
  List<WellnessSuggestion> _suggestions = [];
  String? _errorMessage;
  final Set<String> _completedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchInsights();
  }

  String _getDataSummary() {
    final d = widget.wellnessData;
    final parts = <String>[];
    if (d.heartRateBpm > 80) parts.add('elevated heart rate');
    if (d.heartRateVariabilityMs < 45) parts.add('lower HRV');
    if (d.sleepHours < 6) parts.add('short sleep');
    if (d.stressLevel > 6) parts.add('elevated stress');
    if (parts.isEmpty) return 'Your metrics look balanced today. Here are tailored tips to keep you feeling your best.';
    return 'Based on your ${parts.join(", ")}${parts.length > 1 ? "," : ""} these suggestions can help you feel more grounded.';
  }

  Future<void> _fetchInsights() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _suggestions = [];
    });

    final response = await _wellnessService.getInsights(
      wellnessData: widget.wellnessData,
      additionalContext: widget.additionalContext,
    );

    if (!mounted) return;

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      await _insightsCache.save(
        WellnessInsightsCacheEntry(
          wellnessData: widget.wellnessData,
          suggestions: response.data!,
          additionalContext: widget.additionalContext,
          fetchedAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _suggestions = response.data!;
        _isLoading = false;
      });
    } else if (response.success && (response.data == null || response.data!.isEmpty)) {
      setState(() {
        _isLoading = false;
        _suggestions = _getFallbackSuggestions();
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = response.error?.message ?? 'Unable to fetch insights. Showing sample tips.';
        _suggestions = _getFallbackSuggestions();
      });
    }
  }

  List<WellnessSuggestion> _getFallbackSuggestions() {
    return [
      WellnessSuggestion(
        id: '1',
        title: 'Take a breath break',
        description: 'Your heart rate and stress indicators suggest a moment of calm would help. Try 4-7-8 breathing: inhale 4 counts, hold 7, exhale 8.',
        category: 'emotional',
        priority: 1,
        actionStep: 'Find a quiet spot and practice 3 cycles',
        duration: '2 min',
      ),
      WellnessSuggestion(
        id: '2',
        title: 'Light movement',
        description: 'A short walk or gentle stretch can improve HRV and mood. Your body responds well to moderate activity.',
        category: 'physical',
        priority: 2,
        actionStep: 'Walk for 10 minutes or do 5 min stretching',
        duration: '10 min',
      ),
      WellnessSuggestion(
        id: '3',
        title: 'Mindful hydration',
        description: 'Proper hydration supports both physical and emotional stability. Keep water nearby and take small sips throughout the day.',
        category: 'physical',
        priority: 3,
        actionStep: 'Drink a full glass of water now',
        duration: '1 min',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                          'Your Insights',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Personalized for your body',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : _fetchInsights,
                    icon: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 22),
                    tooltip: 'Get new insights',
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF7C9A92),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Analyzing your data...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is preparing personalized suggestions',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C9A92).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: const Color(0xFF7C9A92), size: 20),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getDataSummary(),
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB74D).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFFFB74D), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suggestions for you',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_completedIds.isNotEmpty)
                Text(
                  '${_completedIds.length}/${_suggestions.length} done',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ..._suggestions.asMap().entries.map((entry) {
            final isCompleted = _completedIds.contains(entry.value.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WellnessSuggestionCard(
                suggestion: entry.value,
                isCompleted: isCompleted,
                onTap: () => _showSuggestionDetail(entry.value),
                onComplete: () {
                  setState(() {
                    if (_completedIds.contains(entry.value.id)) {
                      _completedIds.remove(entry.value.id);
                    } else {
                      _completedIds.add(entry.value.id);
                    }
                  });
                },
              ),
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showSuggestionDetail(WellnessSuggestion suggestion) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: _darkGray2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        _getCategoryIcon(suggestion.category),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            suggestion.title,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      suggestion.description,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (suggestion.actionStep != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C9A92).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF7C9A92).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.touch_app, color: Color(0xFF7C9A92), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Try this',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              suggestion.actionStep!,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (suggestion.duration != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '⏱ ${suggestion.duration}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary.withOpacity(0.8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                if (_completedIds.contains(suggestion.id)) {
                                  _completedIds.remove(suggestion.id);
                                } else {
                                  _completedIds.add(suggestion.id);
                                }
                              });
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              _completedIds.contains(suggestion.id) ? Icons.check_circle : Icons.check_circle_outline,
                              size: 18,
                              color: const Color(0xFF7C9A92),
                            ),
                            label: Text(
                              _completedIds.contains(suggestion.id) ? 'Marked done' : 'Mark as done',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7C9A92),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF7C9A92)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 18),
                            label: Text(
                              'Close',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C9A92),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData icon;
    Color color;
    switch (category.toLowerCase()) {
      case 'emotional':
        icon = Icons.favorite;
        color = const Color(0xFFE57373);
        break;
      case 'physical':
        icon = Icons.fitness_center;
        color = const Color(0xFF81C784);
        break;
      case 'sleep':
        icon = Icons.bedtime;
        color = const Color(0xFF64B5F6);
        break;
      case 'stress':
        icon = Icons.psychology;
        color = const Color(0xFFFFB74D);
        break;
      default:
        icon = Icons.spa;
        color = const Color(0xFF7C9A92);
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
