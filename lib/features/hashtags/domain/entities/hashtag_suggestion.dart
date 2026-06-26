import 'package:equatable/equatable.dart';

class HashtagSuggestion extends Equatable {
  const HashtagSuggestion({
    required this.tag,
    required this.usageCount,
    required this.lastUsedAt,
    required this.createdAt,
  });

  final String tag;
  final int usageCount;
  final DateTime lastUsedAt;
  final DateTime createdAt;

  @override
  List<Object?> get props => [tag, usageCount, lastUsedAt];
}
