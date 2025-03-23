import 'package:flutter/material.dart';
import 'package:zenspace/core/constants/asset_constants.dart';
import 'package:zenspace/features/chat/presentation/pages/chat_options_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5DE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            height: 700,
            decoration: BoxDecoration(
              color: const Color(0xFFBFD342),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 8),
                  spreadRadius: 0,
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "let's paws and\ntalk it off\none wag at a\ntime!",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 10,
                        child: Image.asset(
                          'assets/images/walking_dog_banner.png',
                          height: 340,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const ChatOptionsPage(),
                                transitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Image.asset(AssetConstants.pawButton, height: 48),
                        ),
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