import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String voiceType;
  final String imagePath;
  final String description;

  const ChatPage({
    super.key,
    required this.name,
    required this.voiceType,
    required this.imagePath,
    required this.description,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final _audioPlayer = AudioPlayer();
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isLoading = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // Text Flow: Handle text message
  Future<void> _handleTextMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'type': 'text'
      });
      _isLoading = true;
    });

    try {
      // Step 1: Send message to chat endpoint
      final chatResponse = await http.post(
        Uri.parse('https://zenspace-production.up.railway.app/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_input': message}),
      );

      if (chatResponse.statusCode == 200) {
        final responseData = jsonDecode(chatResponse.body);
        final botMessage = responseData['response'] as String;
        
        setState(() {
          _messages.add({
            'text': botMessage,
            'isUser': false,
            'type': 'text'
          });
        });

        // Step 2: Convert response to speech
        await _convertTextToSpeech(botMessage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      _messageController.clear();
    }
  }

  // Voice Flow: Handle voice recording
  Future<void> _toggleRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission not granted')),
      );
      return;
    }

    if (_isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });

      if (path != null) {
        setState(() {
          _messages.add({
            'text': 'Recording sent...',
            'isUser': true,
            'type': 'voice'
          });
          _isLoading = true;
        });

        try {
          // Step 1: Convert voice to text using /talk endpoint
          final request = http.MultipartRequest(
            'POST',
            Uri.parse('https://zenspace-production.up.railway.app/talk'),
          );
          request.files.add(await http.MultipartFile.fromPath('audio', path));
          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode == 200) {
            final transcription = response.body;
            
            // Update the recording message with transcription
            setState(() {
              _messages.last['text'] = transcription;
            });

            // Step 2: Send transcribed text to chat endpoint
            final chatResponse = await http.post(
              Uri.parse('https://zenspace-production.up.railway.app/chat'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'user_input': transcription}),
            );

            if (chatResponse.statusCode == 200) {
              final responseData = jsonDecode(chatResponse.body);
              final botMessage = responseData['response'] as String;
              
              setState(() {
                _messages.add({
                  'text': botMessage,
                  'isUser': false,
                  'type': 'text'
                });
              });

              // Step 3: Convert response to speech
              await _convertTextToSpeech(botMessage);
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to process voice message')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // Start recording
      try {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/recording.wav';
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        setState(() {
          _isRecording = true;
          _recordingPath = path;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start recording')),
        );
      }
    }
  }

  // Helper: Convert text to speech and play
  Future<void> _convertTextToSpeech(String text) async {
    try {
      final ttsResponse = await http.post(
        Uri.parse('https://zenspace-production.up.railway.app/${widget.voiceType}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (ttsResponse.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/response.mp3');
        await file.writeAsBytes(ttsResponse.bodyBytes);
        await _audioPlayer.play(DeviceFileSource(file.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to play audio response')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5DE),
      body: SafeArea(
        child: Column(
          children: [
            // Chat header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFBFD342),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      widget.imagePath,
                      width: 30,
                      height: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 18,
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
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Chat messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['isUser'] as bool;
                  final isVoice = message['type'] == 'voice';

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFFBFD342)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isVoice && isUser)
                            const Icon(Icons.mic, size: 16, color: Colors.black54),
                          if (isVoice && isUser)
                            const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              message['text'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
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
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBFD342)),
                ),
              ),
            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.black12,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: _handleTextMessage,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleRecording,
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording ? Colors.red : Colors.black54,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _handleTextMessage(_messageController.text),
                    icon: const Icon(
                      Icons.send,
                      color: Color(0xFFBFD342),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 