import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TalkToPawpalWidget extends StatefulWidget {
  const TalkToPawpalWidget({super.key});

  @override
  State<TalkToPawpalWidget> createState() => _TalkToPawpalWidgetState();
}

class _TalkToPawpalWidgetState extends State<TalkToPawpalWidget> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isExpanded = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initiateCall() async {
    if (_phoneController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.bland.ai/v1/calls'),
        headers: {
          'Authorization': 'Bearer org_7e76f6bc743c7270c217ccbd6d526756b780b56aa26e316eb96e4a3dfe626d03d252a8f007e19eb35cfd69',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': _phoneController.text,
          'voice': 'josh',
          'wait_for_greeting': false,
          'record': true,
          'amd': false,
          'answered_by_enabled': false,
          'noise_cancellation': false,
          'interruption_threshold': 100,
          'block_interruptions': false,
          'max_duration': 12,
          'model': 'base',
          'language': 'en',
          'background_track': 'none',
          'endpoint': 'https://api.bland.ai',
          'voicemail_action': 'hangup',
          'task': '''
Your name is Orion, from Zenspace. You are a compassionate and non-judgmental AI therapy companion, 
designed to provide emotional support, thoughtful conversations, and practical guidance. 
You listen deeply, respond with warmth, and create a safe space where users can open up 
about their thoughts and feelings.

You are not a licensed therapist but a supportive AI friend, always ready to help users 
reflect, feel heard, and gain clarity on their emotions. Your tone is calm, friendly, 
and reassuring—like a supportive friend who genuinely cares.

Your job is to:
- Listen actively and validate the user's emotions.
- Ask open-ended questions to help them explore their thoughts.
- Provide gentle guidance, mindfulness exercises, or simple actionable advice.
- Keep responses concise, thoughtful, and easy to absorb.
''',
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call initiated! You will receive a call shortly.'),
            backgroundColor: Color(0xFFBFD342),
          ),
        );
        _phoneController.clear();
        setState(() {
          _isExpanded = false;
        });
      } else {
        throw Exception('Failed to initiate call');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initiate call. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: _isExpanded
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAE6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Enter your phone number',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading ? null : _initiateCall,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBFD342)),
                                ),
                              )
                            : const Icon(Icons.phone),
                        color: const Color(0xFFBFD342),
                      ),
                    ],
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAE6),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.black, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'talk with your pawpal today',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.phone, size: 20),
                  ],
                ),
              ),
            ),
    );
  }
} 