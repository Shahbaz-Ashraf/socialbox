import 'package:flutter/material.dart';

/// Scroll-safe bottom sheet shell — use for forms and lists on narrow screens.
Future<T?> showScrollableBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, ScrollController scrollController)
      builder,
  String? title,
  String? subtitle,
  Widget? headerActions,
  double initialChildSize = 0.55,
  double minChildSize = 0.35,
  double maxChildSize = 0.92,
  bool showDragHandle = true,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) {
      final theme = Theme.of(sheetCtx);
      final bottomInset = MediaQuery.viewInsetsOf(sheetCtx).bottom;

      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          builder: (context, scrollController) {
            return Column(
              children: [
                if (showDragHandle) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (headerActions != null) headerActions,
                      ],
                    ),
                  ),
                Expanded(child: builder(context, scrollController)),
              ],
            );
          },
        ),
      );
    },
  );
}

/// Simple scrollable list picker sheet.
Future<T?> showListBottomSheet<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<Widget> children,
  double initialChildSize = 0.45,
}) {
  return showScrollableBottomSheet<T>(
    context: context,
    title: title,
    subtitle: subtitle,
    initialChildSize: initialChildSize,
    builder: (_, scrollController) => ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: children,
    ),
  );
}