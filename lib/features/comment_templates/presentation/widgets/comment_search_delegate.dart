import 'package:flutter/material.dart';

import '../../domain/entities/comment_category.dart';

class CommentSearchDelegate extends SearchDelegate<void> {
  CommentSearchDelegate({
    required this.search,
    required this.onCopy,
  });

  final Future<List<Comment>> Function(String query) search;
  final Future<void> Function(BuildContext context, String commentId, String text)
      onCopy;

  @override
  String? get searchFieldLabel => 'Search comments';

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

  Widget _build(BuildContext ctx) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Start typing to search comments'));
    }
    return FutureBuilder<List<Comment>>(
      future: search(query),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final comments = snap.data ?? const [];
        if (comments.isEmpty) {
          return const Center(child: Text('No matching comments'));
        }
        return ListView.separated(
          itemCount: comments.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final c = comments[i];
            return ListTile(
              title: Text(
                c.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.copy_rounded,
                      size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${c.usageCount} copies',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () async {
                  await onCopy(ctx, c.id, c.text);
                  if (!ctx.mounted) return;
                  close(ctx, null);
                },
              ),
            );
          },
        );
      },
    );
  }
}