import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ai_prompts/domain/entities/ai_post_prefill.dart';
import '../../../hashtags/domain/usecases/hashtag_usecases.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/post_usecases.dart';

class PostFormData extends Equatable {
  const PostFormData({
    this.id,
    this.title = '',
    this.content = '',
    this.platforms = const [],
    this.status = PostStatus.draft,
    this.scheduledAt,
    this.isRecurring = false,
    this.recurringType = RecurringType.none,
    this.recurringDays = const [],
    this.attachments = const [],
    this.tags = const [],
    this.notes,
  });

  final String? id;
  final String title;
  final String content;
  final List<SocialPlatform> platforms;
  final PostStatus status;
  final DateTime? scheduledAt;
  final bool isRecurring;
  final RecurringType recurringType;
  final List<int> recurringDays;
  final List<String> attachments;
  final List<String> tags;
  final String? notes;

  bool get isValid =>
      title.trim().isNotEmpty &&
      content.trim().isNotEmpty &&
      platforms.isNotEmpty;

  bool get isScheduledValid =>
      status != PostStatus.scheduled ||
      (scheduledAt != null && scheduledAt!.isAfter(DateTime.now()));

  PostFormData copyWith({
    String? id,
    String? title,
    String? content,
    List<SocialPlatform>? platforms,
    PostStatus? status,
    DateTime? scheduledAt,
    bool clearSchedule = false,
    bool? isRecurring,
    RecurringType? recurringType,
    List<int>? recurringDays,
    List<String>? attachments,
    List<String>? tags,
    String? notes,
    bool clearNotes = false,
  }) =>
      PostFormData(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        platforms: platforms ?? this.platforms,
        status: status ?? this.status,
        scheduledAt: clearSchedule ? null : (scheduledAt ?? this.scheduledAt),
        isRecurring: isRecurring ?? this.isRecurring,
        recurringType: recurringType ?? this.recurringType,
        recurringDays: recurringDays ?? this.recurringDays,
        attachments: attachments ?? this.attachments,
        tags: tags ?? this.tags,
        notes: clearNotes ? null : (notes ?? this.notes),
      );

  factory PostFormData.fromPost(SocialPost p) => PostFormData(
        id: p.id,
        title: p.title,
        content: p.content,
        platforms: p.platforms,
        status: p.status,
        scheduledAt: p.scheduledAt,
        isRecurring: p.isRecurring,
        recurringType: p.recurringType,
        recurringDays: p.recurringDays,
        attachments: p.attachments,
        tags: p.tags,
        notes: p.notes,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        platforms,
        status,
        scheduledAt,
        isRecurring,
        recurringType,
        recurringDays,
        attachments,
        tags,
        notes,
      ];
}

class PostFormCubit extends Cubit<PostFormData> {
  PostFormCubit({
    required this.createPost,
    required this.updatePost,
    required this.getPostById,
    required this.recordHashtagUsage,
    required this.extractHashtags,
    PostFormData? initial,
  }) : super(initial ?? const PostFormData());

  final CreatePost createPost;
  final UpdatePost updatePost;
  final GetPostById getPostById;
  final RecordHashtagUsage recordHashtagUsage;
  final ExtractHashtags extractHashtags;

  void load(SocialPost post) => emit(PostFormData.fromPost(post));

  Future<bool> loadById(String id) async {
    final result = await getPostById(id);
    return result.fold(
      (_) => false,
      (post) {
        emit(PostFormData.fromPost(post));
        return true;
      },
    );
  }

  void applyDefaultPlatforms(List<SocialPlatform> platforms) {
    if (state.id == null && platforms.isNotEmpty && state.platforms.isEmpty) {
      emit(state.copyWith(platforms: platforms));
    }
  }

  void loadFromAiPrefill(AiPostPrefill prefill) => emit(PostFormData(
        title: prefill.title ?? '',
        content: prefill.content,
        platforms: prefill.platforms.isNotEmpty
            ? prefill.platforms
            : const [SocialPlatform.linkedin],
        tags: prefill.tags,
        notes: prefill.notes,
        status: PostStatus.draft,
      ));

  void setTitle(String v) => emit(state.copyWith(title: v));
  void setContent(String v) => emit(state.copyWith(content: v));
  void setNotes(String? v) =>
      emit(state.copyWith(notes: v, clearNotes: v == null || v.isEmpty));
  void togglePlatform(SocialPlatform p) {
    final list = List<SocialPlatform>.from(state.platforms);
    if (list.contains(p)) {
      list.remove(p);
    } else {
      list.add(p);
    }
    emit(state.copyWith(platforms: list));
  }

  void setStatus(PostStatus s) {
    emit(state.copyWith(
      status: s,
      clearSchedule: s == PostStatus.draft || s == PostStatus.posted,
    ));
  }

  void setScheduledAt(DateTime? dt) =>
      emit(state.copyWith(scheduledAt: dt, clearSchedule: dt == null));
  void setRecurring(bool v) =>
      emit(state.copyWith(isRecurring: v, recurringType: v ? RecurringType.daily : RecurringType.none));
  void setRecurringType(RecurringType t) => emit(state.copyWith(recurringType: t));
  void toggleRecurringDay(int weekday) {
    final list = List<int>.from(state.recurringDays);
    if (list.contains(weekday)) {
      list.remove(weekday);
    } else {
      list.add(weekday);
      list.sort();
    }
    emit(state.copyWith(recurringDays: list));
  }

  void addTag(String tag) {
    if (state.tags.contains(tag)) return;
    emit(state.copyWith(tags: [...state.tags, tag]));
  }

  void removeTag(String tag) {
    emit(state.copyWith(tags: state.tags.where((t) => t != tag).toList()));
  }

  void addAttachment(String path) {
    if (state.attachments.contains(path)) return;
    emit(state.copyWith(attachments: [...state.attachments, path]));
  }

  void removeAttachment(String path) {
    emit(state.copyWith(
        attachments: state.attachments.where((a) => a != path).toList()));
  }

  Future<void> _recordHashtags() async {
    final fromContent =
        (await extractHashtags(state.content)).getOrElse((_) => <String>[]);
    final merged = <String>{
      ...fromContent,
      ...state.tags.map((t) => t.toLowerCase()),
    };
    if (merged.isEmpty) return;
    await recordHashtagUsage(merged.toList());
  }

  Future<SocialPost?> submit() async {
    if (!state.isValid) return null;
    if (!state.isScheduledValid) return null;
    if (state.id == null) {
      final result = await createPost(CreatePostParams(
        title: state.title.trim(),
        content: state.content.trim(),
        platforms: state.platforms,
        status: state.status,
        scheduledAt: state.scheduledAt,
        isRecurring: state.isRecurring,
        recurringType: state.recurringType,
        recurringDays: state.recurringDays,
        attachments: state.attachments,
        tags: state.tags,
        notes: state.notes,
      ));
      return result.fold(
        (_) => null,
        (post) async {
          await _recordHashtags();
          return post;
        },
      );
    } else {
      final r = await updatePost(UpdatePostParams(
        id: state.id!,
        title: state.title.trim(),
        content: state.content.trim(),
        platforms: state.platforms,
        status: state.status,
        scheduledAt: state.scheduledAt,
        isRecurring: state.isRecurring,
        recurringType: state.recurringType,
        recurringDays: state.recurringDays,
        attachments: state.attachments,
        tags: state.tags,
        notes: state.notes,
        createdAt: DateTime.now(),
      ));
      return r.fold(
        (_) => null,
        (post) async {
          await _recordHashtags();
          return post;
        },
      );
    }
  }
}