import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/reminder.dart';

class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final Reminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final past = reminder.scheduledAt.isBefore(DateTime.now());
    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: reminder.repeat.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(reminder.repeat.icon,
                color: reminder.repeat.color, size: 20),
          ),
          title: Text(
            reminder.title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              decoration: past ? TextDecoration.lineThrough : null,
              color: past ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppDateUtils.formatDateTime(reminder.scheduledAt)),
              Row(
                children: [
                  Icon(reminder.repeat.icon,
                      size: 12, color: reminder.repeat.color),
                  const SizedBox(width: 4),
                  Text(
                    reminder.repeat.label,
                    style: TextStyle(
                        fontSize: 11,
                        color: reminder.repeat.color,
                        fontWeight: FontWeight.w600),
                  ),
                  if (reminder.repeat == ReminderRepeat.custom &&
                      reminder.repeatDays.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      AppDateUtils.repeatDaysSummary(reminder.repeatDays),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                  if (reminder.postId != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Post',
                          style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Switch(
            value: reminder.isEnabled,
            onChanged: onToggle,
          ),
        ),
      ),
    );
  }
}
