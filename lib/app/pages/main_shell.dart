import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    (path: '/dashboard', icon: Icons.home_rounded, label: 'Home'),
    (path: '/calendar', icon: Icons.calendar_today_rounded, label: 'Calendar'),
    (path: '/comments', icon: Icons.chat_bubble_outline_rounded, label: 'Comments'),
    (path: '/posts', icon: Icons.send_rounded, label: 'Posts'),
    (path: '/settings', icon: Icons.settings_rounded, label: 'Settings'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/ai-writer')) return 0;
    for (var i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path) return i;
      if (i > 0 && location.startsWith('${_tabs[i].path}/')) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final tokens = Theme.of(context).extension<AppThemeTokens>() ??
        AppThemeTokens.light();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.navBarBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? tokens.accentBorder
                  : tokens.accentBorder.withValues(alpha: 0.8),
            ),
            boxShadow: tokens.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: NavigationBar(
              selectedIndex: currentIndex,
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 64,
              surfaceTintColor: Colors.transparent,
              indicatorColor: Theme.of(context).colorScheme.primary.withValues(
                    alpha: isDark ? 0.22 : 0.12,
                  ),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (i) => context.go(_tabs[i].path),
              destinations: _tabs
                  .map(
                    (t) => NavigationDestination(
                      icon: Icon(t.icon),
                      selectedIcon: Icon(t.icon, fill: 1.0),
                      label: t.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}