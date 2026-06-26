import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/clipboard_service.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/usecases/comment_usecases.dart';

class CommentSearchDelegate extends SearchDelegate {
  CommentSearchDelegate({
    required this.repository,
    required this.searchUseCase,
  });

  final CommentRepository repository;
  final SearchComments searchUseCase;

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
    return FutureBuilder(
      future: searchUseCase(query),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return snap.data!.fold(
          (failure) => Center(child: Text(failure.message)),
          (comments) {
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
                      final navigator = Navigator.of(ctx);
                      await Clipboard.setData(ClipboardData(text: c.text));
                      await ClipboardService().copyText(ctx, c.text);
                      await repository.incrementUsageCount(c.id);
                      if (navigator.mounted) close(ctx, null);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
