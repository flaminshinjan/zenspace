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

  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      // Save the selected answers
      for (var entry in _selectedAnswers.entries) {
        await prefs.setStringList('onboarding_${entry.key}', entry.value);
      }
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingCompletePage(),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save preferences: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onNext() {
    // Only proceed if at least one option is selected for regular questions
    if (_questions[_currentQuestionIndex]['type'] == null && 
        _selectedAnswers[_questions[_currentQuestionIndex]['id']]!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one option'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _saveUserPreferences();
    }
  }

  void _onBack() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _onOptionSelected(String option, bool isSelected) {
    setState(() {
      final answers = _selectedAnswers[_questions[_currentQuestionIndex]['id']]!;
      if (isSelected) {
        if (!answers.contains(option)) {
          answers.add(option);
        }
      } else {
        answers.remove(option);
      }
    });

    // For mood selection, automatically go to next question when selecting a new option
    if (_questions[_currentQuestionIndex]['type'] == 'mood_selection' && isSelected) {
      _onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final currentAnswers = _selectedAnswers[currentQuestion['id']]!;

    return OnboardingQuestionPage(
      question: currentQuestion,
      selectedAnswers: currentAnswers,
      onNext: _onNext,
      onBack: _onBack,
      onOptionSelected: _onOptionSelected,
      currentIndex: _currentQuestionIndex,
      totalQuestions: _questions.length,
    );
  }
}

class OnboardingQuestionPage extends StatelessWidget {
  final Map<String, dynamic> question;
  final List<String> selectedAnswers;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(String, bool) onOptionSelected;
  final int currentIndex;
  final int totalQuestions;

  const OnboardingQuestionPage({
    super.key,
    required this.question,
    required this.selectedAnswers,
    required this.onNext,
    required this.onBack,
    required this.onOptionSelected,
    required this.currentIndex,
    required this.totalQuestions,
  });

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          question['subtitle'],
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTimeOption('MORNING', Icons.wb_sunny_outlined),
            _buildTimeOption('DAY', Icons.wb_sunny),
            _buildTimeOption('EVENING', Icons.mode_night_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeOption(String time, IconData icon) {
    final isSelected = selectedAnswers.contains(time);
    return Column(
      children: [
        Icon(icon, color: AppColors.textDark),
        Text(time),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryYellow : AppColors.lightYellow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(question['times'][time]),
        ),
        Switch(
          value: isSelected,
          onChanged: (value) {
            onOptionSelected(time, value);
          },
          activeColor: AppColors.primaryYellow,
        ),
      ],
    );
  }

  Widget _buildMoodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          question['date'],
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: question['options'].map<Widget>((emoji) {
            final isSelected = selectedAnswers.contains(emoji);
            return GestureDetector(
              onTap: () {
                onOptionSelected(emoji, !isSelected);
                if (!isSelected) {
                  onNext();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryYellow : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRegularQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        if (question['subtitle'] != null) ...[
          const SizedBox(height: 8),
          Text(
            question['subtitle'],
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
            ),
          ),
        ],
        const SizedBox(height: 24),
        ...question['options'].map((option) {
          final isSelected = selectedAnswers.contains(option);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => onOptionSelected(option, !isSelected),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryYellow : AppColors.lightYellow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.black,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.textDark,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        if (question['footer'] != null) ...[
          const SizedBox(height: 16),
          Text(
            question['footer'],
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.textDark),
                    onPressed: currentIndex > 0 ? onBack : null,
                  ),
                  Text(
                    '${currentIndex + 1}/$totalQuestions',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: onNext,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: question['type'] == 'time_selection'
                      ? _buildTimeSelection()
                      : question['type'] == 'mood_selection'
                          ? _buildMoodSelection()
                          : _buildRegularQuestion(),
                ),
              ),
              if (question['type'] != 'mood_selection') ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedAnswers.isNotEmpty ? onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentIndex < totalQuestions - 1 ? 'Next' : 'Complete',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 