import 'package:flutter/material.dart';

import '../../../../app/theme/app_decorations.dart';
import '../../domain/entities/app_theme_mode.dart';

class ThemeModePicker extends StatelessWidget {
  const ThemeModePicker({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final AppThemeMode current;
  final ValueChanged<AppThemeMode> onChanged;

  static const _options = [
    (mode: AppThemeMode.system, icon: Icons.brightness_auto_rounded, label: 'Auto'),
    (mode: AppThemeMode.light, icon: Icons.light_mode_rounded, label: 'Light'),
    (mode: AppThemeMode.dark, icon: Icons.dark_mode_rounded, label: 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: AppDecorations.elevatedCard(context),
        child: Row(
          children: _options.map((opt) {
            final selected = opt.mode == current;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onChanged(opt.mode),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? LinearGradient(
                                colors: [
                                  primary.withValues(alpha: 0.85),
                                  theme.colorScheme.secondary
                                      .withValues(alpha: 0.75),
                                ],
                              )
                            : null,
                        color: selected
                            ? null
                            : theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            opt.icon,
                            size: 22,
                            color: selected
                                ? Colors.white
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            opt.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.65),
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
      ),
    );
  }
}