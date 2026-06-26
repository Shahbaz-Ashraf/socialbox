import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/hashtag_suggestion.dart';

class HashtagFilter {
  const HashtagFilter({this.query, this.limit = 30});
  final String? query;
  final int limit;
}

abstract class HashtagRepository {
  Stream<List<HashtagSuggestion>> watchSuggestions(HashtagFilter filter);
  Future<Either<Failure, List<HashtagSuggestion>>> getSuggestions(
      HashtagFilter filter);
  Future<Either<Failure, Unit>> recordUsage(List<String> tags);
  Future<Either<Failure, Unit>> clearAll();
}
