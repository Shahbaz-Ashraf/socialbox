import 'package:flutter/material.dart';

import '../../../../core/utils/extensions.dart';
import '../../domain/entities/comment_category.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.commentCount,
  });

  final CommentCategory category;
  final VoidCallback onTap;
  final int? commentCount;

  @override
  Widget build(BuildContext context) {
    final color = ColorFromHex.fromHex(category.colorHex);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.18),
                color.withValues(alpha: 0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(category.icon,
                        style: const TextStyle(fontSize: 24)),
                  ),
                  const Spacer(),
                  if (category.isPredefined)
                    const Icon(Icons.lock_outline_rounded,
                        size: 16, color: Colors.grey),
                ],
              ),
              const Spacer(),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    commentCount != null
                        ? '$commentCount comment${commentCount == 1 ? '' : 's'}'
                        : '—',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
