import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:zenspace/features/chat/presentation/widgets/animated_blob.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String voiceType;
  final String imagePath;
  final String description;
  final bool isTextOnly;

  const ChatPage({
    super.key,
    required this.name,
    required this.voiceType,
    required this.imagePath,
    required this.description,
    this.isTextOnly = false,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final _audioPlayer = AudioPlayer();
  final _audioRecorder = AudioRecorder();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  bool _isLoading = false;
  String? _recordingPath;
  bool get _isTextOnly => widget.isTextOnly;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
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
    
    _scrollToBottom();
    _messageController.clear();

    try {
      // Send message to chat endpoint
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
          _isLoading = false;
        });
        
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
      setState(() {
        _isLoading = false;
      });
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
        
        _scrollToBottom();

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
            
            _scrollToBottom();

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
                _isLoading = false;
              });
              
              _scrollToBottom();

              // Convert response to speech
              await _convertTextToSpeech(botMessage);
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to process voice message')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      try {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/recording.wav';
        
        await _audioRecorder.startStream(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            sampleRate: 44100,
          ),
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.waveDots(
                  color: const Color(0xFFBFD342),
                  size: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5DE),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Chat header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFBFD342),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: const EdgeInsets.all(4),
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
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chat messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return _buildTypingIndicator();
                        }

                        final message = _messages[index];
                        final isUser = message['isUser'] as bool;
                        final isVoice = message['type'] == 'voice';

                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isUser ? const Color(0xFFBFD342) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black, width: 1),
                              ),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isVoice && isUser) ...[
                                    const Icon(Icons.mic, size: 16, color: Colors.black54),
                                    const SizedBox(width: 8),
                                  ],
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
                          ),
                        );
                      },
                    ),
                  ),
                  // Input area
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.black12, width: 1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Type your message...',
                                hintStyle: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 16,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              minLines: 1,
                              maxLines: 5,
                              onSubmitted: _handleTextMessage,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (!_isTextOnly)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: IconButton(
                              onPressed: _toggleRecording,
                              icon: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: _isRecording ? Colors.red : Colors.black54,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFBFD342),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: IconButton(
                            onPressed: () => _handleTextMessage(_messageController.text),
                            icon: const Icon(
                              Icons.send,
                              color: Colors.black87,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isRecording || _isLoading)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AnimatedBlob(),
                      const SizedBox(height: 24),
                      Text(
                        _isRecording ? 'Listening...' : 'Thinking...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 