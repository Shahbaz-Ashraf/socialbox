import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/platform_utils.dart';
import '../cubit/log_cubit.dart';

class LogFilterBar extends StatelessWidget {
  const LogFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogCubit, LogState>(
      builder: (context, state) {
        if (state is! LogLoaded) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All platforms'),
                      selected: state.filterPlatform == null,
                      onSelected: (_) =>
                          context.read<LogCubit>().filterByPlatform(null),
                    ),
                    const SizedBox(width: 6),
                    ...SocialPlatform.values.map((p) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            avatar: Icon(p.icon,
                                size: 14,
                                color: state.filterPlatform == p
                                    ? Colors.white
                                    : p.color),
                            label: Text(p.displayName),
                            selected: state.filterPlatform == p,
                            selectedColor: p.color,
                            labelStyle: TextStyle(
                              color: state.filterPlatform == p
                                  ? Colors.white
                                  : p.color,
                              fontWeight: FontWeight.w600,
                            ),
                            checkmarkColor: Colors.white,
                            onSelected: (sel) => context
                                .read<LogCubit>()
                                .filterByPlatform(sel ? p : null),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All statuses'),
                      selected: state.filterStatus == null,
                      onSelected: (_) =>
                          context.read<LogCubit>().filterByStatus(null),
                    ),
                    const SizedBox(width: 6),
                    ...LogStatus.values.map((st) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            avatar: Icon(st.icon,
                                size: 14,
                                color: state.filterStatus == st
                                    ? Colors.white
                                    : st.color),
                            label: Text(st.label),
                            selected: state.filterStatus == st,
                            selectedColor: st.color,
                            labelStyle: TextStyle(
                              color: state.filterStatus == st
                                  ? Colors.white
                                  : st.color,
                              fontWeight: FontWeight.w600,
                            ),
                            checkmarkColor: Colors.white,
                            onSelected: (sel) => context
                                .read<LogCubit>()
                                .filterByStatus(sel ? st : null),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
