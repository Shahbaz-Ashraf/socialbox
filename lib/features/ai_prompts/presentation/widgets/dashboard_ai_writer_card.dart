import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/clipboard_service.dart';
import '../../../../injection_container.dart';
import '../../data/constants/default_post_writing_prompt.dart';
import '../cubit/ai_prompt_cubit.dart';
import 'paste_ai_response_sheet.dart';

class DashboardAiWriterCard extends StatelessWidget {
  const DashboardAiWriterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiPromptCubit>(),
      child: const _DashboardAiWriterCardBody(),
    );
  }
}

class _DashboardAiWriterCardBody extends StatefulWidget {
  const _DashboardAiWriterCardBody();

  @override
  State<_DashboardAiWriterCardBody> createState() =>
      _DashboardAiWriterCardBodyState();
}

class _DashboardAiWriterCardBodyState extends State<_DashboardAiWriterCardBody> {
  late final TextEditingController _topicCtrl;

  @override
  void initState() {
    super.initState();
    final config = context.read<AiPromptCubit>().state.config;
    _topicCtrl = TextEditingController(text: config.topic);
  }

  @override
  void dispose() {
    _topicCtrl.dispose();
    super.dispose();
  }

  void _syncTopic(String value) {
    context.read<AiPromptCubit>().updateField(topic: value);
    setState(() {});
  }

  void _setPlatform(String platform) {
    context.read<AiPromptCubit>().updateField(platform: platform);
    setState(() {});
  }

  Future<void> _copyPrompt() async {
    if (_topicCtrl.text.trim().isEmpty) return;
    final cubit = context.read<AiPromptCubit>();
    final prompt = cubit.buildPrompt();
    if (!mounted) return;
    await getIt<ClipboardService>().copyText(context, prompt);
    HapticFeedback.mediumImpact();
  }

  Future<void> _copyAndOpen(String url) async {
    if (_topicCtrl.text.trim().isEmpty) return;
    final cubit = context.read<AiPromptCubit>();
    final prompt = cubit.buildPrompt();
    await getIt<ClipboardService>().copyText(context, prompt);
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
    final config = context.read<AiPromptCubit>().state.config;
    context.pushNamed(RouteNames.aiPromptStudio, extra: config);
  }

  void _pasteResponse() {
    final config = context.read<AiPromptCubit>().state.config;
    showPasteAiResponseSheet(
      context,
      topic: _topicCtrl.text.trim(),
      platform: config.platform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiPromptCubit, AiPromptState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final hasTopic = _topicCtrl.text.trim().isNotEmpty;
        final platform = state.config.platform;

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
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
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
                  onChanged: _syncTopic,
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'LinkedIn', label: Text('LinkedIn')),
                    ButtonSegment(value: 'X', label: Text('X')),
                    ButtonSegment(value: 'Facebook', label: Text('Facebook')),
                  ],
                  selected: {platform},
                  onSelectionChanged: (s) => _setPlatform(s.first),
                ),
                if (state.presets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Recent presets',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.hintColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.presets.length.clamp(0, 5),
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final preset = state.presets[i];
                        return ActionChip(
                          label: Text(
                            preset.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            context.read<AiPromptCubit>().loadPreset(preset);
                            _topicCtrl.text = preset.config.topic;
                            setState(() {});
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
                        label: Text(
                          app.name,
                          style: const TextStyle(fontSize: 12),
                        ),
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
      },
    );
  }
}