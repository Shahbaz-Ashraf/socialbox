import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/usecases/comment_usecases.dart';
import '../cubit/category_cubit.dart';
import '../widgets/add_category_bottom_sheet.dart';
import '../widgets/category_card.dart';
import '../widgets/comment_search_delegate.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryCubit(
        repository: getIt<CommentRepository>(),
        getAllCategories: getIt(),
        createCategory: getIt(),
        updateCategory: getIt(),
        deleteCategory: getIt(),
      ),
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
            onPressed: () => showSearch(
              context: context,
              delegate: CommentSearchDelegate(
                searchUseCase: getIt<SearchComments>(),
                onCopied: (id, _) => getIt<IncrementUsageCount>()(id),
              ),
            ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<CategoryCubit>(),
        child: AddCategoryBottomSheet(
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
  final List categories;
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width > 700 ? 3 : 2;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final c = categories[i];
        return CategoryCard(
          category: c,
          commentCount: counts[c.id],
          onTap: () => context.pushNamed(
            RouteNames.comments,
            pathParameters: {'categoryId': c.id},
          ),
        );
      },
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 96, color: Theme.of(context).hintColor),
          const SizedBox(height: 16),
          const Text('No categories yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tap + to create your first category.'),
        ],
      ),
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
