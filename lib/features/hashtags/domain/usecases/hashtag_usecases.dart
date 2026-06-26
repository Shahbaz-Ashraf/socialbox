import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/hashtag_suggestion.dart';
import '../repositories/hashtag_repository.dart';

class GetTopHashtagSuggestions
    extends StreamUseCase<List<HashtagSuggestion>, HashtagFilter> {
  GetTopHashtagSuggestions(this._repo);
  final HashtagRepository _repo;

  @override
  Stream<Either<Failure, List<HashtagSuggestion>>> call(HashtagFilter params) {
    return _repo
        .watchSuggestions(params)
        .map((list) => Right<Failure, List<HashtagSuggestion>>(list));
  }
}

class WatchTopHashtagSuggestions
    extends StreamUseCase<List<HashtagSuggestion>, HashtagFilter> {
  WatchTopHashtagSuggestions(this._repo);
  final HashtagRepository _repo;

  @override
  Stream<Either<Failure, List<HashtagSuggestion>>> call(HashtagFilter params) {
    return _repo
        .watchSuggestions(params)
        .map((list) => Right<Failure, List<HashtagSuggestion>>(list));
  }
}

class RecordHashtagUsage extends UseCase<Unit, List<String>> {
  RecordHashtagUsage(this._repo);
  final HashtagRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(List<String> params) =>
      _repo.recordUsage(params);
}

class ExtractHashtags extends UseCase<List<String>, String> {
  ExtractHashtags(HashtagRepository repo) : _repo = repo;
  // ignore: unused_field
  final HashtagRepository _repo;

  @override
  Future<Either<Failure, List<String>>> call(String params) async {
    return Right(_extract(params));
  }

  static final _regExp = RegExp(r'#([\p{L}0-9_]+)', unicode: true);
  static List<String> _extract(String text) {
    final matches = _regExp.allMatches(text);
    final seen = <String>{};
    final out = <String>[];
    for (final m in matches) {
      final tag = m.group(1)!.toLowerCase();
      if (tag.isEmpty || tag.length > 60) continue;
      if (seen.add(tag)) out.add(tag);
    }
    return out;
  }
}
