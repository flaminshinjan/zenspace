import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenspace/core/services/mood_service_api.dart';
import 'package:zenspace/features/mood/models/mood_check_in.dart';
import 'package:intl/intl.dart';

class MoodCheckInWidget extends StatefulWidget {
  const MoodCheckInWidget({super.key});

  @override
  State<MoodCheckInWidget> createState() => _MoodCheckInWidgetState();
}

class _MoodCheckInWidgetState extends State<MoodCheckInWidget> {
  final MoodServiceApi _moodService = MoodServiceApi();
  bool _isLoading = false;
  bool _hasCheckedInToday = false;
  MoodCheckIn? _todayCheckIn;
  MoodStats? _moodStats;
  String? _selectedMood;
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {
      'value': 'very_sad',
      'label': 'Very Sad',
      'emoji': '😢',
      'color': const Color(0xFF6B4C9A),
    },
    {
      'value': 'sad',
      'label': 'Sad',
      'emoji': '😔',
      'color': const Color(0xFF8B6BB7),
    },
    {
      'value': 'neutral',
      'label': 'Neutral',
      'emoji': '😐',
      'color': const Color(0xFF9E9E9E),
    },
    {
      'value': 'happy',
      'label': 'Happy',
      'emoji': '😊',
      'color': const Color(0xFF4CAF50),
    },
    {
      'value': 'very_happy',
      'label': 'Very Happy',
      'emoji': '😄',
      'color': const Color(0xFF8BC34A),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTodayCheckIn();
    _loadStats();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayCheckIn() async {
    try {
      print('🔄 Loading today\'s check-in...');
      final response = await _moodService.getTodayCheckIn();
      print('📥 Today check-in response: ${response.success}, data: ${response.data}');
      
      if (response.success && response.data != null) {
        setState(() {
          _todayCheckIn = MoodCheckIn.fromJson(response.data!);
          _hasCheckedInToday = true;
        });
        print('✅ Today check-in loaded: ${_todayCheckIn?.mood}');
      } else {
        setState(() {
          _hasCheckedInToday = false;
        });
        print('ℹ️ No check-in today or error: ${response.error?.message}');
      }
    } catch (e, stack) {
      print('❌ Error loading today check-in: $e');
      print('Stack trace: $stack');
      setState(() {
        _hasCheckedInToday = false;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      print('🔄 Loading mood stats...');
      final response = await _moodService.getStats(period: 'week');
      print('📥 Stats response: ${response.success}');
      print('📊 Stats data: ${response.data}');
      
      if (response.success && response.data != null) {
        setState(() {
          _moodStats = MoodStats.fromJson(response.data!);
        });
        print('✅ Stats loaded: ${_moodStats?.totalCheckIns} check-ins, dominant: ${_moodStats?.dominantMood}');
      } else {
        print('❌ Stats error: ${response.error?.message}');
      }
    } catch (e, stack) {
      print('❌ Error loading mood stats: $e');
      print('Stack trace: $stack');
    }
  }

  Future<void> _submitCheckIn() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔄 Submitting check-in: $_selectedMood');
      final response = await _moodService.createCheckIn(
        mood: _selectedMood!,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      print('📥 Create check-in response: ${response.success}, data: ${response.data}');

      if (response.success) {
        setState(() {
          _hasCheckedInToday = true;
          _todayCheckIn = MoodCheckIn.fromJson(response.data!);
          _selectedMood = null;
          _notesController.clear();
        });

        print('✅ Check-in saved: ${_todayCheckIn?.id}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mood check-in saved!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }

        // Reload stats after successful save
        print('🔄 Reloading stats after save...');
        await _loadStats();
      } else {
        print('❌ Check-in failed: ${response.error?.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response.error?.message ?? "Failed to save check-in"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stack) {
      print('❌ Error submitting check-in: $e');
      print('Stack trace: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getMoodEmoji(String mood) {
    final moodData = _moods.firstWhere(
      (m) => m['value'] == mood,
      orElse: () => _moods[2], // Default to neutral
    );
    return moodData['emoji'] as String;
  }

  String _getMoodLabel(String mood) {
    final moodData = _moods.firstWhere(
      (m) => m['value'] == mood,
      orElse: () => _moods[2], // Default to neutral
    );
    return moodData['label'] as String;
  }

  void _showCheckInDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling?',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Mood selection
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _moods.map((mood) {
                      final isSelected = _selectedMood == mood['value'];
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            _selectedMood = mood['value'] as String;
                          });
                          setState(() {});
                        },
                        child: Container(
                          width: 70,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (mood['color'] as Color).withOpacity(0.2)
                                : const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? mood['color'] as Color
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                mood['emoji'] as String,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mood['label'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notes field
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add notes (optional)...',
                      hintStyle: GoogleFonts.poppins(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedMood = null;
                            _notesController.clear();
                          });
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.white54),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                Navigator.pop(context);
                                await _submitCheckIn();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Save',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mood Check-In',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (!_hasCheckedInToday)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _showCheckInDialog,
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white70, size: 20),
                ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          if (_hasCheckedInToday && _todayCheckIn != null)
            _buildTodayCheckIn()
          else
            _buildCheckInPrompt(),
          
          if (_moodStats != null)
            _buildStats(),
        ],
      ),
    );
  }

  Widget _buildTodayCheckIn() {
    if (_todayCheckIn == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            _getMoodEmoji(_todayCheckIn!.mood),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'re feeling ${_getMoodLabel(_todayCheckIn!.mood).toLowerCase()}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('h:mm a').format(_todayCheckIn!.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInPrompt() {
    return GestureDetector(
      onTap: _showCheckInDialog,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.sentiment_satisfied_alt_outlined,
              color: Colors.white54,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tap to check in your mood',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    if (_moodStats == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Divider(color: Colors.white.withOpacity(0.05), height: 1),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Check-ins',
                _moodStats!.totalCheckIns.toString(),
              ),
            ),
            const SizedBox(width: 12),
            if (_moodStats!.dominantMood != null)
              Expanded(
                child: _buildStatItem(
                  'Dominant',
                  _getMoodEmoji(_moodStats!.dominantMood!),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white38,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

