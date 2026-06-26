import 'package:equatable/equatable.dart';

import '../../../../core/utils/platform_utils.dart';

class AiPostPrefill extends Equatable {
  const AiPostPrefill({
    this.title,
    required this.content,
    this.tags = const [],
    this.platforms = const [SocialPlatform.linkedin],
    this.notes,
  });

  final String? title;
  final String content;
  final List<String> tags;
  final List<SocialPlatform> platforms;
  final String? notes;

  @override
  List<Object?> get props => [title, content, tags, platforms, notes];
}