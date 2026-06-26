import '../../domain/repositories/hashtag_repository.dart';

/// Utility service that extracts hashtags from raw text and persists them
/// in the suggestion history.
class HashtagService {
  HashtagService(this._repo);
  final HashtagRepository _repo;

  static final _hashtagRegExp = RegExp(r'#([\p{L}0-9_]+)', unicode: true);
  static final _mentionRegExp = RegExp(r'@([\p{L}0-9_.]+)', unicode: true);

  /// Returns all #tags found in [text], lowercased, deduplicated, in order.
  List<String> extractHashtags(String text) {
    final matches = _hashtagRegExp.allMatches(text);
    final seen = <String>{};
    final out = <String>[];
    for (final m in matches) {
      final tag = m.group(1)!.toLowerCase();
      if (tag.isEmpty || tag.length > 60) continue;
      if (seen.add(tag)) out.add(tag);
    }
    return out;
  }

  /// Returns all @mentions found in [text].
  List<String> extractMentions(String text) {
    final matches = _mentionRegExp.allMatches(text);
    final seen = <String>{};
    final out = <String>[];
    for (final m in matches) {
      final tag = m.group(1)!.toLowerCase();
      if (tag.isEmpty || tag.length > 60) continue;
      if (seen.add(tag)) out.add(tag);
    }
    return out;
  }

  /// Records usage of any tags found in the given text and explicit tag list.
  /// Returns the merged deduped list.
  Future<List<String>> recordFromContent({
    required String content,
    required List<String> explicitTags,
  }) async {
    final fromContent = extractHashtags(content);
    final merged = <String>{...fromContent, ...explicitTags.map((t) => t.toLowerCase())};
    final list = merged.toList();
    if (list.isEmpty) return list;
    await _repo.recordUsage(list);
    return list;
  }
}
