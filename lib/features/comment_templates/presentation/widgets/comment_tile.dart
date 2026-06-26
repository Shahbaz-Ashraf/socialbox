import 'package:flutter/material.dart';

import '../../domain/entities/comment_category.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.onCopy,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
    this.onSwipeDelete,
  });

  final Comment comment;
  final VoidCallback onCopy;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<Comment>? onSwipeDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(comment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Colors.redAccent.withValues(alpha: 0.9),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Delete',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async => onSwipeDelete != null,
      onDismissed: (_) => onSwipeDelete?.call(comment),
      child: Material(
        color: Theme.of(context).cardColor,
        child: InkWell(
          onTap: onCopy,
          onLongPress: () => _showContextMenu(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip:
                          comment.isFavorite ? 'Unfavorite' : 'Favorite',
                      icon: Icon(
                        comment.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: comment.isFavorite
                            ? Colors.redAccent
                            : Theme.of(context).hintColor,
                      ),
                      onPressed: onToggleFavorite,
                    ),
                    Expanded(
                      child: Text(
                        comment.text,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy',
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: onCopy,
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded),
                      onSelected: (v) {
                        switch (v) {
                          case 'edit':
                            onEdit();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                          case 'copy':
                            onCopy();
                            break;
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'copy', child: Text('Copy')),
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete',
                                style: TextStyle(color: Colors.redAccent))),
                      ],
                    ),
                  ],
                ),
                if (comment.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 56, right: 16),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: comment.tags
                          .map((t) => Chip(
                                label: Text('#$t',
                                    style: const TextStyle(fontSize: 11)),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withValues(alpha: 0.4),
                              ))
                          .toList(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 56, right: 16, top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.copy_rounded,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.usageCount} copies',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(box.size.center(Offset.zero), ancestor: overlay),
        box.localToGlobal(box.size.center(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final selected = await showMenu<String>(
      context: context,
      position: position,
      items: const [
        PopupMenuItem(value: 'copy', child: Text('Copy')),
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(
            value: 'delete',
            child: Text('Delete', style: TextStyle(color: Colors.redAccent))),
      ],
    );
    switch (selected) {
      case 'copy':
        onCopy();
        break;
      case 'edit':
        onEdit();
        break;
      case 'delete':
        onDelete();
        break;
    }
  }

}
