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
          final primary = theme.colorScheme.primary;

          return Container(
            decoration: AppDecorations.surfaceCard(context),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: AppDecorations.iconBadge(primary),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Post Writer',
                              style: AppTextStyles.cardTitle(context),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Describe, copy prompt, paste AI response',
                              style: AppTextStyles.caption.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Open studio',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.tune_rounded,
                          color: theme.hintColor,
                        ),
                        onPressed: _openStudio,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  const _StepLabel(step: 1, label: 'Topic'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _topicCtrl,
                    decoration: const InputDecoration(
                      hintText: 'What do you want to write about?',
                      helperText: 'Saved automatically as you type',
                    ),
                    minLines: 2,
                    maxLines: 3,
                    onChanged: _syncTopicFromUser,
                  ),
                  const SizedBox(height: 16),
                  const _StepLabel(step: 2, label: 'Platform'),
                  const SizedBox(height: 8),
                  AiPlatformChipRow(
                    selected: state.config.platform,
                    onSelected: (p) => _cubit.updateField(platform: p),
                  ),
                  if (state.presets.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Recent presets',
                      style: AppTextStyles.sectionHeader(context),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.presets.length.clamp(0, 5),
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final preset = state.presets[i];
                          return ActionChip(
                            label: Text(preset.name),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _confirmPresetLoad(preset),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const _StepLabel(step: 3, label: 'Actions'),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.content_copy_rounded, size: 18),
                      label: const Text('Copy Prompt'),
                      onPressed: hasTopic ? _copyPrompt : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.paste_rounded, size: 18),
                          label: const Text('Paste'),
                          onPressed: _pasteResponse,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text('Open AI'),
                          onPressed:
                              hasTopic ? () => _openAiPicker(hasTopic) : null,
                        ),
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

class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.step, required this.label});

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$step',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.stepLabel(context)),
      ],
    );
  }
}