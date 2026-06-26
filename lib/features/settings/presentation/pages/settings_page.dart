import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/form_section_card.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/scrollable_bottom_sheet.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/theme_mode_picker.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsView();
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              FormSectionCard(
                title: 'Appearance',
                child: ThemeModePicker(
                  current: settings.themeMode,
                  onChanged: (v) => cubit.update(settings.copyWith(themeMode: v)),
                ),
              ),
              const SizedBox(height: 12),
              const FormSectionCard(
                title: 'Defaults',
                child: _DefaultPlatformsTile(),
              ),
              const SizedBox(height: 12),
              FormSectionCard(
                title: 'Notifications',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable notifications'),
                      subtitle: const Text('Reminder and posting result alerts'),
                      value: settings.enableNotifications,
                      onChanged: (v) =>
                          cubit.update(settings.copyWith(enableNotifications: v)),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Reminder lead time'),
                      subtitle: Slider(
                        value: settings.reminderLeadMinutes.toDouble(),
                        min: 0,
                        max: 60,
                        divisions: 12,
                        label: '${settings.reminderLeadMinutes} min',
                        onChanged: (v) => cubit.update(
                          settings.copyWith(reminderLeadMinutes: v.toInt()),
                        ),
                      ),
                      trailing: Text('${settings.reminderLeadMinutes}m'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const FormSectionCard(
                title: 'OAuth credentials',
                child: _OAuthCredentialsSection(),
              ),
              const SizedBox(height: 12),
              FormSectionCard(
                title: 'Social posting',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable API posting'),
                      subtitle: const Text('Auto-publish via OAuth when scheduled'),
                      value: settings.enableApiPosting,
                      onChanged: (v) =>
                          cubit.update(settings.copyWith(enableApiPosting: v)),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto-refresh tokens'),
                      subtitle: const Text('Refresh OAuth tokens automatically'),
                      value: settings.autoRefreshTokens,
                      onChanged: (v) =>
                          cubit.update(settings.copyWith(autoRefreshTokens: v)),
                    ),
                    _SettingsNavTile(
                      icon: Icons.link_rounded,
                      title: 'Connected accounts',
                      onTap: () => context.pushNamed(RouteNames.socialAccounts),
                    ),
                    _SettingsNavTile(
                      icon: Icons.notifications_active_rounded,
                      title: 'Reminders',
                      onTap: () => context.pushNamed(RouteNames.reminders),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FormSectionCard(
                title: 'AI writing',
                child: Column(
                  children: [
                    _SettingsNavTile(
                      icon: Icons.auto_awesome_rounded,
                      title: 'AI Post Writer',
                      subtitle:
                          'Configure prompts, copy to clipboard for ChatGPT, Gemini & more',
                      onTap: () => context.pushNamed(RouteNames.aiPromptStudio),
                    ),
                    _SettingsNavTile(
                      icon: Icons.history_rounded,
                      title: 'Posting log',
                      subtitle: 'Global history of all platform posts',
                      onTap: () => context.pushNamed(RouteNames.logs),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FormSectionCard(
                title: 'Data',
                child: Column(
                  children: [
                    _SettingsNavTile(
                      icon: Icons.download_rounded,
                      title: 'Export comments as CSV',
                      subtitle: 'Share or copy to clipboard',
                      onTap: () => _exportCsv(context),
                    ),
                    _SettingsNavTile(
                      icon: Icons.upload_rounded,
                      title: 'Open quick share dialog',
                      onTap: () => Share.share(
                        'Check out SocialBox — my social media organizer!',
                        subject: 'SocialBox',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FormSectionCard(
                title: 'About',
                child: Column(
                  children: [
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.info_outline_rounded),
                      title: Text('SocialBox'),
                      subtitle: Text('Version 1.0.0  ·  Linkedif'),
                    ),
                    _SettingsNavTile(
                      icon: Icons.code_rounded,
                      title: 'View developer site',
                      trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                      onTap: () => launchUrl(Uri.parse('https://linkedif.com')),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final action = await showScrollableBottomSheet<String>(
      context: context,
      title: 'Export comments',
      subtitle: 'Choose how to share your comment library',
      initialChildSize: 0.32,
      minChildSize: 0.25,
      builder: (_, __) => ListView(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        children: [
          ListTile(
            leading: const Icon(Icons.share_rounded),
            title: const Text('Share CSV'),
            onTap: () => Navigator.pop(context, 'share'),
          ),
          ListTile(
            leading: const Icon(Icons.content_copy_rounded),
            title: const Text('Copy to clipboard'),
            onTap: () => Navigator.pop(context, 'copy'),
          ),
        ],
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
      await cubit.copyExportToClipboard(context);
    }
  }
}

class _SettingsNavTile extends StatelessWidget {
  const _SettingsNavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _DefaultPlatformsTile extends StatelessWidget {
  const _DefaultPlatformsTile();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, settings) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Default platforms'),
          subtitle: Text(
            settings.defaultPlatforms.isEmpty
                ? 'None selected — every post will start empty'
                : settings.defaultPlatforms.map((p) => p.displayName).join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            final selected = List<SocialPlatform>.from(settings.defaultPlatforms);
            await showScrollableBottomSheet<void>(
              context: context,
              title: 'Default platforms',
              subtitle: 'Pre-selected when creating a new post',
              initialChildSize: 0.5,
              builder: (sheetCtx, scrollController) {
                return StatefulBuilder(
                  builder: (sheetCtx, setSheet) {
                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      children: [
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
                          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                context.read<SettingsCubit>().update(
                                      settings.copyWith(
                                        defaultPlatforms: selected,
                                      ),
                                    );
                                Navigator.pop(sheetCtx);
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _OAuthCredentialsSection extends StatefulWidget {
  const _OAuthCredentialsSection();

  @override
  State<_OAuthCredentialsSection> createState() =>
      _OAuthCredentialsSectionState();
}

class _OAuthCredentialsSectionState extends State<_OAuthCredentialsSection> {
  final _fbAppId = TextEditingController();
  final _fbAppSecret = TextEditingController();
  final _liClientId = TextEditingController();
  final _liClientSecret = TextEditingController();
  final _twClientId = TextEditingController();
  final _twClientSecret = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _fbAppId.dispose();
    _fbAppSecret.dispose();
    _liClientId.dispose();
    _liClientSecret.dispose();
    _twClientId.dispose();
    _twClientSecret.dispose();
    super.dispose();
  }

  void _initFromSettings(AppSettings settings) {
    if (_initialized) return;
    _fbAppId.text = settings.fbAppId ?? '';
    _fbAppSecret.text = settings.fbAppSecret ?? '';
    _liClientId.text = settings.liClientId ?? '';
    _liClientSecret.text = settings.liClientSecret ?? '';
    _twClientId.text = settings.twClientId ?? '';
    _twClientSecret.text = settings.twClientSecret ?? '';
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, settings) {
        _initFromSettings(settings);
        final cubit = context.read<SettingsCubit>();

        String? emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store app credentials from each platform developer portal. '
              'Used when connecting accounts.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _CredentialGroup(
              label: 'Facebook',
              children: [
                TextField(
                  controller: _fbAppId,
                  decoration: const InputDecoration(
                    labelText: 'Facebook App ID',
                    isDense: true,
                  ),
                  onSubmitted: (v) => cubit.update(
                    settings.copyWith(fbAppId: emptyToNull(v)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _fbAppSecret,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Facebook App Secret',
                    isDense: true,
                  ),
                  onSubmitted: (v) => cubit.update(
                    settings.copyWith(fbAppSecret: emptyToNull(v)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CredentialGroup(
              label: 'LinkedIn',
              children: [
                TextField(
                  controller: _liClientId,
                  decoration: const InputDecoration(
                    labelText: 'LinkedIn Client ID',
                    isDense: true,
                  ),
                  onSubmitted: (v) => cubit.update(
                    settings.copyWith(liClientId: emptyToNull(v)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _liClientSecret,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'LinkedIn Client Secret',
                    isDense: true,
                  ),
                  onSubmitted: (v) => cubit.update(
                    settings.copyWith(liClientSecret: emptyToNull(v)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CredentialGroup(
              label: 'Twitter / X',
              children: [
                TextField(
                  controller: _twClientId,
                  decoration: const InputDecoration(
                    labelText: 'Twitter Client ID',
                    isDense: true,
                  ),
                  onSubmitted: (v) => cubit.update(
                    settings.copyWith(twClientId: emptyToNull(v)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _twClientSecret,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Twitter Client Secret (optional)',
                    isDense: true,
                  ),
                  onSubmitted: (v) => cubit.update(
                    settings.copyWith(twClientSecret: emptyToNull(v)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CredentialGroup extends StatelessWidget {
  const _CredentialGroup({
    required this.label,
    required this.children,
  });

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.sectionHeader(context)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}