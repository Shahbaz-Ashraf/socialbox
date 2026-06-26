import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/constants/prompt_options.dart';

Future<void> showAiAppPickerSheet(
  BuildContext context, {
  required bool enabled,
  required Future<void> Function(String url) onCopyAndOpen,
}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(sheetCtx).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Open in AI',
              style: Theme.of(sheetCtx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Copies your prompt, then opens the app in your browser.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(sheetCtx).hintColor,
              ),
            ),
            const SizedBox(height: 16),
            ...kAiAppLinks.map(
              (app) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(sheetCtx)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Theme.of(sheetCtx).colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(app.name),
                subtitle: Text(
                  app.url.replaceFirst('https://', ''),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(sheetCtx).hintColor,
                  ),
                ),
                trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                enabled: enabled,
                onTap: enabled
                    ? () async {
                        Navigator.pop(sheetCtx);
                        await onCopyAndOpen(app.url);
                        HapticFeedback.mediumImpact();
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}