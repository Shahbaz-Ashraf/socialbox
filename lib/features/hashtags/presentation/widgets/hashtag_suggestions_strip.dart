import 'package:flutter/material.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/hashtag_repository.dart';

/// Horizontal strip of recent hashtag suggestions above the tag input.
/// Tapping a suggestion adds it to the form.
class HashtagSuggestionsStrip extends StatelessWidget {
  const HashtagSuggestionsStrip({
    super.key,
    required this.existing,
    required this.onAdd,
  });

  final List<String> existing;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final repo = getIt<HashtagRepository>();
    return StreamBuilder(
      stream: repo.watchSuggestions(const HashtagFilter(limit: 12)),
      builder: (context, snap) {
        final tags = (snap.data ?? const [])
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
                    return ActionChip(
                      avatar: Icon(
                        SocialPlatform.twitter.icon,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text('#$tag'),
                      onPressed: () => onAdd(tag),
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
