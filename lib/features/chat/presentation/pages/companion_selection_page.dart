import 'package:flutter/material.dart';
import 'package:zenspace/features/chat/presentation/pages/chat_page.dart';
import 'package:zenspace/features/chat/presentation/pages/voice_chat_page.dart';

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
      backgroundColor: const Color(0xFFFFFAE6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose your companion',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildCompanionCard(
                      context,
                      name: 'po',
                      description: 'your friend in need',
                      imagePath: 'assets/images/happy_dog.png',
                      voiceType: 'tts_female1',
                    ),
                    _buildCompanionCard(
                      context,
                      name: 'max',
                      description: 'your friend in need',
                      imagePath: 'assets/images/running_dog.png',
                      voiceType: 'tts_male1',
                    ),
                    _buildCompanionCard(
                      context,
                      name: 'luna',
                      description: 'your friend in need',
                      imagePath: 'assets/images/meditating_dog.png',
                      voiceType: 'tts_female2',
                    ),
                    _buildCompanionCard(
                      context,
                      name: 'bella',
                      description: 'your friend in need',
                      imagePath: 'assets/images/journal_dog.png',
                      voiceType: 'tts_female3',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                    backgroundColor: const Color(0xFFBFD342),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: Text(
                    widget.isVoiceMode ? 'start talking' : 'start chatting',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
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
          color: isSelected ? const Color(0xFF9FB83A) : const Color(0xFFBFD342),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.black, width: 2)
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 