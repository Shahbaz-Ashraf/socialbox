import 'package:flutter/material.dart';

import '../../../../core/utils/extensions.dart';

class AddCategoryBottomSheet extends StatefulWidget {
  const AddCategoryBottomSheet({super.key, this.onSubmit});

  final Future<void> Function(String name, String icon, String colorHex)?
      onSubmit;

  @override
  State<AddCategoryBottomSheet> createState() => _AddCategoryBottomSheetState();
}

const _iconChoices = [
  '👋', '🎉', '💼', '📢', '🙏', '❓', '💪', '💬',
  '🌟', '🚀', '🔥', '❤️', '👏', '🤝', '💡', '✨',
  '🎯', '📈', '✅', '⚡', '🌱', '🎨', '🏆', '🔔',
];

const _colorChoices = [
  '#4CAF50', '#FF9800', '#2196F3', '#E91E63',
  '#9C27B0', '#00BCD4', '#FF5722', '#607D8B',
  '#3F51B5', '#009688', '#795548', '#F44336',
];

class _AddCategoryBottomSheetState extends State<AddCategoryBottomSheet> {
  final _nameCtrl = TextEditingController();
  String _selectedIcon = _iconChoices.first;
  String _selectedColor = _colorChoices.first;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('New Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Follow-up',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            const Text('Icon',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconChoices.map((emoji) {
                final selected = emoji == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = emoji),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? ColorFromHex.fromHex(_selectedColor)
                              .withValues(alpha: 0.18)
                          : Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: selected
                            ? ColorFromHex.fromHex(_selectedColor)
                            : Theme.of(context)
                                .hintColor
                                .withValues(alpha: 0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Color',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colorChoices.map((hex) {
                final selected = hex == _selectedColor;
                final color = ColorFromHex.fromHex(hex);
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                  color: color.withValues(alpha: 0.6),
                                  blurRadius: 8)
                            ]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('Create Category'),
                onPressed: () async {
                  final name = _nameCtrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a name')),
                    );
                    return;
                  }
                  await widget.onSubmit?.call(
                      name, _selectedIcon, _selectedColor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
