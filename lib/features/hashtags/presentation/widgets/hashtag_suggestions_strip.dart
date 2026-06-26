import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/platform_utils.dart';
import '../cubit/hashtag_suggestions_cubit.dart';

/// Horizontal strip of recent hashtag suggestions above the tag input.
/// Tapping a suggestion adds it to the form.
class HashtagSuggestionsStrip extends StatelessWidget {
  const HashtagSuggestionsStrip({
    super.key,
    required this.existing,
    required this.onAdd,
    this.onCopy,
  });

  final List<String> existing;
  final ValueChanged<String> onAdd;
  final ValueChanged<String>? onCopy;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HashtagSuggestionsCubit, HashtagSuggestionsState>(
      builder: (context, state) {
        if (state.isLoading) return const SizedBox.shrink();

        final tags = state.suggestions
            .map((s) => s.tag)
            .where((t) => !existing.contains(t))
            .toList();
        if (tags.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text(
                  'Suggested',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: tags.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final tag = tags[i];
                    return GestureDetector(
                      onLongPress: onCopy == null ? null : () => onCopy!(tag),
                      child: ActionChip(
                        avatar: Icon(
                          SocialPlatform.twitter.icon,
                          size: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text('#$tag'),
                        tooltip: onCopy == null
                            ? 'Add #$tag'
                            : 'Tap to add · long-press to copy',
                        onPressed: () => onAdd(tag),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}