import '../../../../core/database/app_database.dart';
import '../../domain/entities/hashtag_suggestion.dart';

extension HashtagSuggestionRowX on HashtagSuggestionRow {
  HashtagSuggestion toDomain() => HashtagSuggestion(
        tag: tag,
        usageCount: usageCount,
        lastUsedAt: lastUsedAt,
        createdAt: createdAt,
      );
}
