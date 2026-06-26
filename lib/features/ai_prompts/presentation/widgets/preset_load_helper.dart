import 'package:flutter/material.dart';

import '../../domain/entities/prompt_config.dart';

/// Returns true when the preset should be loaded (user confirmed or no diff).
Future<bool> confirmPresetLoadIfNeeded(
  BuildContext context, {
  required PromptConfig currentConfig,
  required PromptPreset preset,
}) async {
  if (currentConfig == preset.config) return true;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Load preset?'),
      content: Text(
        'Loading "${preset.name}" will replace your current prompt settings '
        'including topic, keywords, platform, audience, and style options.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Load'),
        ),
      ],
    ),
  );
  return confirmed == true;
}