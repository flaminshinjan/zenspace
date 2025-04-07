import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'exercise_guide_page.dart';

class MentalExercise {
  final String title;
  final String description;
  final String duration;
  final IconData icon;
  final List<String> steps;

  const MentalExercise({
    required this.title,
    required this.description,
    required this.duration,
    required this.icon,
    required this.steps,
  });
}

class MentalExercisesPage extends StatelessWidget {
  final String mood;

  const MentalExercisesPage({
    Key? key,
    required this.mood,
  }) : super(key: key);

  List<MentalExercise> _getExercisesForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return [
          MentalExercise(
            title: 'Gratitude Practice',
            description: 'Take a moment to appreciate the good things in life',
            duration: '5 minutes',
            icon: Icons.favorite,
            steps: [
              'Find a quiet, comfortable space',
              'Close your eyes and take 3 deep breaths',
              'Think of 3 things you\'re grateful for today',
              'Write them down in detail',
              'Reflect on how these things make you feel',
            ],
          ),
          MentalExercise(
            title: 'Positive Affirmations',
            description: 'Boost your positive mindset with affirmations',
            duration: '3 minutes',
            icon: Icons.psychology,
            steps: [
              'Stand in front of a mirror',
              'Take 3 deep breaths',
              'Repeat 5 positive affirmations',
              'Feel the energy of each affirmation',
              'End with a smile and gratitude',
            ],
          ),
        ];
      case 'sad':
        return [
          MentalExercise(
            title: 'Compassion Meditation',
            description: 'Practice self-compassion and kindness',
            duration: '10 minutes',
            icon: Icons.self_improvement,
            steps: [
              'Find a comfortable seated position',
              'Place your hand on your heart',
              'Take 5 deep breaths',
              'Repeat: "May I be kind to myself"',
              'Visualize sending love to yourself',
            ],
          ),
          MentalExercise(
            title: 'Mood Boosting Walk',
            description: 'A gentle walk to lift your spirits',
            duration: '15 minutes',
            icon: Icons.directions_walk,
            steps: [
              'Put on comfortable shoes',
              'Walk at a gentle pace',
              'Notice 5 things you can see',
              'Notice 4 things you can touch',
              'Notice 3 things you can hear',
              'Notice 2 things you can smell',
              'Notice 1 thing you can taste',
            ],
          ),
        ];
      case 'anxious':
        return [
          MentalExercise(
            title: 'Box Breathing',
            description: 'A powerful technique to calm anxiety',
            duration: '5 minutes',
            icon: Icons.air,
            steps: [
              'Sit in a comfortable position',
              'Inhale for 4 counts',
              'Hold for 4 counts',
              'Exhale for 4 counts',
              'Hold for 4 counts',
              'Repeat 5 times',
            ],
          ),
          MentalExercise(
            title: 'Grounding Exercise',
            description: 'Connect with the present moment',
            duration: '3 minutes',
            icon: Icons.anchor,
            steps: [
              'Name 5 things you can see',
              'Name 4 things you can touch',
              'Name 3 things you can hear',
              'Name 2 things you can smell',
              'Name 1 thing you can taste',
            ],
          ),
        ];
      case 'angry':
        return [
          MentalExercise(
            title: 'Anger Release',
            description: 'Safely release built-up tension',
            duration: '5 minutes',
            icon: Icons.sports_martial_arts,
            steps: [
              'Find a private space',
              'Take 3 deep breaths',
              'Clench your fists tightly',
              'Hold for 5 seconds',
              'Release slowly',
              'Repeat 3 times',
            ],
          ),
          MentalExercise(
            title: 'Cooling Breath',
            description: 'A cooling breath technique to reduce anger',
            duration: '3 minutes',
            icon: Icons.ac_unit,
            steps: [
              'Sit comfortably',
              'Roll your tongue',
              'Inhale through rolled tongue',
              'Close mouth and exhale through nose',
              'Repeat 10 times',
            ],
          ),
        ];
      case 'calm':
        return [
          MentalExercise(
            title: 'Mindful Breathing',
            description: 'Maintain your calm state',
            duration: '5 minutes',
            icon: Icons.spa,
            steps: [
              'Find a quiet space',
              'Sit comfortably',
              'Focus on your breath',
              'Notice the sensation',
              'Return focus when mind wanders',
            ],
          ),
          MentalExercise(
            title: 'Body Scan',
            description: 'A gentle body awareness practice',
            duration: '10 minutes',
            icon: Icons.accessibility_new,
            steps: [
              'Lie down comfortably',
              'Close your eyes',
              'Scan from toes to head',
              'Notice any sensations',
              'Release tension as you go',
            ],
          ),
        ];
      default:
        return [
          MentalExercise(
            title: 'Basic Breathing',
            description: 'A simple breathing exercise',
            duration: '3 minutes',
            icon: Icons.air,
            steps: [
              'Sit comfortably',
              'Take deep breaths',
              'Count to 4 as you inhale',
              'Count to 4 as you exhale',
              'Repeat 10 times',
            ],
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _getExercisesForMood(mood);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mental Exercises',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(
                exercise.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${exercise.description} • ${exercise.duration}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
              leading: Icon(
                exercise.icon,
                color: Theme.of(context).primaryColor,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Steps:',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...exercise.steps.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key + 1}. ',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseGuidePage(
                                  title: exercise.title,
                                  steps: exercise.steps,
                                  duration: exercise.duration,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Start Exercise',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 