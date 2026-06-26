import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/form_section_card.dart';
import '../../../../core/constants/predefined_categories.dart';
import '../../../../core/widgets/scrollable_bottom_sheet.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../ai_prompts/domain/entities/ai_post_prefill.dart';
import '../../../ai_prompts/domain/entities/prompt_config.dart';
import '../../../ai_prompts/presentation/widgets/paste_ai_response_sheet.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../injection_container.dart';
import '../../../hashtags/presentation/cubit/hashtag_suggestions_cubit.dart';
import '../../../hashtags/presentation/widgets/hashtag_suggestions_strip.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/social_post.dart';
import '../cubit/post_form_cubit.dart';
import '../widgets/platform_chip_selector.dart';
import '../widgets/recurring_options_sheet.dart';
import '../widgets/schedule_date_picker.dart';

class CreateEditPostPage extends StatelessWidget {
  const CreateEditPostPage({
    super.key,
    this.postId,
    this.prefillDate,
    this.aiPrefill,
  });

  final String? postId;
  final DateTime? prefillDate;
  final AiPostPrefill? aiPrefill;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<PostFormCubit>();
        if (postId != null) {
          cubit.loadById(postId!);
        } else if (aiPrefill != null) {
          cubit.loadFromAiPrefill(aiPrefill!);
        } else {
          final settings = context.read<SettingsCubit>().state;
          cubit.applyDefaultPlatforms(settings.defaultPlatforms);
          if (prefillDate != null) {
            cubit.setScheduledAt(prefillDate);
          }
        }
        return cubit;
      },
      child: const _FormView(),
    );
  }
}

class _FormView extends StatefulWidget {
  const _FormView();

  @override
  State<_FormView> createState() => _FormViewState();
}

class _FormViewState extends State<_FormView> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _tagCtrl;
  late final TextEditingController _notesCtrl;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final s = context.read<PostFormCubit>().state;
    _titleCtrl = TextEditingController(text: s.title);
    _contentCtrl = TextEditingController(text: s.content);
    _notesCtrl = TextEditingController(text: s.notes ?? '');
    _tagCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(PostFormCubit cubit) async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      cubit.addAttachment(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostFormCubit>();
    return BlocListener<PostFormCubit, PostFormData>(
      listenWhen: (prev, next) =>
          prev.title != next.title ||
          prev.content != next.content ||
          prev.notes != next.notes,
      listener: (context, state) {
        if (_titleCtrl.text != state.title) {
          _titleCtrl.text = state.title;
        }
        if (_contentCtrl.text != state.content) {
          _contentCtrl.text = state.content;
        }
        final notes = state.notes ?? '';
        if (_notesCtrl.text != notes) {
          _notesCtrl.text = notes;
        }
      },
      child: BlocBuilder<PostFormCubit, PostFormData>(
        builder: (context, state) {
          final narrow = MediaQuery.of(context).size.width < 400;
          final canCopy = state.content.trim().isNotEmpty;

          return Scaffold(
            appBar: AppBar(
              title: Text(state.id == null ? 'New Post' : 'Edit Post'),
              actions: narrow
                  ? [
                      PopupMenuButton<String>(
                        tooltip: 'Actions',
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (value) {
                          switch (value) {
                            case 'copy':
                              if (canCopy) cubit.copyContent(context);
                              break;
                            case 'ai':
                              _openAiWriter(context, state);
                              break;
                            case 'paste':
                              _pasteAiResponse(context, state, cubit);
                              break;
                            case 'template':
                              _showTemplates(context);
                              break;
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'copy',
                            enabled: canCopy,
                            child: const Text('Copy content'),
                          ),
                          const PopupMenuItem(
                            value: 'ai',
                            child: Text('AI Post Writer'),
                          ),
                          const PopupMenuItem(
                            value: 'paste',
                            child: Text('Paste AI response'),
                          ),
                          const PopupMenuItem(
                            value: 'template',
                            child: Text('Insert template'),
                          ),
                        ],
                      ),
                    ]
                  : [
                      IconButton(
                        tooltip: 'Copy content',
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: canCopy
                            ? () => cubit.copyContent(context)
                            : null,
                      ),
                      IconButton(
                        tooltip: 'AI Post Writer',
                        icon: const Icon(Icons.psychology_rounded),
                        onPressed: () => _openAiWriter(context, state),
                      ),
                      IconButton(
                        tooltip: 'Paste AI response',
                        icon: const Icon(Icons.paste_rounded),
                        onPressed: () =>
                            _pasteAiResponse(context, state, cubit),
                      ),
                      IconButton(
                        tooltip: 'Insert template',
                        icon: const Icon(Icons.auto_awesome_rounded),
                        onPressed: () => _showTemplates(context),
                      ),
                    ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                FormSectionCard(
                  title: 'Content',
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Give your post a short title',
                        ),
                        onChanged: cubit.setTitle,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contentCtrl,
                        maxLines: 6,
                        minLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          hintText: 'Write your post body…',
                          alignLabelWithHint: true,
                        ),
                        onChanged: cubit.setContent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FormSectionCard(
                  title: 'Platforms & status',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlatformChipSelector(
                        selected: state.platforms,
                        onToggle: cubit.togglePlatform,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PostStatus.values
                            .where((s) => s != PostStatus.partial)
                            .map((s) => ChoiceChip(
                                  label: Text(s.label),
                                  selected: state.status == s,
                                  onSelected: (_) => cubit.setStatus(s),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                if (state.status == PostStatus.scheduled ||
                    state.scheduledAt != null) ...[
                  const SizedBox(height: 12),
                  FormSectionCard(
                    title: 'Schedule',
                    child: Column(
                      children: [
                        ScheduleDatePicker(
                          value: state.scheduledAt,
                          onChanged: cubit.setScheduledAt,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Switch(
                              value: state.isRecurring,
                              onChanged: cubit.setRecurring,
                            ),
                            const Text('Recurring'),
                            const Spacer(),
                            if (state.isRecurring)
                              TextButton.icon(
                                icon: const Icon(Icons.tune_rounded, size: 18),
                                label: Text(state.recurringType.label),
                                onPressed: () =>
                                    _showRecurring(context, state, cubit),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FormSectionCard(
                  title: 'Attachments',
                  child: Column(
                    children: [
                      if (state.attachments.isNotEmpty)
                        ...state.attachments.map(
                          (path) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(path),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image_rounded,
                                  ),
                                ),
                              ),
                              title: Text(
                                p.basename(path),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                tooltip: 'Remove attachment',
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () => cubit.removeAttachment(path),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add_photo_alternate_rounded),
                          label: const Text('Add image'),
                          onPressed: () => _pickImage(cubit),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FormSectionCard(
                  title: 'Tags',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocProvider(
                        create: (_) => getIt<HashtagSuggestionsCubit>(),
                        child: HashtagSuggestionsStrip(
                          existing: state.tags,
                          onAdd: cubit.addTag,
                          onCopy: (tag) => cubit.copyHashtag(context, tag),
                        ),
                      ),
                      if (state.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: state.tags
                                .map((t) => InputChip(
                                      label: Text('#$t'),
                                      onDeleted: () => cubit.removeTag(t),
                                    ))
                                .toList(),
                          ),
                        ),
                      TextField(
                        controller: _tagCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Add tag and press Enter',
                          isDense: true,
                        ),
                        onSubmitted: (v) {
                          final t = v.trim();
                          if (t.isNotEmpty) {
                            cubit.addTag(t);
                            _tagCtrl.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FormSectionCard(
                  title: 'Notes',
                  child: TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Private notes about this post…',
                      alignLabelWithHint: true,
                    ),
                    onChanged: cubit.setNotes,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.save_rounded),
                  label:
                      Text(state.id == null ? 'Create post' : 'Save changes'),
                  onPressed: !state.isValid
                      ? null
                      : () async {
                          HapticFeedback.lightImpact();
                          final saved = await cubit.submit();
                          if (!context.mounted) return;
                          if (saved != null) {
                            AppSnackbar.success(
                              context,
                              'Post saved successfully',
                            );
                            if (saved.status == PostStatus.scheduled &&
                                saved.scheduledAt != null) {
                              await _offerReminder(context, saved);
                            }
                            if (context.mounted) context.pop();
                          } else {
                            AppSnackbar.error(
                              context,
                              'Could not save — check fields and try again',
                            );
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _offerReminder(BuildContext context, SocialPost saved) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add a reminder?'),
        content: const Text(
          'Would you like to add a reminder notification for this scheduled post?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add Reminder'),
          ),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;
    context.pushNamed(
      RouteNames.reminders,
      extra: {
        'prefillTitle': saved.title,
        'prefillTime': saved.scheduledAt,
        'postId': saved.id,
      },
    );
  }

  void _pasteAiResponse(
    BuildContext context,
    PostFormData state,
    PostFormCubit cubit,
  ) {
    showPasteAiResponseSheet(
      context,
      topic: state.title.isNotEmpty ? state.title : _titleCtrl.text,
      platform: state.platforms.isNotEmpty
          ? PromptConfig.platformFromSocial(state.platforms.first)
          : 'LinkedIn',
      onCopyExtracted: cubit.copyText,
      onApply: (prefill) {
        cubit.loadFromAiPrefill(prefill);
        _titleCtrl.text = prefill.title ?? '';
        _contentCtrl.text = prefill.content;
        _notesCtrl.text = prefill.notes ?? '';
        AppSnackbar.success(context, 'AI response applied to post');
      },
    );
  }

  void _openAiWriter(BuildContext context, PostFormData state) {
    final config = PromptConfig.fromPost(
      title: state.title.isNotEmpty ? state.title : _titleCtrl.text,
      content: state.content,
      platforms: state.platforms,
      tags: state.tags,
    );
    context.pushNamed(RouteNames.aiPromptStudio, extra: config);
  }

  void _showTemplates(BuildContext context) {
    showScrollableBottomSheet<void>(
      context: context,
      title: 'Insert template',
      subtitle: 'Tap a snippet to append to your content',
      initialChildSize: 0.6,
      builder: (_, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        children: kPostTemplates.entries.expand((e) {
          return [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text(
                e.key,
                style: AppTextStyles.sectionHeader(context),
              ),
            ),
            ...e.value.map(
              (t) => ListTile(
                leading: const Icon(Icons.auto_awesome_rounded),
                title: Text(t, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () {
                  final cur = _contentCtrl.text;
                  _contentCtrl.text = cur.isEmpty ? t : '$cur\n\n$t';
                  if (context.mounted) {
                    context
                        .read<PostFormCubit>()
                        .setContent(_contentCtrl.text);
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ];
        }).toList(),
      ),
    );
  }

  void _showRecurring(
    BuildContext context,
    PostFormData state,
    PostFormCubit cubit,
  ) {
    showScrollableBottomSheet<void>(
      context: context,
      title: 'Recurring options',
      initialChildSize: 0.55,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: RecurringOptionsSheet(
          type: state.recurringType,
          days: state.recurringDays,
          onChanged: (type, days) {
            cubit.setRecurringType(type);
            for (final d in days) {
              if (!cubit.state.recurringDays.contains(d)) {
                cubit.toggleRecurringDay(d);
              }
            }
          },
        ),
      ),
    );
  }
}