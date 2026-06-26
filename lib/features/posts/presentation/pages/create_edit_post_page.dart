import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/constants/predefined_categories.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../ai_prompts/domain/entities/ai_post_prefill.dart';
import '../../../ai_prompts/domain/entities/prompt_config.dart';
import '../../../ai_prompts/presentation/widgets/paste_ai_response_sheet.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../injection_container.dart';
import '../../../hashtags/data/services/hashtag_service.dart';
import '../../../hashtags/presentation/widgets/hashtag_suggestions_strip.dart';
import '../../domain/usecases/post_usecases.dart';
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
        final cubit = PostFormCubit(
          createPost: getIt<CreatePost>(),
          updatePost: getIt<UpdatePost>(),
        );
        if (postId != null) {
          getIt<GetPostById>().call(postId!).then((r) {
            r.fold((_) {}, (p) => cubit.load(p));
          });
        } else if (aiPrefill != null) {
          cubit.loadFromAiPrefill(aiPrefill!);
        } else if (prefillDate != null) {
          cubit.setScheduledAt(prefillDate);
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostFormCubit>();
    return BlocBuilder<PostFormCubit, PostFormData>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.id == null ? 'New Post' : 'Edit Post'),
            actions: [
              IconButton(
                tooltip: 'AI Post Writer',
                icon: const Icon(Icons.psychology_rounded),
                onPressed: () => _openAiWriter(context, state),
              ),
              IconButton(
                tooltip: 'Paste AI response',
                icon: const Icon(Icons.paste_rounded),
                onPressed: () => _pasteAiResponse(context, state, cubit),
              ),
              IconButton(
                tooltip: 'Insert template',
                icon: const Icon(Icons.auto_awesome_rounded),
                onPressed: () => _showTemplates(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
                ),
                onChanged: cubit.setContent,
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Platforms'),
              PlatformChipSelector(
                selected: state.platforms,
                onToggle: cubit.togglePlatform,
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Status'),
              Wrap(
                spacing: 8,
                children: PostStatus.values
                    .where((s) => s != PostStatus.partial)
                    .map((s) => ChoiceChip(
                          label: Text(s.label),
                          selected: state.status == s,
                          onSelected: (_) => cubit.setStatus(s),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              if (state.status == PostStatus.scheduled ||
                  state.scheduledAt != null) ...[
                const _SectionLabel('Schedule'),
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
                        onPressed: () => _showRecurring(context, state, cubit),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              const _SectionLabel('Tags'),
              HashtagSuggestionsStrip(
                existing: state.tags,
                onAdd: (tag) {
                  cubit.addTag(tag);
                },
              ),
              if (state.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Wrap(
                    spacing: 6,
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
                  hintText: 'Add tag + Enter',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (v) {
                  final t = v.trim();
                  if (t.isNotEmpty) {
                    cubit.addTag(t);
                    _tagCtrl.clear();
                  }
                },
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Notes (optional)'),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Private notes about this post...',
                ),
                onChanged: (v) => cubit.setNotes(v),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.save_rounded),
                label: Text(state.id == null ? 'Create Post' : 'Save Changes'),
                onPressed: !state.isValid
                    ? null
                    : () async {
                        HapticFeedback.lightImpact();
                        final ok = await cubit.submit();
                        if (!mounted) return;
                        if (ok) {
                          // Record hashtag usage in the background.
                          unawaited(
                            getIt<HashtagService>().recordFromContent(
                              content: state.content,
                              explicitTags: state.tags,
                            ),
                          );
                          AppSnackbar.success(
                              context, 'Post saved successfully');
                          if (state.status == PostStatus.scheduled &&
                              state.scheduledAt != null) {
                            await _offerReminder(context, state);
                          }
                          if (mounted) context.pop();
                        } else {
                          AppSnackbar.error(
                              context,
                              'Could not save — check fields and try again');
                        }
                      },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _offerReminder(BuildContext context, PostFormData state) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add a reminder?'),
        content: const Text(
            'Would you like to add a reminder notification for this scheduled post?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add Reminder')),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;
    context.pushNamed(
      'reminders',
      extra: {
        'prefillTitle': state.title,
        'prefillTime': state.scheduledAt,
        'postId': state.id,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: kPostTemplates.entries.expand((e) {
            return [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  e.key.toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, letterSpacing: 1.2),
                ),
              ),
              ...e.value.map(
                (t) => ListTile(
                  leading: const Icon(Icons.auto_awesome_rounded),
                  title: Text(t),
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
      ),
    );
  }

  void _showRecurring(
      BuildContext context, PostFormData state, PostFormCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RecurringOptionsSheet(
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}
