# ZenSpace 🧘‍♂️

> A comprehensive mental health and wellness mobile application built with Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red)]()

## 🌟 Overview

ZenSpace is a mental health and wellness platform that combines AI-powered journaling, guided meditation, AI chat companions, and therapist discovery to help users on their mental health journey.

### Key Features

- 📝 **AI-Powered Journaling** - Multiple journaling modes with AI guidance and mood tracking
- 💬 **AI Chat Companions** - Voice and text chat with empathetic AI companions
- 🧘 **Guided Meditation** - Curated meditation sessions for stress, anxiety, sleep, and focus
- 👨‍⚕️ **Therapist Discovery** - Find and book appointments with licensed therapists
- 📊 **Wellness Analytics** - Track your mental health journey with detailed insights
- 🎵 **Music Generation** - Create personalized ambient music (Coming Soon)

## 📚 Documentation

### 📖 Complete Documentation Guide

We have created comprehensive documentation to help you understand the entire application:

1. **[APP_FLOW_README.md](./APP_FLOW_README.md)** - Complete Application Flow Guide
   - Detailed user journey through every feature
   - UI/UX flow with visual representations
   - Current architecture overview
   - Development roadmap
   - Perfect for: Understanding the app from a user perspective

2. **[BACKEND_ARCHITECTURE.md](./BACKEND_ARCHITECTURE.md)** - Backend Architecture & API Specification
   - Complete REST API documentation (80+ endpoints)
   - Detailed request/response examples for every API
   - Database schema design
   - Authentication & security implementation
   - Scalability and deployment strategy
   - Migration path from current to production architecture
   - Perfect for: Backend development and API integration

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.3.0+)
- Dart SDK (3.0+)
- iOS/Android development environment
- Supabase account
- Google Gemini API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/zenspace.git
   cd zenspace
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GEMINI_API_KEY=your_gemini_api_key
   ```

4. **Run the app**
   ```bash
   # Development
   flutter run --flavor dev
   
   # Testing
   flutter run --flavor testing
   
   # Production
   flutter run --flavor prod
   ```

## 🏗️ Project Structure

```
zenspace/
├── lib/
│   ├── core/
│   │   ├── config/         # App configuration and flavors
│   │   ├── constants/      # Constants (assets, colors, strings)
│   │   ├── routes/         # Navigation routing
│   │   └── theme/          # App theme and styling
│   ├── features/
│   │   ├── auth/           # Authentication (login, register, OAuth)
│   │   ├── chat/           # AI Chat companions
│   │   ├── dashboard/      # Main dashboard/home
│   │   ├── journal/        # Journaling feature
│   │   ├── meditation/     # Guided meditation
│   │   ├── profile/        # User profile
│   │   └── therapists/     # Therapist discovery
│   └── main.dart           # App entry point
├── assets/
│   ├── images/             # App images and illustrations
│   ├── icons/              # App icons
│   └── audio/              # Audio files (if any)
├── test/                   # Unit and widget tests
└── docs/                   # Additional documentation
```

## 🎯 Features Deep Dive

### 📝 AI-Powered Journaling

- **Five Whys**: Deep introspection technique
- **AI Suggestions**: Context-aware prompts
- **Mood Tracking**: Track emotional patterns
- **Empty Canvas**: Free-form journaling
- **Custom Prompts**: Create your own prompts
- **Calendar View**: Visual mood tracking
- **Analytics**: Mood trends and insights

### 💬 AI Chat Companions

- **Voice Chat**: Real-time speech recognition and AI voice responses
- **Text Chat**: Traditional messaging interface
- **Multiple Companions**: Po (empathetic), Max (motivating), Bella (calming), Rocky (energetic)
- **Context-Aware**: Remembers conversation history
- **Empathetic**: Tailored for mental health support

### 🧘 Guided Meditation

- **Categories**: Stress Relief, Sleep, Anxiety, Focus, Mindfulness
- **Difficulty Levels**: Beginner, Intermediate, Advanced
- **Session Tracking**: Monitor meditation habits
- **Streak Tracking**: Build consistent practice
- **Audio Player**: Beautiful meditation player interface

### 👨‍⚕️ Therapist Discovery

- **Location-Based Search**: Find therapists near you
- **Advanced Filters**: Specialty, availability, session type
- **Detailed Profiles**: Credentials, reviews, specialties
- **Appointment Booking**: (Coming Soon)
- **Insurance Verification**: (Coming Soon)

### 📊 Profile & Analytics

- **Streak Tracking**: Daily, weekly, and mood streaks
- **Statistics**: Journal entries, meditation minutes
- **Subscription Management**: Manage your plan
- **Personalization**: Customize app experience
- **Reminders**: Set journaling reminders

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.3.0+
- **State Management**: Flutter Bloc
- **UI Components**: Custom Material Design
- **Fonts**: Google Fonts
- **Audio**: audioplayers, record
- **Voice**: speech_to_text, flutter_tts

### Backend (Current)
- **Backend as a Service**: Supabase
- **Database**: PostgreSQL
- **Authentication**: Supabase Auth (Email, Google, Apple OAuth)
- **Storage**: Supabase Storage

### AI Services
- **LLM**: Google Gemini AI
- **Chat & TTS**: Railway-hosted APIs

### Future Backend (See BACKEND_ARCHITECTURE.md)
- **API**: Node.js/Python REST API
- **Database**: PostgreSQL + Redis
- **Infrastructure**: Docker + Kubernetes
- **Cloud**: AWS/GCP/Azure

## 🔐 Security & Privacy

- 🔒 End-to-end encryption for journal entries
- 🏥 HIPAA-compliant architecture (planned)
- 🔑 Secure authentication with JWT
- 🛡️ Row-level security in database
- 🚫 No third-party data sharing
- 📋 GDPR compliant

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📱 Platform Support

- ✅ iOS (12.0+)
- ✅ Android (21+)
- ⏳ Web (Coming Soon)
- ⏳ macOS (Coming Soon)

## 🚀 Deployment

### iOS
```bash
flutter build ios --release --flavor prod
```

### Android
```bash
flutter build apk --release --flavor prod
flutter build appbundle --release --flavor prod
```

## 📊 Current Status

### Completed Features ✅
- User authentication (Email, Google, Apple)
- AI chat with voice and text
- Journal with multiple modes
- Meditation sessions
- Therapist discovery UI
- Profile and analytics
- Dashboard with quick actions

### In Progress 🔄
- Backend API development
- Offline support
- Push notifications
- Advanced analytics

### Planned Features 🔮
- Therapist appointment booking
- Payment integration
- Music generation
- Group therapy
- Community features
- Multi-language support

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features

## 📄 License

This project is proprietary software. All rights reserved.

## 👥 Team

- **Development Team**: ZenSpace Dev Team
- **Design**: ZenSpace Design Team
- **Product**: ZenSpace Product Team

## 📞 Support & Contact

- **Email**: support@zenspace.app
- **Website**: https://zenspace.app
- **Documentation**: See [APP_FLOW_README.md](./APP_FLOW_README.md) and [BACKEND_ARCHITECTURE.md](./BACKEND_ARCHITECTURE.md)
- **Issues**: GitHub Issues

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for backend infrastructure
- Google for Gemini AI
- All our beta testers and early users

## 📈 Roadmap

See [APP_FLOW_README.md](./APP_FLOW_README.md) for detailed development roadmap.

## 🔗 Important Links

- 📱 [Download iOS App](https://apps.apple.com/zenspace) (Coming Soon)
- 🤖 [Download Android App](https://play.google.com/store/zenspace) (Coming Soon)
- 📖 [Complete App Flow Guide](./APP_FLOW_README.md)
- 🏗️ [Backend Architecture & APIs](./BACKEND_ARCHITECTURE.md)
- 🌐 [Website](https://zenspace.app) (Coming Soon)

---

**Made with ❤️ by the ZenSpace Team**

*Helping people find peace, one day at a time.*

---

## ⚡ Quick Links to Documentation

| Document | Purpose | Best For |
|----------|---------|----------|
| [APP_FLOW_README.md](./APP_FLOW_README.md) | Complete user journey and app flow | Product managers, designers, frontend developers |
| [BACKEND_ARCHITECTURE.md](./BACKEND_ARCHITECTURE.md) | API specs and backend architecture | Backend developers, DevOps, API integration |
| README.md (this file) | Quick start and overview | Everyone new to the project |
