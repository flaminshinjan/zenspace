import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:zenspace/features/chat/presentation/widgets/animated_blob.dart';

class VoiceChatPage extends StatefulWidget {
  final String name;
  final String voiceType;
  final String imagePath;
  final String description;

  const VoiceChatPage({
    super.key,
    required this.name,
    required this.voiceType,
    required this.imagePath,
    required this.description,
  });

  @override
  State<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage> {
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  final _speechToText = SpeechToText();
  final _flutterTts = FlutterTts();
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _recordingPath;
  String _statusText = 'tap the button\nto start talking';
  bool _isInitialized = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      await _speechToText.initialize();
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.9);
      setState(() => _isInitialized = true);
    } catch (e) {
      print('❌ Audio initialization error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initialize audio')),
      );
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    try {
      if (!_speechToText.isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
        return;
      }

      setState(() {
        _isRecording = true;
        _statusText = 'listening to\nyour voice...';
      });

      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
            _statusText = _lastWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );

      print('🎙️ Started listening...');
    } catch (e) {
      print('❌ Listening error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start listening')),
      );
    }
  }

  Future<void> _stopListeningAndProcess() async {
    if (!_isRecording) return;

    try {
      await _speechToText.stop();
      print('✅ Stopped listening');

      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _statusText = 'processing\nyour message...';
      });

      if (_lastWords.isNotEmpty) {
        try {
          // Send transcribed text to chat endpoint
          print('📤 Sending to chat endpoint...');
          final chatResponse = await http.post(
            Uri.parse('https://zenspace-production.up.railway.app/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_input': _lastWords}),
          );

          if (chatResponse.statusCode != 200) {
            print('❌ Chat Error: ${chatResponse.body}');
            throw Exception('Chat failed: ${chatResponse.statusCode}');
          }

          final responseData = jsonDecode(chatResponse.body);
          final botMessage = responseData['response'] as String;
          print('✅ Bot response: $botMessage');

          // Convert response to speech using selected voice type
          print('🔊 Converting to speech...');
          final ttsResponse = await http.post(
            Uri.parse('https://zenspace-production.up.railway.app/${widget.voiceType}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': botMessage}),
          );

          if (ttsResponse.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final file = File('${tempDir.path}/response.mp3');
            await file.writeAsBytes(ttsResponse.bodyBytes);
            await _audioPlayer.play(DeviceFileSource(file.path));
          }

          setState(() {
            _isProcessing = false;
            _statusText = botMessage;
          });
        } catch (e) {
          print('❌ Processing error: $e');
          setState(() {
            _isProcessing = false;
            _statusText = 'tap the button\nto start talking';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        setState(() {
          _isProcessing = false;
          _statusText = 'tap the button\nto start talking';
        });
      }
    } catch (e) {
      print('❌ Stop listening error: $e');
      setState(() {
        _isRecording = false;
        _isProcessing = false;
        _statusText = 'tap the button\nto start talking';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to stop listening')),
      );
    }
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio not initialized')),
      );
      return;
    }

    if (_isRecording) {
      await _stopListeningAndProcess();
    } else {
      await _startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAE6),
      body: SafeArea(
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.black,
                ),
              ),
            ),
            // Main content
            Column(
              children: [
                const SizedBox(height: 24),
                // Companion info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _isProcessing ? null : _toggleListening,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: _isRecording 
                                ? Colors.red 
                                : const Color(0xFFBFD342),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              size: 64,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
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
              ],
            ),
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AnimatedBlob(),
                      const SizedBox(height: 24),
                      Text(
                        _statusText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 