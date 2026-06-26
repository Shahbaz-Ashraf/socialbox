import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';

class RecurringOptionsSheet extends StatefulWidget {
  const RecurringOptionsSheet({
    super.key,
    required this.type,
    required this.days,
    required this.onChanged,
  });

  final RecurringType type;
  final List<int> days;
  final void Function(RecurringType type, List<int> days) onChanged;

  @override
  State<RecurringOptionsSheet> createState() => _RecurringOptionsSheetState();
}

class _RecurringOptionsSheetState extends State<RecurringOptionsSheet> {
  late RecurringType _type = widget.type;
  late final List<int> _days = List<int>.from(widget.days);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
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
          const Text('Repeat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: RecurringType.values.map((t) {
              final selected = t == _type;
              return ChoiceChip(
                label: Text(t.label),
                selected: selected,
                onSelected: (_) => setState(() => _type = t),
              );
            }).toList(),
          ),
          if (_type == RecurringType.custom) ...[
            const SizedBox(height: 16),
            const Text('On days',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: List.generate(7, (i) {
                final day = i + 1;
                final selected = _days.contains(day);
                return FilterChip(
                  label: Text(AppDateUtils.dayOfWeek(day)),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    if (selected) {
                      _days.remove(day);
                    } else {
                      _days.add(day);
                      _days.sort();
                    }
                  }),
                );
              }),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onChanged(_type, List<int>.from(_days));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
