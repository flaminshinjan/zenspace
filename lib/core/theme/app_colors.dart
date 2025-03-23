import 'package:flutter/material.dart';

class AppColors {
  // Main colors
  static const Color primaryYellow = Color(0xFFFFC107);  // Main yellow for buttons and highlights
  static const Color lightYellow = Color(0xFFFFF3D0);    // Light yellow for cards
  static const Color bgColor = Color(0xFFFFFBF2);        // Very light yellow-white background
  
  // Text colors
  static const Color textDark = Color(0xFF2C2C2C);       // Dark text color
  static const Color textLight = Color(0xFF757575);      // Light text color
  
  // Additional colors
  static const Color error = Color(0xFFE53935);          // Error red
  static const Color success = Color(0xFF43A047);        // Success green
  static const Color black = Colors.black;               // Pure black for borders
  
  // Gradients
  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF8E1),  // Very light yellow
      Color(0xFFFFECB3),  // Light yellow
    ],
  );
} 