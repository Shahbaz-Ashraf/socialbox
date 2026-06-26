import 'package:flutter/material.dart';

import '../../../../core/utils/platform_utils.dart';

class PlatformChipSelector extends StatelessWidget {
  const PlatformChipSelector({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final List<SocialPlatform> selected;
  final ValueChanged<SocialPlatform> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SocialPlatform.values.map((p) {
        final isSelected = selected.contains(p);
        return FilterChip(
          avatar: Icon(p.icon, size: 16, color: isSelected ? Colors.white : p.color),
          label: Text(p.displayName),
          selected: isSelected,
          onSelected: (_) => onToggle(p),
          selectedColor: p.color,
          backgroundColor: p.color.withValues(alpha: 0.08),
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : p.color,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(color: p.color.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }
}
