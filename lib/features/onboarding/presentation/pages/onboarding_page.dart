import 'package:flutter/material.dart';
import 'package:zenspace/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenspace/features/onboarding/presentation/pages/onboarding_complete_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentQuestionIndex = 0;
  Map<String, List<String>> _selectedAnswers = {};
  DateTime _currentDate = DateTime.now();

  final List<Map<String, dynamic>> _questions = [
    {
      'id': '1',
      'question': 'What would you like to do?',
      'subtitle': 'You can pick more than one and easily change it later.',
      'options': [
        'Everyday Planning',
        'Reflection and Diary',
        'Manage Stressful Situations',
        'Boost Positive Thinking',
        'Discover Myself',
        'Journal on My Own',
      ],
      'footer': 'Your choices won\'t limit access to any features of the app.',
    },
    {
      'id': '2',
      'question': 'What would you like to improve in your life?',
      'subtitle': 'Our science-backed tools are designed to help.',
      'options': [
        'Improve mood',
        'Increase productivity',
        'Improve sleep quality',
        'Reduce stress & anxiety',
        'Something else',
      ],
      'footer': 'Your choices won\'t limit access to any features of the app.',
    },
    {
      'id': '3',
      'question': 'How old are you?',
      'subtitle': 'Our science-backed tools are designed to help.',
      'options': [
        'Under 18',
        '18-24',
        '25-34',
        '35-44',
        '45-54',
        '55-64',
        'Over 64',
      ],
      'footer': 'Your choices won\'t limit access to any features of the app.',
    },
    {
      'id': '4',
      'question': 'Healthy habits are built through consistency.',
      'subtitle': 'When do you want to carve out time for your self-care reflections?',
      'type': 'time_selection',
      'times': {
        'MORNING': '8:00 AM',
        'DAY': '2:30 PM',
        'EVENING': '9:00 PM',
      },
    },
    {
      'id': '5',
      'question': 'How are you feeling?',
      'type': 'mood_selection',
      'date': null,
      'options': [
        '😢',
        '😕',
        '😐',
        '🙂',
        '😊',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _questions[4]['date'] = '${_currentDate.day} March ${_currentDate.year} at ${_formatTime(_currentDate)}';
    // Initialize selected answers map
    for (var question in _questions) {
      _selectedAnswers[question['id']] = [];
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  void _onOptionSelected(String questionId, String option) {
    setState(() {
      if (_selectedAnswers.containsKey(questionId)) {
        final answers = _selectedAnswers[questionId]!;
        if (answers.contains(option)) {
          answers.remove(option);
        } else {
          answers.add(option);
        }
      } else {
        _selectedAnswers[questionId] = [option];
      }
    });
  }

  void _onNext() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Save answers and navigate to completion
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingCompletePage()),
      );
    }
  }

  void _onBack() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final selectedAnswers = _selectedAnswers[currentQuestion['id']] ?? [];

    Widget optionsWidget;
    
    if (currentQuestion['type'] == 'time_selection') {
      optionsWidget = _buildTimeSelectionOptions(currentQuestion);
    } else if (currentQuestion['type'] == 'mood_selection') {
      optionsWidget = _buildMoodSelectionOptions(currentQuestion, selectedAnswers);
    } else {
      optionsWidget = _buildRegularOptions(currentQuestion, selectedAnswers);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress and Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                      size: 28,
                    ),
                    onPressed: _currentQuestionIndex > 0 ? _onBack : null,
                  ),
                  Text(
                    '${_currentQuestionIndex + 1}/${_questions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: _onNext,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // Question
              Text(
                currentQuestion['question'],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (currentQuestion['subtitle'] != null) ...[
                const SizedBox(height: 12),
                Text(
                  currentQuestion['subtitle'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              
              // Options
              Expanded(child: optionsWidget),
              
              // Footer
              if (currentQuestion['footer'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    currentQuestion['footer'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Next Button
              if (currentQuestion['type'] != 'mood_selection')
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedAnswers.isNotEmpty ? _onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black,
                    ),
                    child: Text(
                      _currentQuestionIndex == _questions.length - 1 ? 'Complete' : 'Continue',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelectionOptions(Map<String, dynamic> question) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: (question['times'] as Map<String, String>).entries.map((entry) {
        final time = entry.key;
        final timeValue = entry.value;
        final isSelected = _selectedAnswers[question['id']]?.contains(time) ?? false;

        return GestureDetector(
          onTap: () => _onOptionSelected(question['id'], time),
          child: Column(
            children: [
              Icon(
                time == 'MORNING' ? Icons.wb_sunny_outlined :
                time == 'DAY' ? Icons.wb_sunny :
                Icons.mode_night_outlined,
                size: 32,
                color: Colors.black87,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFC107) : const Color(0xFFFFF3D0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: isSelected ? [
                    const BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ] : null,
                ),
                child: Column(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeValue,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodSelectionOptions(Map<String, dynamic> question, List<String> selectedAnswers) {
    return Column(
      children: [
        if (question['date'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              question['date'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: (question['options'] as List<String>).map((emoji) {
            final isSelected = selectedAnswers.contains(emoji);
            
            return GestureDetector(
              onTap: () {
                _onOptionSelected(question['id'], emoji);
                // Auto-advance after mood selection
                Future.delayed(const Duration(milliseconds: 300), _onNext);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFC107) : const Color(0xFFFFF3D0),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: isSelected ? [
                    const BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ] : null,
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRegularOptions(Map<String, dynamic> question, List<String> selectedAnswers) {
    return ListView.builder(
      itemCount: question['options'].length,
      itemBuilder: (context, index) {
        final option = question['options'][index];
        final isSelected = selectedAnswers.contains(option);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _onOptionSelected(question['id'], option),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFC107) : const Color(0xFFFFF3D0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                boxShadow: isSelected ? [
                  const BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.black87,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 