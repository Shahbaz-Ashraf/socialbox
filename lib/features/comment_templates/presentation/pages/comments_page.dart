import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/scrollable_bottom_sheet.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/comment_category.dart' show Comment;
import '../cubit/comment_cubit.dart';
import '../widgets/add_comment_bottom_sheet.dart';
import '../widgets/comment_tile.dart';

class CommentsPage extends StatelessWidget {
  const CommentsPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CommentCubit>(param1: categoryId),
      child: _CommentsView(categoryId: categoryId),
    );
  }
}

class _CommentsView extends StatefulWidget {
  const _CommentsView({required this.categoryId});
  final String categoryId;

  @override
  State<_CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<_CommentsView> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CommentCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        actions: [
          BlocBuilder<CommentCubit, CommentState>(
            builder: (context, state) {
              final fav = state is CommentLoaded ? state.favoritesOnly : false;
              return IconButton(
                tooltip: fav ? 'Show all' : 'Favorites only',
                icon: Icon(fav
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded),
                onPressed: cubit.toggleFavoritesFilter,
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search comments...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: cubit.setQuery,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Comment'),
        onPressed: () => _showAddComment(context),
      ),
      body: BlocBuilder<CommentCubit, CommentState>(
        builder: (context, state) {
          if (state is CommentLoading || state is CommentInitial) {
            return const LoadingListSkeleton(itemCount: 6, itemHeight: 72);
          }
          if (state is CommentError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(state.message),
                ],
              ),
            );
          }
          if (state is CommentLoaded) {
            final visible = state.visibleComments;
            if (visible.isEmpty) {
              return EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: state.comments.isEmpty
                    ? 'No comments yet'
                    : 'No matches',
                message: state.comments.isEmpty
                    ? 'Add reusable comments you can copy to any post.'
                    : 'Try a different search or turn off favorites filter.',
                actionLabel:
                    state.comments.isEmpty ? 'Add comment' : null,
                onAction: state.comments.isEmpty
                    ? () => _showAddComment(context)
                    : null,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: visible.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Theme.of(context).dividerColor),
              itemBuilder: (context, i) {
                final c = visible[i];
                return CommentTile(
                  comment: c,
                  onCopy: () => cubit.copyWithClipboard(context, c),
                  onToggleFavorite: () async {
                    final ok = await cubit.toggleFav(c.id);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not update')),
                      );
                    }
                  },
                  onEdit: () => _showEditComment(context, c),
                  onDelete: () => _confirmAndDelete(context, c),
                  onSwipeDelete: (comment) =>
                      _deleteWithUndo(context, comment),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddComment(BuildContext context) {
    final cubit = context.read<CommentCubit>();
    final catId = widget.categoryId;
    showScrollableBottomSheet(
      context: context,
      title: 'New comment',
      initialChildSize: 0.7,
      builder: (sheetCtx, scrollController) => AddCommentBottomSheet(
        scrollController: scrollController,
        embeddedInSheet: true,
        onSubmit: (text, tags) async {
          final ok = await cubit.add(
            categoryId: catId,
            text: text,
            tags: tags,
          );
          if (ok && sheetCtx.mounted) Navigator.pop(sheetCtx);
        },
      ),
    );
  }

  void _showEditComment(BuildContext context, Comment c) {
    final cubit = context.read<CommentCubit>();
    showScrollableBottomSheet(
      context: context,
      title: 'Edit comment',
      initialChildSize: 0.7,
      builder: (sheetCtx, scrollController) => AddCommentBottomSheet(
        scrollController: scrollController,
        embeddedInSheet: true,
        initialText: c.text,
        initialTags: c.tags,
        onSubmit: (text, tags) async {
          final ok = await cubit.edit(Comment(
            id: c.id,
            categoryId: c.categoryId,
            text: text,
            tags: tags,
            isFavorite: c.isFavorite,
            usageCount: c.usageCount,
            createdAt: c.createdAt,
            updatedAt: DateTime.now(),
          ));
          if (ok && sheetCtx.mounted) Navigator.pop(sheetCtx);
        },
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, Comment c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Comment?'),
        content: const Text(
          'This comment will be permanently removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _deleteWithUndo(context, c);
  }

  Future<void> _deleteWithUndo(BuildContext context, Comment c) async {
    final cubit = context.read<CommentCubit>();
    final deleted = Comment(
      id: c.id,
      categoryId: c.categoryId,
      text: c.text,
      tags: List<String>.from(c.tags),
      isFavorite: c.isFavorite,
      usageCount: c.usageCount,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
    );

    final ok = await cubit.remove(c.id);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete comment')),
      );
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Comment deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final ok = await cubit.restoreDeleted(
              categoryId: deleted.categoryId,
              text: deleted.text,
              tags: deleted.tags,
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ok ? 'Comment restored' : 'Could not restore comment',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
