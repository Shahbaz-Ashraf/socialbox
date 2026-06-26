import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/social_post.dart';
import '../bloc/post_list_bloc.dart';
import '../cubit/post_list_cubit.dart';
import '../widgets/post_card.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PostListBloc>(),
      child: const _PostsView(),
    );
  }
}

class _PostsView extends StatelessWidget {
  const _PostsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostListBloc, PostListState>(
      listenWhen: (prev, curr) =>
          curr is PostListLoaded &&
          curr.actionMessage != null &&
          (prev is! PostListLoaded ||
              prev.actionMessage != curr.actionMessage),
      listener: (context, state) {
        if (state is PostListLoaded && state.actionMessage != null) {
          AppSnackbar.info(context, state.actionMessage!);
        }
      },
      child: DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Posts'),
          actions: [
            IconButton(
              tooltip: 'AI Post Writer',
              icon: const Icon(Icons.psychology_rounded),
              onPressed: () => context.pushNamed(RouteNames.aiPromptStudio),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Draft'),
              Tab(text: 'Scheduled'),
              Tab(text: 'Posted'),
              Tab(text: 'Failed'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Post'),
          onPressed: () => context.pushNamed(RouteNames.createPost),
        ),
        body: BlocBuilder<PostListBloc, PostListState>(
          builder: (context, state) {
            if (state is PostListInitial || state is PostListLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PostListError) {
              return Center(child: Text(state.message));
            }
            if (state is PostListLoaded) {
              if (state.posts.isEmpty) {
                return _Empty(
                  onCreate: () => context.pushNamed(RouteNames.createPost),
                );
              }
              return TabBarView(
                children: [
                  _PostList(posts: state.posts),
                  _PostList(
                    posts: state.posts
                        .where((p) => p.status == PostStatus.draft)
                        .toList(),
                  ),
                  _PostList(
                    posts: state.posts
                        .where((p) => p.status == PostStatus.scheduled)
                        .toList(),
                  ),
                  _PostList(
                    posts: state.posts
                        .where((p) =>
                            p.status == PostStatus.posted ||
                            p.status == PostStatus.partial)
                        .toList(),
                  ),
                  _PostList(
                    posts: state.posts
                        .where((p) => p.status == PostStatus.failed)
                        .toList(),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList({required this.posts});
  final List<SocialPost> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 12),
              const Text('No posts here yet'),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PostListBloc>().add(const PostListReload());
        await Future<void>.delayed(const Duration(milliseconds: 300));
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 96),
        itemCount: posts.length,
        itemBuilder: (context, i) {
          final p = posts[i];
          final bloc = context.read<PostListBloc>();
          return PostCard(
            post: p,
            onTap: () => context.pushNamed(
              RouteNames.postDetail,
              pathParameters: {'id': p.id},
            ),
            onCopy: () => bloc.copyContent(context, p.content),
          );
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_document,
              size: 96,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'No posts yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Tap "New Post" to get started.'),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('New Post'),
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}