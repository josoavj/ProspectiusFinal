import 'package:flutter/material.dart';

class AppColors {
  // Deep Professional Blue (Royal Blue) - used in loading/splash screens
  static const Color azure = Color(0xFF1565C0);
  
  // Traditional Blue for Dark Mode or Fallback
  static const Color blue = Colors.blue;
  
  // Method to get the right blue based on theme
  static Color getPrimaryBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? azure : blue;
  }
}
