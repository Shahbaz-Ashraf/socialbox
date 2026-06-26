import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/services/clipboard_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();
          return ListView(
            children: [
              const _SectionTitle('Appearance'),
              _ThemeModeTile(
                label: 'System default',
                icon: Icons.brightness_auto_rounded,
                value: ThemeMode.system,
                current: settings.themeMode,
                onSelect: (v) => cubit.update(settings.copyWith(themeMode: v)),
              ),
              _ThemeModeTile(
                label: 'Light',
                icon: Icons.light_mode_rounded,
                value: ThemeMode.light,
                current: settings.themeMode,
                onSelect: (v) => cubit.update(settings.copyWith(themeMode: v)),
              ),
              _ThemeModeTile(
                label: 'Dark',
                icon: Icons.dark_mode_rounded,
                value: ThemeMode.dark,
                current: settings.themeMode,
                onSelect: (v) => cubit.update(settings.copyWith(themeMode: v)),
              ),
              const Divider(),
              const _SectionTitle('Defaults'),
              const _DefaultPlatformsTile(),
              const Divider(),
              const _SectionTitle('Notifications'),
              SwitchListTile(
                title: const Text('Enable notifications'),
                subtitle: const Text('Reminder and posting result alerts'),
                value: settings.enableNotifications,
                onChanged: (v) =>
                    cubit.update(settings.copyWith(enableNotifications: v)),
              ),
              ListTile(
                title: const Text('Reminder lead time'),
                subtitle: Slider(
                  value: settings.reminderLeadMinutes.toDouble(),
                  min: 0,
                  max: 60,
                  divisions: 12,
                  label: '${settings.reminderLeadMinutes} min',
                  onChanged: (v) =>
                      cubit.update(settings.copyWith(reminderLeadMinutes: v.toInt())),
                ),
                trailing: Text('${settings.reminderLeadMinutes}m'),
              ),
              const Divider(),
              const _SectionTitle('Social Posting'),
              SwitchListTile(
                title: const Text('Enable API posting'),
                subtitle: const Text('Auto-publish via OAuth when scheduled'),
                value: settings.enableApiPosting,
                onChanged: (v) =>
                    cubit.update(settings.copyWith(enableApiPosting: v)),
              ),
              SwitchListTile(
                title: const Text('Auto-refresh tokens'),
                subtitle: const Text('Refresh OAuth tokens automatically'),
                value: settings.autoRefreshTokens,
                onChanged: (v) =>
                    cubit.update(settings.copyWith(autoRefreshTokens: v)),
              ),
              ListTile(
                leading: const Icon(Icons.link_rounded),
                title: const Text('Connected accounts'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.pushNamed(RouteNames.socialAccounts),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active_rounded),
                title: const Text('Reminders'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.pushNamed(RouteNames.reminders),
              ),
              const Divider(),
              const _SectionTitle('AI Writing'),
              ListTile(
                leading: const Icon(Icons.auto_awesome_rounded),
                title: const Text('AI Post Writer'),
                subtitle: const Text(
                    'Configure prompts, copy to clipboard for ChatGPT, Gemini & more'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.pushNamed(RouteNames.aiPromptStudio),
              ),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: const Text('Posting log'),
                subtitle: const Text('Global history of all platform posts'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.pushNamed(RouteNames.logs),
              ),
              const Divider(),
              const _SectionTitle('Data'),
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('Export comments as CSV'),
                subtitle: const Text('Share or copy to clipboard'),
                onTap: () => _exportCsv(context),
              ),
              ListTile(
                leading: const Icon(Icons.upload_rounded),
                title: const Text('Open quick share dialog'),
                onTap: () => Share.share(
                  'Check out SocialBox — my social media organizer!',
                  subject: 'SocialBox',
                ),
              ),
              const Divider(),
              const _SectionTitle('About'),
              const ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text('SocialBox'),
                subtitle: Text('Version 1.0.0  •  Linkedif'),
              ),
              ListTile(
                leading: const Icon(Icons.code_rounded),
                title: const Text('View developer site'),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () => launchUrl(Uri.parse('https://linkedif.com')),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share CSV'),
              onTap: () => Navigator.pop(ctx, 'share'),
            ),
            ListTile(
              leading: const Icon(Icons.content_copy_rounded),
              title: const Text('Copy to clipboard'),
              onTap: () => Navigator.pop(ctx, 'copy'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    if (action == 'share') {
      final ok = await cubit.exportCommentsToShare();
      if (context.mounted && ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export ready — share or save the CSV')),
        );
      }
    } else if (action == 'copy') {
      final csv = await cubit.exportCommentsToClipboard();
      if (csv != null && context.mounted) {
        await getIt<ClipboardService>().copyText(context, csv);
      }
    }
  }
}

class _DefaultPlatformsTile extends StatelessWidget {
  const _DefaultPlatformsTile();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, settings) {
        return ListTile(
          title: const Text('Default platforms'),
          subtitle: Text(settings.defaultPlatforms.isEmpty
              ? 'None selected — every post will start empty'
              : settings.defaultPlatforms.map((p) => p.displayName).join(', ')),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            final selected = List<SocialPlatform>.from(settings.defaultPlatforms);
            await showModalBottomSheet(
              context: context,
              builder: (sheetCtx) {
                return StatefulBuilder(builder: (sheetCtx, setSheet) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Default platforms for new posts',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ),
                        ...SocialPlatform.values.map((p) {
                          final isSel = selected.contains(p);
                          return CheckboxListTile(
                            title: Text(p.displayName),
                            value: isSel,
                            onChanged: (v) => setSheet(() {
                              if (v == true) {
                                if (!selected.contains(p)) selected.add(p);
                              } else {
                                selected.remove(p);
                              }
                            }),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                context
                                    .read<SettingsCubit>()
                                    .update(settings.copyWith(
                                        defaultPlatforms: selected));
                                Navigator.pop(sheetCtx);
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              },
            );
          },
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          )),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.current,
    required this.onSelect,
  });

  final String label;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode current;
  final ValueChanged<ThemeMode> onSelect;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == current;
    return ListTile(
      leading: Icon(icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).hintColor),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () => onSelect(value),
    );
  }
}
