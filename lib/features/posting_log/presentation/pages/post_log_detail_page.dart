import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../domain/repositories/log_repository.dart';
import '../cubit/log_cubit.dart';
import '../widgets/log_filter_bar.dart';
import '../widgets/log_tile.dart';

class PostLogDetailPage extends StatelessWidget {
  const PostLogDetailPage({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LogCubit(repository: getIt<LogRepository>())..loadForPost(postId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Post Logs')),
        body: Column(
          children: [
            const LogFilterBar(),
            Expanded(
              child: BlocBuilder<LogCubit, LogState>(
                builder: (context, state) {
                  if (state is LogLoaded) {
                    final logs = state.visible;
                    if (logs.isEmpty) {
                      return const Center(child: Text('No log entries yet'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: logs.length,
                      itemBuilder: (_, i) => LogTile(log: logs[i]),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
