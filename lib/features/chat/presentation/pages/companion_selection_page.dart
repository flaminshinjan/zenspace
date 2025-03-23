import 'package:flutter/material.dart';
import 'package:zenspace/features/chat/presentation/pages/chat_page.dart';
import 'package:zenspace/features/chat/presentation/pages/voice_chat_page.dart';
import 'package:zenspace/core/theme/app_colors.dart';

class CompanionSelectionPage extends StatefulWidget {
  final bool isVoiceMode;
  
  const CompanionSelectionPage({
    super.key,
    this.isVoiceMode = false,
  });

  @override
  State<CompanionSelectionPage> createState() => _CompanionSelectionPageState();
}

class _CompanionSelectionPageState extends State<CompanionSelectionPage> {
  String? _selectedName;
  String? _selectedVoiceType;
  String? _selectedImagePath;
  String? _selectedDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightYellow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.black, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(Icons.arrow_back, color: AppColors.textDark),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Text(
                'Choose Your\nCompanion',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your AI companion to chat with',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 32),

              // Companion grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildCompanionCard(
                      context,
                      name: 'Luna',
                      description: 'Your mindful friend',
                      imagePath: 'assets/images/meditating_dog.png',
                      voiceType: 'tts_female1',
                    ),
                    _buildCompanionCard(
                      context,
                      name: 'Max',
                      description: 'Your energetic buddy',
                      imagePath: 'assets/images/max.png',
                      voiceType: 'tts_male1',
                    ),
                    _buildCompanionCard(
                      context,
                      name: 'Bella',
                      description: 'Your gentle guide',
                      imagePath: 'assets/images/bella.png',
                      voiceType: 'tts_female2',
                    ),
                    _buildCompanionCard(
                      context,
                      name: 'Rocky',
                      description: 'Your loyal companion',
                      imagePath: 'assets/images/rocky.png',
                      voiceType: 'tts_male2',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedName == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => widget.isVoiceMode
                                  ? VoiceChatPage(
                                      name: _selectedName!,
                                      voiceType: _selectedVoiceType!,
                                      imagePath: _selectedImagePath!,
                                      description: _selectedDescription!,
                                    )
                                  : ChatPage(
                                      name: _selectedName!,
                                      voiceType: _selectedVoiceType!,
                                      imagePath: _selectedImagePath!,
                                      description: _selectedDescription!,
                                    ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.black,
                        width: 2,
                      ),
                    ),
                    disabledBackgroundColor: AppColors.textLight.withOpacity(0.3),
                  ),
                  child: Text(
                    widget.isVoiceMode ? 'start talking' : 'start chatting',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
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

  Widget _buildCompanionCard(
    BuildContext context, {
    required String name,
    required String description,
    required String imagePath,
    required String voiceType,
  }) {
    final isSelected = name == _selectedName;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedName = name;
          _selectedVoiceType = voiceType;
          _selectedImagePath = imagePath;
          _selectedDescription = description;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow : AppColors.lightYellow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.black,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 80,
              width: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 