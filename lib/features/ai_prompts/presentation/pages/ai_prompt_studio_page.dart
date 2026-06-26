import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../injection_container.dart';
import '../../data/constants/default_post_writing_prompt.dart';
import '../../domain/constants/prompt_options.dart';
import '../../domain/entities/prompt_config.dart';
import '../cubit/ai_prompt_cubit.dart';
import '../widgets/paste_ai_response_sheet.dart';

List<DropdownMenuItem<String>> _dropdownItems(List<String> values) => values
    .map(
      (v) => DropdownMenuItem(
        value: v,
        child: Text(v, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    )
    .toList();

List<Widget> _selectedDropdownLabels(List<String> values) => values
    .map(
      (v) => Align(
        alignment: Alignment.centerLeft,
        child: Text(v, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    )
    .toList();

String _dropdownValue(
  String? value,
  List<String> options, {
  String? fallback,
}) {
  if (value != null && value.isNotEmpty && options.contains(value)) {
    return value;
  }
  return fallback ?? options.first;
}

String? _optionalDropdownValue(String? value, List<String> options) {
  if (value != null && value.isNotEmpty && options.contains(value)) {
    return value;
  }
  return null;
}

class AiPromptStudioPage extends StatelessWidget {
  const AiPromptStudioPage({super.key, this.initialConfig});

  final PromptConfig? initialConfig;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<AiPromptCubit>();
        if (initialConfig != null) {
          cubit.updateConfig(initialConfig!);
        }
        return cubit;
      },
      child: const _StudioView(),
    );
  }
}

class _StudioView extends StatefulWidget {
  const _StudioView();

  @override
  State<_StudioView> createState() => _StudioViewState();
}

class _StudioViewState extends State<_StudioView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final TextEditingController _topicCtrl;
  late final TextEditingController _primaryKwCtrl;
  late final TextEditingController _secondaryKwCtrl;
  late final TextEditingController _audienceCtrl;
  late final TextEditingController _wordLimitCtrl;
  late final TextEditingController _emojiCtrl;
  late final TextEditingController _hashtagCtrl;
  late final TextEditingController _templateCtrl;
  bool _synced = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final config = context.read<AiPromptCubit>().state.config;
    _topicCtrl = TextEditingController(text: config.topic);
    _primaryKwCtrl = TextEditingController(text: config.primaryKeyword);
    _secondaryKwCtrl = TextEditingController(text: config.secondaryKeywords);
    _audienceCtrl = TextEditingController(text: config.targetAudience);
    _wordLimitCtrl = TextEditingController(text: config.wordLimit);
    _emojiCtrl = TextEditingController(text: config.emojiRange);
    _hashtagCtrl = TextEditingController(text: config.hashtagRange);
    _templateCtrl = TextEditingController(
      text: context.read<AiPromptCubit>().state.template,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _topicCtrl.dispose();
    _primaryKwCtrl.dispose();
    _secondaryKwCtrl.dispose();
    _audienceCtrl.dispose();
    _wordLimitCtrl.dispose();
    _emojiCtrl.dispose();
    _hashtagCtrl.dispose();
    _templateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiPromptCubit, AiPromptState>(
      listener: (context, state) {
        if (state.showPreview) {
          final cubit = context.read<AiPromptCubit>();
          _showPreviewSheet(context, state.builtPrompt, cubit);
          cubit.hidePreview();
        }
        if (!_synced) {
          _synced = true;
          return;
        }
        if (_templateCtrl.text != state.template) {
          _templateCtrl.text = state.template;
        }
      },
      builder: (context, state) {
        final cubit = context.read<AiPromptCubit>();
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Post Writer'),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(icon: Icon(Icons.tune_rounded), text: 'Configure'),
                Tab(icon: Icon(Icons.code_rounded), text: 'Template'),
              ],
            ),
            actions: [
              if (state.presets.isNotEmpty)
                IconButton(
                  tooltip: 'Load preset',
                  icon: const Icon(Icons.bookmark_rounded),
                  onPressed: () => _showPresets(context),
                ),
              IconButton(
                tooltip: 'Save preset',
                icon: const Icon(Icons.bookmark_add_outlined),
                onPressed: () => _savePresetDialog(context),
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _ConfigTab(
                state: state,
                cubit: cubit,
                topicCtrl: _topicCtrl,
                primaryKwCtrl: _primaryKwCtrl,
                secondaryKwCtrl: _secondaryKwCtrl,
                audienceCtrl: _audienceCtrl,
                wordLimitCtrl: _wordLimitCtrl,
                emojiCtrl: _emojiCtrl,
                hashtagCtrl: _hashtagCtrl,
              ),
              _TemplateTab(
                templateCtrl: _templateCtrl,
                cubit: cubit,
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.visibility_rounded, size: 18),
                          label: const Text('Preview'),
                          onPressed: () => cubit.buildPrompt(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.content_copy_rounded, size: 18),
                          label: const Text('Copy Prompt'),
                          onPressed: state.config.isReady
                              ? () => _copyPrompt(context, cubit)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.paste_rounded, size: 18),
                      label: const Text('Paste AI Response → New Post'),
                      onPressed: () => showPasteAiResponseSheet(
                        context,
                        topic: state.config.topic,
                        platform: state.config.platform,
                        onCopyExtracted:
                            context.read<AiPromptCubit>().copyPrompt,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AiAppShortcuts(
                    onCopyAndOpen: (url) => _copyAndOpen(context, cubit, url),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _copyPrompt(BuildContext context, AiPromptCubit cubit) async {
    final prompt = cubit.buildPrompt();
    await cubit.copyPrompt(context, prompt);
    HapticFeedback.mediumImpact();
  }

  Future<void> _copyAndOpen(
    BuildContext context,
    AiPromptCubit cubit,
    String url,
  ) async {
    final prompt = cubit.buildPrompt();
    await Clipboard.setData(ClipboardData(text: prompt));
    HapticFeedback.mediumImpact();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prompt copied — paste in ${uri.host}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPreviewSheet(BuildContext context, String prompt, AiPromptCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Prompt Preview',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_rounded),
                    onPressed: () => Share.share(prompt, subject: 'AI Post Prompt'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy_rounded),
                    onPressed: () => cubit.copyPrompt(sheetCtx, prompt),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  prompt,
                  style: const TextStyle(fontSize: 13, height: 1.45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePresetDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save Preset'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Preset name',
            hintText: 'e.g. Flutter Tutorial Post',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameCtrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameCtrl.dispose();
    if (name != null && name.isNotEmpty && context.mounted) {
      await context.read<AiPromptCubit>().savePreset(name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preset "$name" saved')),
        );
      }
    }
  }

  void _showPresets(BuildContext context) {
    final cubit = context.read<AiPromptCubit>();
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Saved Presets',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ...cubit.state.presets.map((p) => ListTile(
                  leading: const Icon(Icons.bookmark_rounded),
                  title: Text(p.name),
                  subtitle: Text(
                    p.config.topic.isEmpty
                        ? 'No topic set'
                        : p.config.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () {
                      cubit.deletePreset(p.id);
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    cubit.loadPreset(p);
                    _topicCtrl.text = p.config.topic;
                    _primaryKwCtrl.text = p.config.primaryKeyword;
                    _secondaryKwCtrl.text = p.config.secondaryKeywords;
                    _audienceCtrl.text = p.config.targetAudience;
                    _wordLimitCtrl.text = p.config.wordLimit;
                    _emojiCtrl.text = p.config.emojiRange;
                    _hashtagCtrl.text = p.config.hashtagRange;
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _ConfigTab extends StatelessWidget {
  const _ConfigTab({
    required this.state,
    required this.cubit,
    required this.topicCtrl,
    required this.primaryKwCtrl,
    required this.secondaryKwCtrl,
    required this.audienceCtrl,
    required this.wordLimitCtrl,
    required this.emojiCtrl,
    required this.hashtagCtrl,
  });

  final AiPromptState state;
  final AiPromptCubit cubit;
  final TextEditingController topicCtrl;
  final TextEditingController primaryKwCtrl;
  final TextEditingController secondaryKwCtrl;
  final TextEditingController audienceCtrl;
  final TextEditingController wordLimitCtrl;
  final TextEditingController emojiCtrl;
  final TextEditingController hashtagCtrl;

  @override
  Widget build(BuildContext context) {
    final c = state.config;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(
          icon: Icons.lightbulb_rounded,
          title: 'Topic & Keywords',
          subtitle: 'What should the AI write about?',
        ),
        TextField(
          controller: topicCtrl,
          decoration: const InputDecoration(
            labelText: 'Topic *',
            hintText: 'e.g. How I fixed a memory leak in my Flutter app',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (v) => cubit.updateField(topic: v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: primaryKwCtrl,
          decoration: const InputDecoration(
            labelText: 'Primary Keyword',
            hintText: 'e.g. Flutter performance',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => cubit.updateField(primaryKeyword: v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: secondaryKwCtrl,
          decoration: const InputDecoration(
            labelText: 'Secondary Keywords',
            hintText: 'e.g. dart, memory management, profiling',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => cubit.updateField(secondaryKeywords: v),
        ),
        const SizedBox(height: 20),
        _SectionHeader(
          icon: Icons.public_rounded,
          title: 'Platform & Audience',
        ),
        DropdownButtonFormField<String>(
          key: ValueKey('platform-${c.platform}'),
          initialValue: _dropdownValue(c.platform, PromptConfig.aiPlatforms),
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Platform',
            border: OutlineInputBorder(),
          ),
          items: _dropdownItems(PromptConfig.aiPlatforms),
          selectedItemBuilder: (context) =>
              _selectedDropdownLabels(PromptConfig.aiPlatforms),
          onChanged: (v) {
            if (v != null) cubit.updateField(platform: v);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey('audience-${c.targetAudience}'),
          initialValue: kTargetAudiences.contains(c.targetAudience)
              ? c.targetAudience
              : null,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Target Audience (quick pick)',
            border: OutlineInputBorder(),
          ),
          items: _dropdownItems(kTargetAudiences),
          selectedItemBuilder: (context) =>
              _selectedDropdownLabels(kTargetAudiences),
          onChanged: (v) {
            if (v != null) {
              audienceCtrl.text = v;
              cubit.updateField(targetAudience: v);
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: audienceCtrl,
          decoration: const InputDecoration(
            labelText: 'Target Audience (custom)',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (v) => cubit.updateField(targetAudience: v),
        ),
        const SizedBox(height: 20),
        _SectionHeader(
          icon: Icons.palette_rounded,
          title: 'Voice & Style',
        ),
        DropdownButtonFormField<String>(
          key: ValueKey('archetype-${c.brandArchetype}'),
          initialValue: _dropdownValue(c.brandArchetype, kBrandArchetypes),
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Brand Archetype',
            border: OutlineInputBorder(),
          ),
          items: _dropdownItems(kBrandArchetypes),
          selectedItemBuilder: (context) =>
              _selectedDropdownLabels(kBrandArchetypes),
          onChanged: (v) {
            if (v != null) cubit.updateField(brandArchetype: v);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey('goal-${c.postGoal}'),
          initialValue: _dropdownValue(c.postGoal, kPostGoals),
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Post Goal',
            border: OutlineInputBorder(),
          ),
          items: _dropdownItems(kPostGoals),
          selectedItemBuilder: (context) => _selectedDropdownLabels(kPostGoals),
          onChanged: (v) {
            if (v != null) cubit.updateField(postGoal: v);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey('mode-${c.contentMode}'),
          initialValue: _dropdownValue(
            c.contentMode.isEmpty ? kContentModes.first : c.contentMode,
            kContentModes,
          ),
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Content Mode',
            border: OutlineInputBorder(),
          ),
          items: _dropdownItems(kContentModes),
          selectedItemBuilder: (context) => _selectedDropdownLabels(kContentModes),
          onChanged: (v) {
            if (v != null) cubit.updateField(contentMode: v);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey('pillar-${c.contentPillar}'),
          initialValue: _optionalDropdownValue(c.contentPillar, kContentPillars),
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Content Pillar (optional)',
            border: OutlineInputBorder(),
          ),
          items: _dropdownItems(kContentPillars),
          selectedItemBuilder: (context) => _selectedDropdownLabels(kContentPillars),
          onChanged: (v) => cubit.updateField(contentPillar: v ?? ''),
        ),
        const SizedBox(height: 20),
        _SectionHeader(
          icon: Icons.straighten_rounded,
          title: 'Limits & Formatting',
        ),
        TextField(
          controller: wordLimitCtrl,
          decoration: const InputDecoration(
            labelText: 'Word Limit',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => cubit.updateField(wordLimit: v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: emojiCtrl,
          decoration: const InputDecoration(
            labelText: 'Emojis',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => cubit.updateField(emojiRange: v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: hashtagCtrl,
          decoration: const InputDecoration(
            labelText: 'Hashtags',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => cubit.updateField(hashtagRange: v),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _TemplateTab extends StatelessWidget {
  const _TemplateTab({
    required this.templateCtrl,
    required this.cubit,
  });

  final TextEditingController templateCtrl;
  final AiPromptCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.primaryContainer.withValues(
                alpha: 0.3,
              ),
          child: const Text(
            'Edit the master prompt template. Configuration values are injected automatically when you copy.',
            style: TextStyle(fontSize: 13),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: templateCtrl,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontSize: 12, height: 1.4),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste or edit your AI system prompt here...',
              ),
              onChanged: cubit.updateTemplate,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                icon: const Icon(Icons.restore_rounded, size: 18),
                label: const Text('Reset Default'),
                onPressed: () async {
                  final yes = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Reset template?'),
                      content: const Text(
                          'This will restore the default post-writing prompt.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                  if (yes == true) await cubit.resetTemplate();
                },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Template'),
                onPressed: () async {
                  await cubit.persistTemplate();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Template saved')),
                    );
                  }
                },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiAppShortcuts extends StatelessWidget {
  const _AiAppShortcuts({required this.onCopyAndOpen});

  final void Function(String url) onCopyAndOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kAiAppLinks.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          if (i == kAiAppLinks.length) {
            return ActionChip(
              avatar: const Icon(Icons.share_rounded, size: 16),
              label: const Text('Share'),
              onPressed: () {
                final cubit = context.read<AiPromptCubit>();
                if (!cubit.state.config.isReady) return;
                final prompt = cubit.buildPrompt();
                Share.share(prompt, subject: 'AI Post Writing Prompt');
              },
            );
          }
          final app = kAiAppLinks[i];
          return ActionChip(
            label: Text(app.name),
            onPressed: () => onCopyAndOpen(app.url),
          );
        },
      ),
    );
  }
}