import 'package:flutter/material.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/prompt_config.dart';

SocialPlatform aiPlatformToSocial(String platform) {
  switch (PromptConfig.normalizePlatform(platform)) {
    case 'Facebook':
      return SocialPlatform.facebook;
    case 'X':
      return SocialPlatform.twitter;
    case 'LinkedIn':
    default:
      return SocialPlatform.linkedin;
  }
}

class AiPlatformChipRow extends StatelessWidget {
  const AiPlatformChipRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = PromptConfig.normalizePlatform(selected);

    return SegmentedButton<String>(
      segments: PromptConfig.aiPlatforms.map((platform) {
        final social = aiPlatformToSocial(platform);
        return ButtonSegment<String>(
          value: platform,
          label: Text(platform, style: const TextStyle(fontSize: 11)),
          icon: Icon(social.icon, size: 16, color: social.color),
        );
      }).toList(),
      selected: {normalized},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) onSelected(selection.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return theme.colorScheme.primaryContainer;
          }
          return theme.colorScheme.surfaceContainerHighest;
        }),
      ),
    );
  }
}