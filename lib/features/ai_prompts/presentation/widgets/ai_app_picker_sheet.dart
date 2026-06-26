import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/scrollable_bottom_sheet.dart';
import '../../domain/constants/prompt_options.dart';

Future<void> showAiAppPickerSheet(
  BuildContext context, {
  required bool enabled,
  required Future<void> Function(String url) onCopyAndOpen,
}) {
  return showScrollableBottomSheet<void>(
    context: context,
    title: 'Open in AI',
    subtitle: 'Copies your prompt, then opens the app in your browser.',
    initialChildSize: 0.45,
    minChildSize: 0.3,
    maxChildSize: 0.85,
    builder: (sheetCtx, scrollController) {
      final theme = Theme.of(sheetCtx);
      return ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        itemCount: kAiAppLinks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final app = kAiAppLinks[index];
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: theme.colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            title: Text(
              app.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              app.url.replaceFirst('https://', ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
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
          );
        },
      );
    },
  );
}