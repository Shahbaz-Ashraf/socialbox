import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/log_tile.dart';
import '../../../../injection_container.dart';
import '../cubit/log_cubit.dart';
import '../widgets/log_filter_bar.dart';

class PostLogDetailPage extends StatelessWidget {
  const PostLogDetailPage({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LogCubit>()..loadForPost(postId),
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
                      itemBuilder: (context, i) {
                        final log = logs[i];
                        return LogTile(
                          log: log,
                          onCopyUrl: context.read<LogCubit>().copyExternalUrl,
                          onStatusChanged: (status) async {
                            final ok = await context
                                .read<LogCubit>()
                                .changeStatus(log.id, status);
                            if (!context.mounted) return;
                            if (ok) {
                              AppSnackbar.success(
                                context,
                                'Status updated to ${status.label}',
                              );
                            } else {
                              AppSnackbar.error(
                                context,
                                'Could not update status',
                              );
                            }
                          },
                        );
                      },
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
