import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClipboardService {
  Future<void> copyText(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    await HapticFeedback.lightImpact();
    if (context.mounted) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded,
                  color: Color(0xFF4CAF50), size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Copied to clipboard')),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
