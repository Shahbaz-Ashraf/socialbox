import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/prompt_config.dart';
import '../cubit/ai_prompt_cubit.dart';
import 'ai_app_picker_sheet.dart';
import 'ai_platform_chip_row.dart';
import 'paste_ai_response_sheet.dart';
import 'preset_load_helper.dart';

class DashboardAiWriterCard extends StatefulWidget {
  const DashboardAiWriterCard({super.key});

  @override
  State<DashboardAiWriterCard> createState() => _DashboardAiWriterCardState();
}

class _DashboardAiWriterCardState extends State<DashboardAiWriterCard> {
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

  AiPromptCubit get _cubit => context.read<AiPromptCubit>();

  void _syncTopicFromUser(String value) => _cubit.updateField(topic: value);

  void _syncTopicFromCubit(String topic) {
    if (_topicCtrl.text == topic) return;
    _topicCtrl.value = TextEditingValue(
      text: topic,
      selection: TextSelection.collapsed(offset: topic.length),
    );
  }

  void _ensureTopicInCubit() {
    final topic = _topicCtrl.text;
    if (topic != _cubit.state.config.topic) {
      _cubit.updateField(topic: topic);
    }
  }

  Future<void> _confirmPresetLoad(PromptPreset preset) async {
    final confirmed = await confirmPresetLoadIfNeeded(
      context,
      currentConfig: _cubit.state.config,
      preset: preset,
    );
    if (!confirmed || !mounted) return;
    _cubit.loadPreset(preset);
    _syncTopicFromCubit(preset.config.topic);
  }

  Future<void> _copyPrompt() async {
    _ensureTopicInCubit();
    _cubit.flushPersist();
    if (!_cubit.state.config.isReady) return;
    final prompt = _cubit.buildPromptForCopy();
    if (!mounted) return;
    await _cubit.copyPrompt(context, prompt);
    HapticFeedback.mediumImpact();
  }

  Future<void> _copyAndOpen(String url) async {
    _ensureTopicInCubit();
    _cubit.flushPersist();
    if (!_cubit.state.config.isReady) return;
    final prompt = _cubit.buildPromptForCopy();
    await _cubit.copyPrompt(context, prompt);
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
    _ensureTopicInCubit();
    _cubit.flushPersist();
    context.pushNamed(RouteNames.aiPromptStudio, extra: _cubit);
  }

  void _pasteResponse() {
    _ensureTopicInCubit();
    final config = _cubit.state.config;
    showPasteAiResponseSheet(
      context,
      topic: config.topic,
      platform: config.platform,
      onCopyExtracted: _cubit.copyPrompt,
    );
  }

  void _openAiPicker(bool hasTopic) {
    showAiAppPickerSheet(
      context,
      enabled: hasTopic,
      onCopyAndOpen: _copyAndOpen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AiPromptCubit, AiPromptState>(
      listenWhen: (prev, next) => prev.config.topic != next.config.topic,
      listener: (context, state) => _syncTopicFromCubit(state.config.topic),
      child: BlocBuilder<AiPromptCubit, AiPromptState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final hasTopic = state.config.isReady;

          return Container(
            decoration: AppDecorations.modernCard(context),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Writer',
                              style: AppTextStyles.sectionHeader(context)
                                  .copyWith(fontSize: 14),
                            ),
                            Text(
                              'Topic → copy prompt → paste result',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Open studio',
                        visualDensity: VisualDensity.compact,
                        onPressed: _openStudio,
                        icon: const Icon(Icons.tune_rounded, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _topicCtrl,
                    decoration: InputDecoration(
                      hintText: 'What should this post be about?',
                      prefixIcon: const Icon(Icons.edit_outlined, size: 20),
                      suffixIcon: hasTopic
                          ? Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    onChanged: _syncTopicFromUser,
                    onSubmitted: _syncTopicFromUser,
                  ),
                  const SizedBox(height: 10),
                  AiPlatformChipRow(
                    selected: state.config.platform,
                    onSelected: (p) => _cubit.updateField(platform: p),
                  ),
                  if (state.presets.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.presets.length.clamp(0, 5),
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (_, i) {
                          final preset = state.presets[i];
                          return FilterChip(
                            label: Text(preset.name),
                            visualDensity: VisualDensity.compact,
                            onSelected: (_) => _confirmPresetLoad(preset),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: hasTopic ? _copyPrompt : null,
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Copy'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pasteResponse,
                          icon: const Icon(Icons.paste_rounded, size: 18),
                          label: const Text('Paste'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Open in AI',
                        onPressed:
                            hasTopic ? () => _openAiPicker(hasTopic) : null,
                        icon: const Icon(Icons.open_in_new_rounded, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}