import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          context.go(_tabs[i].path);
        },
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.icon, fill: 1.0),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
