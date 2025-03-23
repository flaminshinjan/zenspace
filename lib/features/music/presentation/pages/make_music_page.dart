import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:zenspace/features/chat/presentation/widgets/animated_blob.dart';
import 'package:zenspace/core/theme/app_colors.dart';

class MakeMusicPage extends StatefulWidget {
  const MakeMusicPage({super.key});

  @override
  State<MakeMusicPage> createState() => _MakeMusicPageState();
}

class _MakeMusicPageState extends State<MakeMusicPage> with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isGenerating = false;
  bool _isPlaying = false;
  String? _currentMusicPath;
  late AnimationController _animationController;
  String _statusText = 'describe the music\nyou want to create';

  final List<String> _samplePrompts = [
    'Calming piano melody',
    'Peaceful nature sounds',
    'Gentle meditation music',
    'Soft acoustic guitar',
    'Relaxing rain sounds',
    'Soothing wind chimes',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateMusic(String prompt) async {
    if (prompt.trim().isEmpty) return;

    setState(() {
      _isGenerating = true;
      _statusText = 'composing your\nmusical story...';
    });

    try {
      print('🎵 Generating music with prompt: $prompt');
      final response = await http.post(
        Uri.parse('https://zenspace-production.up.railway.app/generate-music'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'inputs': prompt}),
      );

      if (response.statusCode != 200) {
        print('❌ Generation failed: ${response.statusCode}');
        throw Exception('Failed to generate music');
      }

      print('✨ Music generated successfully');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/generated_music.wav');
      await file.writeAsBytes(response.bodyBytes);
      print('💾 Music saved to: ${file.path}');

      setState(() {
        _currentMusicPath = file.path;
        _isGenerating = false;
        _statusText = 'your music is ready\nto play';
      });

      // Auto-play the generated music
      await _playMusic();
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _isGenerating = false;
        _statusText = 'describe the music\nyou want to create';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _playMusic() async {
    if (_currentMusicPath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(_currentMusicPath!));
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      print('❌ Playback error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to play music')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
                  'Create Your\nMelody',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Describe the music you want to hear',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 24),

                // Text input field
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightYellow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.black, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _promptController,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. A calming piano melody with gentle rain in the background...',
                          hintStyle: TextStyle(
                            color: AppColors.textLight,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isGenerating ? null : () => _generateMusic(_promptController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: AppColors.textDark,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: AppColors.black),
                            ),
                          ),
                          child: _isGenerating
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(),
                                )
                              : const Text(
                                  'Generate Music',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sample prompts
                Text(
                  'Try these prompts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _samplePrompts.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _promptController.text = _samplePrompts[index];
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightYellow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.black),
                        ),
                        child: Center(
                          child: Text(
                            _samplePrompts[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Music player area (placeholder)
                if (!_isGenerating)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.lightYellow,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.black, width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.black),
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 48,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0:00',
                              style: TextStyle(
                                color: AppColors.textLight,
                              ),
                            ),
                            Text(
                              '3:30',
                              style: TextStyle(
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 