import 'package:fpdart/fpdart.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/hashtag_suggestion.dart';
import '../../domain/repositories/hashtag_repository.dart';
import '../datasources/hashtag_datasource.dart';
import '../models/hashtag_model.dart';

class HashtagRepositoryImpl implements HashtagRepository {
  HashtagRepositoryImpl(this._local);
  final HashtagLocalDataSource _local;

  @override
  Stream<List<HashtagSuggestion>> watchSuggestions(HashtagFilter filter) {
    return _local.watchTop(limit: filter.limit).map(
          (rows) => _filterAndMap(rows, filter.query),
        );
  }

  @override
  Future<Either<Failure, List<HashtagSuggestion>>> getSuggestions(
      HashtagFilter filter) async {
    try {
      final rows = await _local.getTop(limit: filter.limit);
      return Right(_filterAndMap(rows, filter.query));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> recordUsage(List<String> tags) async {
    try {
      await _local.recordUsage(tags);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAll() async {
    try {
      await _local.clear();
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  List<HashtagSuggestion> _filterAndMap(
      List<HashtagSuggestionRow> rows, String? query) {
    Iterable<HashtagSuggestionRow> list = rows;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((r) => r.tag.contains(q));
    }
    return list.map((r) => r.toDomain()).toList();
  }
}
