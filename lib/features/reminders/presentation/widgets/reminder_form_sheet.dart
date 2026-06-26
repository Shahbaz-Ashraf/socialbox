import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/reminder.dart';

class ReminderFormSheet extends StatefulWidget {
  const ReminderFormSheet({
    super.key,
    this.initial,
    this.prefillTitle,
    this.prefillTime,
    this.linkedPostId,
    this.onSubmit,
  });

  final Reminder? initial;
  final String? prefillTitle;
  final DateTime? prefillTime;
  final String? linkedPostId;
  final Future<bool> Function(CreateReminderParams params)? onSubmit;

  @override
  State<ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<ReminderFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late DateTime _scheduledAt;
  late ReminderRepeat _repeat;
  late List<int> _days;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _titleCtrl = TextEditingController(
        text: r?.title ?? widget.prefillTitle ?? 'Reminder');
    _bodyCtrl = TextEditingController(text: r?.body ?? '');
    _scheduledAt = r?.scheduledAt ??
        widget.prefillTime ??
        DateTime.now().add(const Duration(hours: 1));
    _repeat = r?.repeat ?? ReminderRepeat.none;
    _days = List<int>.from(r?.repeatDays ?? const []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
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
            Text(widget.initial == null ? 'New Reminder' : 'Edit Reminder',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Body (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.event_rounded),
                    label: Text(AppDateUtils.formatDateTime(_scheduledAt)),
                    onPressed: () async {
                      final now = DateTime.now();
                      final d = await showDatePicker(
                        context: context,
                        firstDate: now.subtract(const Duration(days: 1)),
                        lastDate: now.add(const Duration(days: 365 * 2)),
                        initialDate: _scheduledAt,
                      );
                      if (d == null || !mounted) return;
                      if (!context.mounted) return;
                      final t = await showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(_scheduledAt),
                      );
                      if (t == null) return;
                      setState(() {
                        _scheduledAt = DateTime(
                            d.year, d.month, d.day, t.hour, t.minute);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Repeat',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: ReminderRepeat.values
                  .map((r) => ChoiceChip(
                        label: Text(r.label),
                        selected: _repeat == r,
                        onSelected: (_) => setState(() => _repeat = r),
                      ))
                  .toList(),
            ),
            if (_repeat == ReminderRepeat.custom) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: List.generate(7, (i) {
                  final day = i + 1;
                  return FilterChip(
                    label: Text(AppDateUtils.dayOfWeek(day)),
                    selected: _days.contains(day),
                    onSelected: (sel) => setState(() {
                      if (sel) {
                        if (!_days.contains(day)) {
                          _days = [..._days, day]..sort();
                        }
                      } else {
                        _days = _days.where((d) => d != day).toList();
                      }
                    }),
                  );
                }),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.notifications_active_rounded),
                label: const Text('Save Reminder'),
                onPressed: () async {
                  final params = CreateReminderParams(
                    title: _titleCtrl.text.trim().isEmpty
                        ? 'Reminder'
                        : _titleCtrl.text.trim(),
                    body: _bodyCtrl.text.trim().isEmpty
                        ? null
                        : _bodyCtrl.text.trim(),
                    postId: widget.initial?.postId ?? widget.linkedPostId,
                    scheduledAt: _scheduledAt,
                    repeat: _repeat,
                    repeatDays: _days,
                  );
                  final ok = await widget.onSubmit?.call(params) ?? true;
                  if (!mounted) return;
                  if (ok && context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
