import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../domain/models/meditation_session.dart';

class MeditationStep {
  final String instruction;
  final String description;
  final Duration duration;

  MeditationStep({
    required this.instruction,
    required this.description,
    required this.duration,
  });
}

class MeditationPlayerPage extends StatefulWidget {
  final MeditationSession session;

  const MeditationPlayerPage({
    super.key,
    required this.session,
  });

  @override
  State<MeditationPlayerPage> createState() => _MeditationPlayerPageState();
}

class _MeditationPlayerPageState extends State<MeditationPlayerPage> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _remainingTime = Duration.zero;
  Timer? _timer;
  int _currentStepIndex = 0;
  bool _isFavorite = false;
  late AnimationController _breathingController;

  final List<MeditationStep> _meditationSteps = [
    MeditationStep(
      instruction: "Prepare",
      description: "Find a comfortable position. Sit with your back straight but not stiff. Let your shoulders relax. Close your eyes gently.",
      duration: const Duration(seconds: 30),
    ),
    MeditationStep(
      instruction: "Deep Breathing",
      description: "Take a deep breath in through your nose, feeling your belly expand. Hold briefly. Then exhale slowly through your mouth.",
      duration: const Duration(seconds: 45),
    ),
    MeditationStep(
      instruction: "Body Awareness",
      description: "Bring attention to your body. Notice any tension or discomfort. Don't try to change anything, just observe with curiosity.",
      duration: const Duration(seconds: 45),
    ),
    MeditationStep(
      instruction: "Mind Settling",
      description: "Let your thoughts come and go naturally, like clouds in the sky. There's no need to follow them or push them away.",
      duration: const Duration(seconds: 60),
    ),
    MeditationStep(
      instruction: "Breath Focus",
      description: "Return your attention to your breath. Notice the natural rhythm of your breathing. No need to control it.",
      duration: const Duration(seconds: 45),
    ),
    MeditationStep(
      instruction: "Gentle Awareness",
      description: "Expand your awareness to include sounds around you, sensations in your body, and your current emotional state.",
      duration: const Duration(seconds: 45),
    ),
    MeditationStep(
      instruction: "Completion",
      description: "Take a few deep breaths. Wiggle your fingers and toes. When you're ready, slowly open your eyes.",
      duration: const Duration(seconds: 30),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _remainingTime = _meditationSteps[0].duration;
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      } else {
        // Move to next step
        if (_currentStepIndex < _meditationSteps.length - 1) {
          setState(() {
            _currentStepIndex++;
            _remainingTime = _meditationSteps[_currentStepIndex].duration;
          });
        } else {
          // Meditation complete
          _stopTimer();
          setState(() {
            _isPlaying = false;
            _currentStepIndex = 0;
            _remainingTime = _meditationSteps[0].duration;
          });
          _showCompletionDialog();
        }
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startTimer();
        _breathingController.repeat(reverse: true);
      } else {
        _stopTimer();
        _breathingController.stop();
      }
    });
  }

  void _resetMeditation() {
    _stopTimer();
    setState(() {
      _isPlaying = false;
      _currentStepIndex = 0;
      _remainingTime = _meditationSteps[0].duration;
    });
    _breathingController.reset();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D1D1D),
          title: Text(
            'Meditation Complete',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF4ECDC4),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Great job! Take a moment to notice how you feel.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Done',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4ECDC4),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _stopTimer();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.session.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.session.category,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxHeight = constraints.maxHeight;
                  final maxWidth = constraints.maxWidth;
                  final animationSize = maxHeight * 0.4; // 40% of available height
                  final descriptionMaxHeight = maxHeight * 0.25; // 25% of available height
                  
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),
                        // Breathing Animation
                        Container(
                          width: animationSize,
                          height: animationSize,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D1D1D),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: GestureDetector(
                            onTap: _togglePlayback,
                            child: AnimatedBuilder(
                              animation: _breathingController,
                              builder: (context, child) {
                                final baseSize = animationSize * 0.65;
                                final maxExpansion = baseSize * 0.25;
                                
                                return Container(
                                  width: baseSize + (_breathingController.value * maxExpansion),
                                  height: baseSize + (_breathingController.value * maxExpansion),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF4ECDC4).withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: (baseSize * 0.875) + (_breathingController.value * maxExpansion * 0.5),
                                      height: (baseSize * 0.875) + (_breathingController.value * maxExpansion * 0.5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF4ECDC4).withOpacity(0.2),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: baseSize * 0.75,
                                          height: baseSize * 0.75,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF4ECDC4),
                                          ),
                                          
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const Spacer(flex: 1),
                        // Description
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: descriptionMaxHeight,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _meditationSteps[_currentStepIndex].description,
                              style: GoogleFonts.poppins(
                                fontSize: maxWidth > 400 ? 16 : 14,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: maxHeight * 0.03), // 3% of available height
                      ],
                    ),
                  );
                },
              ),
            ),

            // Controls
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1D),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress Indicator
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4ECDC4).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _currentStepIndex / (_meditationSteps.length - 1),
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // Time and Step Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4ECDC4).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _formatDuration(_remainingTime),
                          style: GoogleFonts.poppins(
                            fontSize: MediaQuery.of(context).size.width > 400 ? 18 : 16,
                            color: const Color(0xFF4ECDC4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Step ${_currentStepIndex + 1} of ${_meditationSteps.length}',
                          style: GoogleFonts.poppins(
                            fontSize: MediaQuery.of(context).size.width > 400 ? 16 : 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay, color: Colors.white, size: 28),
                        onPressed: _resetMeditation,
                      ),
                      GestureDetector(
                        onTap: _togglePlayback,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4ECDC4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
                        onPressed: _currentStepIndex < _meditationSteps.length - 1
                            ? () {
                                setState(() {
                                  _currentStepIndex++;
                                  _remainingTime = _meditationSteps[_currentStepIndex].duration;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 