import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../comment_templates/domain/entities/comment_category.dart';
import '../../../posts/domain/entities/social_post.dart';

sealed class GlobalSearchResult {
  const GlobalSearchResult();
}

final class GlobalSearchPostResult extends GlobalSearchResult {
  const GlobalSearchPostResult(this.post);
  final SocialPost post;
}

final class GlobalSearchCommentResult extends GlobalSearchResult {
  const GlobalSearchCommentResult(this.comment);
  final Comment comment;
}

class GlobalSearchDelegate extends SearchDelegate<void> {
  GlobalSearchDelegate({
    required this.searchPosts,
    required this.searchComments,
  });

  final Future<List<SocialPost>> Function(String query) searchPosts;
  final Future<List<Comment>> Function(String query) searchComments;

  @override
  String? get searchFieldLabel => 'Search posts and comments';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext ctx) => _build(ctx);

  @override
  Widget buildSuggestions(BuildContext ctx) => _build(ctx);

  Future<List<GlobalSearchResult>> _runSearch(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return const [];

    final postsFuture = searchPosts(trimmed);
    final commentsFuture = searchComments(trimmed);
    final results = await Future.wait([postsFuture, commentsFuture]);
    final posts = results[0] as List<SocialPost>;
    final comments = results[1] as List<Comment>;

    return [
      ...posts.map(GlobalSearchPostResult.new),
      ...comments.map(GlobalSearchCommentResult.new),
    ];
  }

  Widget _build(BuildContext ctx) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Search posts by title or content, and comment templates'),
      );
    }

    return FutureBuilder<List<GlobalSearchResult>>(
      future: _runSearch(query),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snap.data ?? const [];
        if (results.isEmpty) {
          return const Center(child: Text('No matching posts or comments'));
        }

        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final result = results[i];
            return switch (result) {
              GlobalSearchPostResult(:final post) => ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    close(ctx, null);
                    ctx.pushNamed(
                      RouteNames.postDetail,
                      pathParameters: {'id': post.id},
                    );
                  },
                ),
              GlobalSearchCommentResult(:final comment) => ListTile(
                  leading: const Icon(Icons.comment_outlined),
                  title: Text(
                    comment.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text('Comment template'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    close(ctx, null);
                    ctx.pushNamed(
                      RouteNames.comments,
                      pathParameters: {'categoryId': comment.categoryId},
                    );
                  },
                ),
            };
          },
        );
      },
    );
  }
}