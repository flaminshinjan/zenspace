import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExerciseGuidePage extends StatefulWidget {
  final String title;
  final List<String> steps;
  final String duration;

  const ExerciseGuidePage({
    Key? key,
    required this.title,
    required this.steps,
    required this.duration,
  }) : super(key: key);

  @override
  State<ExerciseGuidePage> createState() => _ExerciseGuidePageState();
}

class _ExerciseGuidePageState extends State<ExerciseGuidePage> {
  int _currentStepIndex = 0;
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    // Parse duration string (e.g., "5 minutes" -> 300 seconds)
    final durationStr = widget.duration.toLowerCase();
    if (durationStr.contains('minute')) {
      final minutes = int.tryParse(durationStr.split(' ')[0]) ?? 5;
      _secondsRemaining = minutes * 60;
    } else {
      _secondsRemaining = 300; // Default to 5 minutes
    }
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _isCompleted = true;
        }
      });
    });
  }

  void _nextStep() {
    setState(() {
      if (_currentStepIndex < widget.steps.length - 1) {
        _currentStepIndex++;
      } else {
        _isCompleted = true;
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timer
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            // Progress indicator
            LinearProgressIndicator(
              value: _currentStepIndex / (widget.steps.length - 1),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            // Main content
            Expanded(
              child: _isCompleted
                  ? _buildCompletionView()
                  : _buildExerciseView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step number
          Text(
            'Step ${_currentStepIndex + 1} of ${widget.steps.length}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Current step
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  widget.steps[_currentStepIndex],
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Next button
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentStepIndex < widget.steps.length - 1
                  ? 'Next Step'
                  : 'Complete Exercise',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Exercise Completed!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Great job taking care of your mental health',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Return to Exercises',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 