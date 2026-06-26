import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/theme/app_decorations.dart';

/// Shimmer placeholder matching the compact home layout.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: _bone(height: 20, width: 120),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _bone(height: 140, radius: 16),
                const SizedBox(height: 12),
                _bone(height: 18, width: 72),
                const SizedBox(height: 8),
                SizedBox(
                  height: 68,
                  child: Row(
                    children: List.generate(
                      4,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                          child: _bone(height: 68, radius: 14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _bone(height: 36, width: 96, radius: 20),
                    const SizedBox(width: 8),
                    _bone(height: 36, width: 96, radius: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 220,
                  decoration: AppDecorations.modernCard(context),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: List.generate(
                          3,
                          (i) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                              child: _bone(height: 28, radius: 8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(3, (_) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _bone(height: 44, radius: 10),
                          )),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bone({
    required double height,
    double? width,
    double radius = 8,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}