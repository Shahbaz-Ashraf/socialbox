import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/scrollable_bottom_sheet.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/comment_category.dart';
import '../cubit/category_cubit.dart';
import '../widgets/add_category_bottom_sheet.dart';
import '../widgets/category_card.dart';
import '../widgets/comment_search_delegate.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryCubit>(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment Library'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              final cubit = context.read<CategoryCubit>();
              showSearch(
                context: context,
                delegate: CommentSearchDelegate(
                  search: cubit.search,
                  onCopy: cubit.copySearchResult,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Category'),
        onPressed: () => _showAddCategory(context),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading || state is CategoryInitial) {
            return const _LoadingGrid();
          }
          if (state is CategoryError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<CategoryCubit>().load(),
            );
          }
          if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return const _EmptyState();
            }
            return _CategoryGrid(
              categories: state.categories,
              counts: state.commentCounts,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddCategory(BuildContext context) {
    showScrollableBottomSheet(
      context: context,
      title: 'New category',
      subtitle: 'Choose a name, icon, and color',
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (sheetCtx, scrollController) => BlocProvider.value(
        value: context.read<CategoryCubit>(),
        child: AddCategoryBottomSheet(
          scrollController: scrollController,
          embeddedInSheet: true,
          onSubmit: (name, icon, color) async {
            final ok = await context.read<CategoryCubit>().add(
                  name: name,
                  icon: icon,
                  colorHex: color,
                );
            if (ok && sheetCtx.mounted) Navigator.pop(sheetCtx);
          },
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.counts});
  final List<CommentCategory> categories;
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final predefined = categories.where((c) => c.isPredefined).toList();
    final custom = categories.where((c) => !c.isPredefined).toList();
    final width = MediaQuery.of(context).size.width;
    final cols = width > 700 ? 3 : 2;

    return CustomScrollView(
      slivers: [
        if (predefined.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Built-in', style: AppTextStyles.sectionHeader(context)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final c = predefined[i];
                  return CategoryCard(
                    category: c,
                    commentCount: counts[c.id],
                    onTap: () => context.pushNamed(
                      RouteNames.comments,
                      pathParameters: {'categoryId': c.id},
                    ),
                  );
                },
                childCount: predefined.length,
              ),
            ),
          ),
        ],
        if (custom.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Your categories',
                    style: AppTextStyles.sectionHeader(context),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.drag_handle_rounded,
                      size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Text(
                    'Drag to reorder',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            sliver: SliverReorderableList(
              onReorder: (oldIndex, newIndex) =>
                  context.read<CategoryCubit>().reorderCustom(oldIndex, newIndex),
              itemBuilder: (context, i) {
                final c = custom[i];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(c.id),
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReorderableCategoryTile(
                      category: c,
                      commentCount: counts[c.id],
                      onTap: () => context.pushNamed(
                        RouteNames.comments,
                        pathParameters: {'categoryId': c.id},
                      ),
                      onDelete: () => _confirmDeleteCategory(context, c),
                    ),
                  ),
                );
              },
              itemCount: custom.length,
            ),
          ),
        ] else
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 96),
            sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
      ],
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    CommentCategory category,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Delete "${category.name}" and all its comments? This cannot be undone.',
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
    final result = await context.read<CategoryCubit>().remove(category.id);
    if (!context.mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted')),
      ),
    );
  }
}

class _ReorderableCategoryTile extends StatelessWidget {
  const _ReorderableCategoryTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
    this.commentCount,
  });

  final CommentCategory category;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final int? commentCount;

  @override
  Widget build(BuildContext context) {
    final color = ColorFromHex.fromHex(category.colorHex);
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.drag_handle_rounded,
                  color: Theme.of(context).hintColor),
              const SizedBox(width: 8),
              Text(category.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      commentCount != null
                          ? '$commentCount comment${commentCount == 1 ? '' : 's'}'
                          : '—',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete category',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent),
                onPressed: onDelete,
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();
  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.of(context).size.width > 700 ? 3 : 2;
    return LoadingGridSkeleton(crossAxisCount: cols);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'No categories yet',
      message: 'Create a category to organize your comment templates.',
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
