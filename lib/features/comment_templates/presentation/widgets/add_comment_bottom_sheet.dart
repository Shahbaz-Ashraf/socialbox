import 'package:flutter/material.dart';

class AddCommentBottomSheet extends StatefulWidget {
  const AddCommentBottomSheet({
    super.key,
    this.initialText,
    this.initialTags = const [],
    this.onSubmit,
  });

  final String? initialText;
  final List<String> initialTags;
  final Future<void> Function(String text, List<String> tags)? onSubmit;

  @override
  State<AddCommentBottomSheet> createState() => _AddCommentBottomSheetState();
}

class _AddCommentBottomSheetState extends State<AddCommentBottomSheet> {
  late final TextEditingController _textCtrl =
      TextEditingController(text: widget.initialText);
  late final List<String> _tags = List<String>.from(widget.initialTags);
  final _tagCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _tagCtrl.dispose();
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
            Text(
              widget.initialText == null ? 'New Comment' : 'Edit Comment',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textCtrl,
              autofocus: true,
              maxLines: 5,
              minLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comment',
                hintText: 'Type or paste your reusable comment here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ..._tags.map((t) => InputChip(
                      label: Text('#$t'),
                      onDeleted: () => setState(() => _tags.remove(t)),
                    )),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _tagCtrl,
                    decoration: const InputDecoration(
                      hintText: 'add tag',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save'),
                onPressed: () async {
                  final text = _textCtrl.text.trim();
                  if (text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter text')),
                    );
                    return;
                  }
                  await widget.onSubmit?.call(text, _tags);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTag() {
    final t = _tagCtrl.text.trim().replaceAll('#', '');
    if (t.isEmpty) return;
    if (!_tags.contains(t)) setState(() => _tags.add(t));
    _tagCtrl.clear();
  }
}
