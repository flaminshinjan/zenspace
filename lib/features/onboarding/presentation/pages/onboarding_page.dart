import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _questions = [
    {
      'question': 'What do you want to achieve with rewind.ai?',
      'options': '''
- Message better (serious with people)
- Message better (serious with work)
- Message better (serious with friends)
- Message better (serious with family)
- Message better (serious with everyone)
      ''',
    },
    {
      'question': 'How do you want to improve your communication?',
      'options': '''
- Be more empathetic
- Be more assertive
- Be more concise
- Be more engaging
- Be more professional
      ''',
    },
    {
      'question': 'What are your communication challenges?',
      'options': '''
- Difficulty expressing emotions
- Misunderstandings
- Conflict resolution
- Public speaking
- Written communication
      ''',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Text(
                'rewind.ai',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _questions[index]['question']!,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        ..._questions[index]['options']!
                            .trim()
                            .split('\n')
                            .map((option) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: InkWell(
                                    onTap: () {
                                      if (_currentPage < _questions.length - 1) {
                                        _pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      } else {
                                        // TODO: Navigate to home page
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        option.substring(2),
                                        style:
                                            Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _questions.length,
                  effect: WormEffect(
                    dotColor: Colors.white.withOpacity(0.2),
                    activeDotColor: Theme.of(context).primaryColor,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 