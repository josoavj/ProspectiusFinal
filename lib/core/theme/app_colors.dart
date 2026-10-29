import 'package:flutter/material.dart';

class AppColors {
  // Deep Professional Blue (Royal Blue) - used in loading/splash screens
  static const Color azure = Color(0xFF1565C0);
  static const Color azureDark = Color(0xFF0D47A1);
  static const Color azureAccent = Color(0xFF42A5F5);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [azure, azureDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Traditional Blue for Dark Mode or Fallback
  static const Color blue = Colors.blue;
  
  // Method to get the right blue based on theme
  static Color getPrimaryBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? azure : blue;
  }
}
