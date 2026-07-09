import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppSnackBars {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, const Color(0xFF06CE70), Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Colors.redAccent, Icons.error_outline);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppColors.azure, Icons.info_outline);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, Colors.orangeAccent, Icons.warning_amber_outlined);
  }

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    
    final width = MediaQuery.of(context).size.width;
    final snackBarWidth = width > 600 ? 400.0 : width * 0.9;

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
        width: snackBarWidth,
      ),
    );
  }
}
