import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SnackKind { info, success, error }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    SnackKind kind = SnackKind.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    Color iconColor;
    IconData icon;
    switch (kind) {
      case SnackKind.success:
        iconColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle_rounded;
        break;
      case SnackKind.error:
        iconColor = const Color(0xFFF44336);
        icon = Icons.error_rounded;
        break;
      case SnackKind.info:
        iconColor = const Color(0xFF2196F3);
        icon = Icons.info_rounded;
        break;
    }
    HapticFeedback.lightImpact();
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        duration: Duration(seconds: kind == SnackKind.error ? 4 : 2),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: iconColor,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, kind: SnackKind.success);

  static void error(BuildContext context, String message) =>
      show(context, message, kind: SnackKind.error);

  static void info(BuildContext context, String message) =>
      show(context, message, kind: SnackKind.info);
}
