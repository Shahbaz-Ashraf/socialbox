import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';

class ScheduleDatePicker extends StatelessWidget {
  const ScheduleDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.event_rounded),
            label: Text(value == null
                ? 'Pick date & time'
                : AppDateUtils.formatDateTime(value!)),
            onPressed: () async {
              final now = DateTime.now();
              final date = await showDatePicker(
                context: context,
                firstDate: now,
                lastDate: now.add(const Duration(days: 365 * 2)),
                initialDate: value ?? now.add(const Duration(hours: 1)),
              );
              if (date == null) return;
              if (!context.mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(
                    value ?? now.add(const Duration(hours: 1))),
              );
              if (time == null) return;
              onChanged(DateTime(
                  date.year, date.month, date.day, time.hour, time.minute));
            },
          ),
        ),
        if (value != null) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.clear_rounded),
            onPressed: () => onChanged(null),
          ),
        ],
      ],
    );
  }
}
