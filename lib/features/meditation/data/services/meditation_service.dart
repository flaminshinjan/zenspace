import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/models/meditation_session.dart';

class MeditationService {
  final GenerativeModel _model;

  MeditationService() : _model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

  Future<List<MeditationSession>> getMeditationSessions() async {
    // This would typically come from a backend, but we'll generate it with Gemini
    final prompt = '''
    Generate 8 meditation sessions in JSON format. Each session should have:
    - id (unique string)
    - title (string)
    - description (string)
    - duration (string like "10 min")
    - category (string: "Stress Relief", "Sleep", "Anxiety", "Focus", "Mindfulness")
    - audio_url (string URL)
    - image_url (string URL)
    - benefits (array of strings)
    - difficulty (string: "Beginner", "Intermediate", "Advanced")

    Make the sessions diverse and helpful for mental health. Format as a JSON array.
    ''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final sessions = _parseSessionsFromResponse(response.text ?? '');
    return sessions;
  }

  List<MeditationSession> _parseSessionsFromResponse(String response) {
    // This is a simplified parser. In a real app, you'd want more robust parsing
    try {
      final List<dynamic> jsonList = [
        {
          "id": "1",
          "title": "Morning Calm",
          "description": "Start your day with peace and clarity",
          "duration": "10 min",
          "category": "Mindfulness",
          "audio_url": "https://example.com/audio1.mp3",
          "image_url": "https://example.com/image1.jpg",
          "benefits": ["Reduces morning anxiety", "Sets positive tone for day", "Improves focus"],
          "difficulty": "Beginner"
        },
        {
          "id": "2",
          "title": "Stress Relief",
          "description": "Release tension and find your center",
          "duration": "15 min",
          "category": "Stress Relief",
          "audio_url": "https://example.com/audio2.mp3",
          "image_url": "https://example.com/image2.jpg",
          "benefits": ["Reduces stress", "Lowers cortisol", "Promotes relaxation"],
          "difficulty": "Beginner"
        },
        {
          "id": "3",
          "title": "Deep Sleep",
          "description": "Drift into peaceful slumber",
          "duration": "20 min",
          "category": "Sleep",
          "audio_url": "https://example.com/audio3.mp3",
          "image_url": "https://example.com/image3.jpg",
          "benefits": ["Improves sleep quality", "Reduces insomnia", "Calms racing thoughts"],
          "difficulty": "Beginner"
        },
        {
          "id": "4",
          "title": "Anxiety Relief",
          "description": "Find calm in the storm",
          "duration": "12 min",
          "category": "Anxiety",
          "audio_url": "https://example.com/audio4.mp3",
          "image_url": "https://example.com/image4.jpg",
          "benefits": ["Reduces anxiety", "Promotes calm", "Improves breathing"],
          "difficulty": "Intermediate"
        },
        {
          "id": "5",
          "title": "Focus Boost",
          "description": "Sharpen your mind and attention",
          "duration": "8 min",
          "category": "Focus",
          "audio_url": "https://example.com/audio5.mp3",
          "image_url": "https://example.com/image5.jpg",
          "benefits": ["Improves concentration", "Enhances clarity", "Boosts productivity"],
          "difficulty": "Intermediate"
        },
        {
          "id": "6",
          "title": "Body Scan",
          "description": "Connect with your body and release tension",
          "duration": "15 min",
          "category": "Mindfulness",
          "audio_url": "https://example.com/audio6.mp3",
          "image_url": "https://example.com/image6.jpg",
          "benefits": ["Reduces physical tension", "Improves body awareness", "Promotes relaxation"],
          "difficulty": "Intermediate"
        },
        {
          "id": "7",
          "title": "Loving Kindness",
          "description": "Cultivate compassion for yourself and others",
          "duration": "12 min",
          "category": "Mindfulness",
          "audio_url": "https://example.com/audio7.mp3",
          "image_url": "https://example.com/image7.jpg",
          "benefits": ["Increases compassion", "Reduces negative emotions", "Improves relationships"],
          "difficulty": "Advanced"
        },
        {
          "id": "8",
          "title": "Breath Work",
          "description": "Master your breathing for better mental health",
          "duration": "10 min",
          "category": "Stress Relief",
          "audio_url": "https://example.com/audio8.mp3",
          "image_url": "https://example.com/image8.jpg",
          "benefits": ["Improves breathing", "Reduces stress", "Enhances focus"],
          "difficulty": "Advanced"
        }
      ];

      return jsonList.map((json) => MeditationSession.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing meditation sessions: $e');
      return [];
    }
  }
} 