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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = isSmallScreen ? 16.0 : 24.0;
            final spacing = isSmallScreen ? 16.0 : 24.0;
            final gridSpacing = isSmallScreen ? 12.0 : 20.0;
            final imageSize = isSmallScreen ? 60.0 : 80.0;
            final titleSize = isSmallScreen ? 32.0 : 40.0;
            final subtitleSize = isSmallScreen ? 14.0 : 16.0;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      ),
                    ),
                    SizedBox(height: spacing),

                    // Header
                    Text(
                      'Choose Your\nCompanion',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: spacing / 2),
                    Text(
                      'Select your AI companion to chat with',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: spacing * 1.5),

                    // Companion grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isLargeScreen ? 4 : (isSmallScreen ? 2 : 3),
                      mainAxisSpacing: gridSpacing,
                      crossAxisSpacing: gridSpacing,
                      childAspectRatio: isSmallScreen ? 0.85 : 0.9,
                      children: [
                        _buildCompanionCard(
                          context,
                          name: 'Luna',
                          description: 'Your mindful friend',
                          imagePath: 'assets/images/luna.png',
                          voiceType: 'tts_female1',
                          imageSize: isSmallScreen ? 80 : 90,
                        ),
                        _buildCompanionCard(
                          context,
                          name: 'Max',
                          description: 'Your energetic buddy',
                          imagePath: 'assets/images/max.png',
                          voiceType: 'tts_male1',
                          imageSize: isSmallScreen ? 80 : 90,
                        ),
                        _buildCompanionCard(
                          context,
                          name: 'Bella',
                          description: 'Your gentle guide',
                          imagePath: 'assets/images/bella.png',
                          voiceType: 'tts_female2',
                          imageSize: isSmallScreen ? 80 : 90,
                        ),
                        _buildCompanionCard(
                          context,
                          name: 'Rocky',
                          description: 'Your loyal companion',
                          imagePath: 'assets/images/rocky.png',
                          voiceType: 'tts_male2',
                          imageSize: isSmallScreen ? 80 : 90,
                        ),
                      ],
                    ),
                    SizedBox(height: spacing * 1.5),

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
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppColors.cardBorder,
                              width: 2,
                            ),
                          ),
                          disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        child: Text(
                          widget.isVoiceMode ? 'start talking' : 'start chatting',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
    required double imageSize,
  }) {
    final isSelected = name == _selectedName;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

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
          color: isSelected ? AppColors.primaryColor : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cardBorder,
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
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: imageSize,
              width: imageSize,
              fit: BoxFit.contain,
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              name,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 