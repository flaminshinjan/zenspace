import 'package:flutter/material.dart';

class MakeMusicPage extends StatelessWidget {
  const MakeMusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('Make Music Page'),
        ),
      ),
    );
  }
} 