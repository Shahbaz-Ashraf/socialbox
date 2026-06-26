import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/clipboard_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/comment_category.dart' show Comment;
import '../../domain/repositories/comment_repository.dart';
import '../../domain/usecases/comment_usecases.dart';
import '../cubit/comment_cubit.dart';
import '../widgets/add_comment_bottom_sheet.dart';
import '../widgets/comment_tile.dart';

class CommentsPage extends StatelessWidget {
  const CommentsPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = CommentCubit(
          repository: getIt<CommentRepository>(),
          createComment: getIt<CreateComment>(),
          updateComment: getIt<UpdateComment>(),
          deleteComment: getIt<DeleteComment>(),
          toggleFavorite: getIt<ToggleFavorite>(),
          incrementUsageCount: getIt<IncrementUsageCount>(),
          watchByCategory: getIt<CommentRepository>().watchCommentsByCategory,
        );
        cubit.watchCategory(categoryId);
        return cubit;
      },
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
            return const Center(child: CircularProgressIndicator());
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
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 72, color: Theme.of(context).hintColor),
                    const SizedBox(height: 12),
                    Text(
                      state.comments.isEmpty
                          ? 'No comments in this category yet.'
                          : 'No comments match your filter.',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
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
                  clipboard: getIt<ClipboardService>(),
                  onCopy: () => _copy(context, c),
                  onToggleFavorite: () async {
                    final ok = await cubit.toggleFav(c.id);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not update')),
                      );
                    }
                  },
                  onEdit: () => _showEditComment(context, c),
                  onDelete: () async {
                    final ok = await cubit.remove(c.id);
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comment deleted')),
                      );
                    }
                  },
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => AddCommentBottomSheet(
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => AddCommentBottomSheet(
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

  Future<void> _copy(BuildContext context, Comment c) async {
    final clipboard = getIt<ClipboardService>();
    await clipboard.copyText(context, c.text);
    if (!context.mounted) return;
    await context.read<CommentCubit>().copy(c);
  }
}
