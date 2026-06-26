import 'package:flutter/material.dart';

import '../../../../app/theme/app_decorations.dart';
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

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: AppDecorations.listItemSurface(context),
      child: Row(
        children: PromptConfig.aiPlatforms.map((platform) {
          final social = aiPlatformToSocial(platform);
          final isSelected = platform == normalized;
          final color = social.color;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelected(platform),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.cardColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(social.icon, color: color, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          platform,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? theme.colorScheme.onSurface
                                : theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}