import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/clipboard_service.dart';
import '../../../../injection_container.dart';
import '../../data/constants/default_post_writing_prompt.dart';
import '../../data/datasources/prompt_datasource.dart';
import '../../domain/entities/prompt_config.dart';
import '../../domain/services/prompt_builder.dart';
import 'paste_ai_response_sheet.dart';

class DashboardAiWriterCard extends StatefulWidget {
  const DashboardAiWriterCard({super.key});

  @override
  State<DashboardAiWriterCard> createState() => _DashboardAiWriterCardState();
}

class _DashboardAiWriterCardState extends State<DashboardAiWriterCard> {
  final _topicCtrl = TextEditingController();
  final _builder = const PromptBuilder();
  late PromptConfig _config;
  late List<PromptPreset> _presets;
  String _platform = 'LinkedIn';

  @override
  void initState() {
    super.initState();
    final ds = getIt<PromptDataSource>();
    _config = ds.loadLastConfig();
    _presets = ds.loadPresets();
    _topicCtrl.text = _config.topic;
    _platform = _config.platform;
  }

  @override
  void dispose() {
    _topicCtrl.dispose();
    super.dispose();
  }

  PromptConfig get _activeConfig =>
      _config.copyWith(topic: _topicCtrl.text.trim(), platform: _platform);

  String _buildPrompt() {
    final ds = getIt<PromptDataSource>();
    return _builder.build(
      template: ds.loadTemplate(),
      config: _activeConfig,
    );
  }

  Future<void> _saveConfig() async {
    final ds = getIt<PromptDataSource>();
    _config = _activeConfig;
    await ds.saveLastConfig(_config);
  }

  Future<void> _copyPrompt() async {
    if (_topicCtrl.text.trim().isEmpty) return;
    await _saveConfig();
    final prompt = _buildPrompt();
    if (!mounted) return;
    await getIt<ClipboardService>().copyText(context, prompt);
    HapticFeedback.mediumImpact();
  }

  Future<void> _copyAndOpen(String url) async {
    if (_topicCtrl.text.trim().isEmpty) return;
    await _saveConfig();
    final prompt = _buildPrompt();
    await Clipboard.setData(ClipboardData(text: prompt));
    HapticFeedback.mediumImpact();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prompt copied — paste in ${uri.host}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openStudio() {
    _saveConfig();
    context.pushNamed(
      RouteNames.aiPromptStudio,
      extra: _activeConfig,
    );
  }

  void _pasteResponse() {
    showPasteAiResponseSheet(
      context,
      topic: _topicCtrl.text.trim(),
      platform: _platform,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTopic = _topicCtrl.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.tertiary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    color: theme.colorScheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Post Writer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Build prompt → copy to AI → paste response as post',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Full studio',
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: _openStudio,
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _topicCtrl,
              decoration: const InputDecoration(
                labelText: 'What do you want to write about?',
                hintText: 'e.g. Riverpod vs Bloc for state management',
                border: OutlineInputBorder(),
                filled: true,
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'LinkedIn', label: Text('LinkedIn')),
                ButtonSegment(value: 'X', label: Text('X')),
                ButtonSegment(value: 'Facebook', label: Text('Facebook')),
              ],
              selected: {_platform},
              onSelectionChanged: (s) => setState(() => _platform = s.first),
            ),
            if (_presets.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Recent presets',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.hintColor,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 6),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presets.length.clamp(0, 5),
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final p = _presets[i];
                    return ActionChip(
                      label: Text(p.name, style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        setState(() {
                          _config = p.config;
                          _topicCtrl.text = p.config.topic;
                          _platform = p.config.platform;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.content_copy_rounded, size: 18),
                    label: const Text('Copy Prompt'),
                    onPressed: hasTopic ? _copyPrompt : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.paste_rounded, size: 18),
                    label: const Text('Paste Response'),
                    onPressed: _pasteResponse,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kAiAppLinks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final app = kAiAppLinks[i];
                  return ActionChip(
                    label: Text(app.name, style: const TextStyle(fontSize: 12)),
                    onPressed:
                        hasTopic ? () => _copyAndOpen(app.url) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}