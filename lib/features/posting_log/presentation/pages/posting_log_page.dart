import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../domain/repositories/log_repository.dart';
import '../cubit/log_cubit.dart';
import '../widgets/log_filter_bar.dart';
import '../widgets/log_tile.dart';

class PostingLogPage extends StatelessWidget {
  const PostingLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LogCubit(repository: getIt<LogRepository>()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Posting Log')),
        body: Column(
          children: [
            const LogFilterBar(),
            Expanded(
              child: BlocBuilder<LogCubit, LogState>(
                builder: (context, state) {
                  if (state is LogLoading || state is LogInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is LogLoaded) {
                    final visible = state.visible;
                    if (visible.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history_rounded,
                                size: 96,
                                color: Theme.of(context).hintColor),
                            const SizedBox(height: 12),
                            const Text('No log entries yet'),
                            const SizedBox(height: 6),
                            const Text(
                                'Logs appear here after you mark a post as posted.'),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: visible.length,
                      itemBuilder: (_, i) => LogTile(log: visible[i]),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
