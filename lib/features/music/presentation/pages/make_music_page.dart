import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:zenspace/features/chat/presentation/widgets/animated_blob.dart';

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
    'A soft piano melody with a relaxing atmosphere',
    'Upbeat electronic dance music with synth waves',
    'Calming nature sounds with gentle guitar',
    'Meditation music with crystal bowls',
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
      backgroundColor: const Color(0xFFFFFAE6),
      body: SafeArea(
        child: Stack(
          children: [
            // Background design elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFBFD342).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFBFD342).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Main content
            SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  
                  // Main area with blob/player
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isGenerating)
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const AnimatedBlob(
                                  size: 250,
                                  color: Color(0xFFBFD342),
                                ),
                                LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.black,
                                  size: 40,
                                ),
                              ],
                            )
                          else if (_currentMusicPath != null)
                            GestureDetector(
                              onTap: _playMusic,
                              child: Container(
                                width: 250,
                                height: 250,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFBFD342),
                                      Color(0xFF9FB83A),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(125),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(0, 8),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 80,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          else
                            const AnimatedBlob(
                              size: 250,
                              color: Color(0xFFBFD342),
                            ),
                          const SizedBox(height: 40),
                          Text(
                            _statusText,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Playback controls when music is generated
                  if (_currentMusicPath != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _currentMusicPath = null;
                                _statusText = 'describe the music\nyou want to create';
                              });
                              _audioPlayer.stop();
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Create New'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Colors.black12),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _playMusic,
                            icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                            label: Text(_isPlaying ? 'Pause' : 'Play'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBFD342),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  // Custom prompt input
                  if (!_isGenerating && _currentMusicPath == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promptController,
                                decoration: const InputDecoration(
                                  hintText: 'Describe your music...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: _generateMusic,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBFD342),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () => _generateMusic(_promptController.text),
                                icon: const Icon(Icons.music_note_rounded),
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Sample prompts
                  if (!_isGenerating && _currentMusicPath == null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 12),
                            child: Text(
                              'Try these prompts:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 3,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _samplePrompts.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  _promptController.text = _samplePrompts[index];
                                  _generateMusic(_samplePrompts[index]);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _samplePrompts[index],
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 100)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 