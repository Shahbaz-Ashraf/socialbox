import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../domain/entities/ai_post_prefill.dart';
import '../../domain/services/ai_response_parser.dart';

Future<void> showPasteAiResponseSheet(
  BuildContext context, {
  String? topic,
  String platform = 'LinkedIn',
  void Function(AiPostPrefill prefill)? onApply,
  Future<void> Function(BuildContext context, String text)? onCopyExtracted,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PasteAiResponseSheet(
      topic: topic,
      platform: platform,
      onApply: onApply,
      onCopyExtracted: onCopyExtracted,
    ),
  );
}

class _PasteAiResponseSheet extends StatefulWidget {
  const _PasteAiResponseSheet({
    this.topic,
    required this.platform,
    this.onApply,
    this.onCopyExtracted,
  });

  final String? topic;
  final String platform;
  final void Function(AiPostPrefill prefill)? onApply;
  final Future<void> Function(BuildContext context, String text)? onCopyExtracted;

  @override
  State<_PasteAiResponseSheet> createState() => _PasteAiResponseSheetState();
}

class _PasteAiResponseSheetState extends State<_PasteAiResponseSheet> {
  late final TextEditingController _ctrl;
  final _parser = const AiResponseParser();
  ParsedAiResponse? _parsed;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _loadClipboard();
  }

  Future<void> _loadClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      _ctrl.text = data.text!;
      _parse(data.text!);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _parse(String raw) {
    setState(() {
      _parsed = _parser.parse(raw, fallbackTitle: widget.topic);
    });
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parsed;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.paste_rounded),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Paste AI Response',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Paste from clipboard',
                    icon: const Icon(Icons.content_paste_go_rounded),
                    onPressed: () async {
                      final data =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        _ctrl.text = data!.text!;
                        _parse(data.text!);
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Paste the full AI reply here. The post text inside the ```text block (or "The Post" section) will be extracted automatically.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  TextField(
                    controller: _ctrl,
                    maxLines: 8,
                    minLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'AI response',
                      hintText: 'Paste ChatGPT / Gemini output here...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _parse,
                  ),
                  if (parsed != null && parsed.hasContent) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Extracted post',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        if (widget.onCopyExtracted != null)
                          IconButton(
                            tooltip: 'Copy extracted content',
                            icon: const Icon(Icons.copy_rounded),
                            onPressed: () => widget.onCopyExtracted!(
                              context,
                              parsed.content,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      child: SelectableText(
                        parsed.content,
                        style: const TextStyle(fontSize: 14, height: 1.45),
                      ),
                    ),
                    if (parsed.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: parsed.tags
                            .map((t) => Chip(
                                  label: Text('#$t'),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                  ] else if (_ctrl.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Could not find a ```text block — the full pasted text will be used as the post.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        icon: Icon(
                          widget.onApply != null
                              ? Icons.check_rounded
                              : Icons.post_add_rounded,
                          size: 18,
                        ),
                        label: Text(
                          widget.onApply != null
                              ? 'Apply to Post'
                              : 'Create Post',
                        ),
                        onPressed: parsed == null || !parsed.hasContent
                            ? null
                            : () {
                                final prefill = _parser.toPrefill(
                                  parsed,
                                  platform: widget.platform,
                                  topic: widget.topic,
                                );
                                Navigator.pop(context);
                                if (widget.onApply != null) {
                                  widget.onApply!(prefill);
                                } else {
                                  context.pushNamed(
                                    RouteNames.createPost,
                                    extra: prefill,
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}