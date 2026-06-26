import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/scrollable_bottom_sheet.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/connected_account.dart';
import '../../domain/entities/facebook_page.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/platform_account_tile.dart';

class SocialAccountsPage extends StatelessWidget {
  const SocialAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthLoadAccounts()),
      child: const _AccountsView(),
    );
  }
}

class _AccountsView extends StatelessWidget {
  const _AccountsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connected Accounts')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (a, b) =>
            b is AuthConnected ||
            b is AuthFailureState ||
            b is AuthFacebookPagePicker,
        listener: (context, state) {
          if (state is AuthFacebookPagePicker) {
            _showFacebookPagePicker(context, state.pages);
          } else if (state is AuthConnected) {
            AppSnackbar.success(
              context,
              'Connected to ${state.account.platform.displayName}',
            );
          } else if (state is AuthFailureState) {
            AppSnackbar.error(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AuthError) {
            return Center(child: Text(state.message));
          }
          final accounts = _accountsFromState(state);
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Connect your social media accounts to enable auto-posting via the platform APIs. '
                  'Credentials are stored securely on this device.',
                ),
              ),
              ...SocialPlatform.values.map((p) {
                final account = accounts[p];
                final isConnecting =
                    state is AuthConnecting && state.platform == p;
                return PlatformAccountTile(
                  platform: p,
                  account: account,
                  isConnecting: isConnecting,
                  onConnect: () => _connect(context, p),
                  onDisconnect: () => _confirmDisconnect(context, p),
                  onRefresh: account?.isConnected == true
                      ? () => _refreshToken(context, p)
                      : null,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Map<SocialPlatform, ConnectedAccount> _accountsFromState(AuthState s) {
    final list = switch (s) {
      AuthLoaded(:final accounts) => accounts,
      AuthConnected(:final allAccounts) => allAccounts,
      AuthFailureState(:final allAccounts) => allAccounts,
      AuthFacebookPagePicker(:final allAccounts) => allAccounts,
      _ => const <ConnectedAccount>[],
    };
    return {for (final a in list) a.platform: a};
  }

  Future<void> _showFacebookPagePicker(
    BuildContext context,
    List<FacebookPage> pages,
  ) async {
    final selected = await showScrollableBottomSheet<FacebookPage>(
      context: context,
      title: 'Select a Facebook Page',
      subtitle: 'Choose which page SocialBox should use for posting.',
      initialChildSize: 0.5,
      builder: (sheetCtx, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        children: pages
            .map(
              (page) => ListTile(
                leading: const Icon(Icons.facebook_rounded),
                title: Text(page.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('Page ID: ${page.id}'),
                onTap: () => Navigator.pop(sheetCtx, page),
              ),
            )
            .toList(),
      ),
    );
    if (selected == null || !context.mounted) return;
    context.read<AuthBloc>().add(AuthSelectFacebookPage(selected));
  }

  Future<void> _connect(BuildContext context, SocialPlatform platform) async {
    final authBloc = context.read<AuthBloc>();
    final clientIdCtrl = TextEditingController(
      text: await authBloc.getClientId(platform) ?? '',
    );
    final clientSecretCtrl = TextEditingController(
      text: await authBloc.getClientSecret(platform) ?? '',
    );
    if (!context.mounted) return;

    final credentials = await showDialog<_OAuthCredentials>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Connect ${platform.displayName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your app credentials from the developer portal:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: clientIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Client ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              if (platform != SocialPlatform.twitter)
                TextField(
                  controller: clientSecretCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Client Secret',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                _helpFor(platform),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (clientIdCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client ID required')),
                );
                return;
              }
              Navigator.pop(
                context,
                _OAuthCredentials(
                  clientId: clientIdCtrl.text.trim(),
                  clientSecret: clientSecretCtrl.text.trim().isEmpty
                      ? null
                      : clientSecretCtrl.text.trim(),
                ),
              );
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    if (credentials == null) return;

    if (!context.mounted) return;
    await authBloc.saveCredentials(
      platform,
      clientId: credentials.clientId,
      clientSecret: credentials.clientSecret,
    );
    if (!context.mounted) return;
    context.read<AuthBloc>().add(
          AuthConnect(
            platform: platform,
            clientId: credentials.clientId,
            clientSecret: credentials.clientSecret,
          ),
        );
  }

  Future<void> _refreshToken(
      BuildContext context, SocialPlatform platform) async {
    final ok = await context.read<AuthBloc>().refresh(platform);
    if (!context.mounted) return;
    if (ok) {
      AppSnackbar.success(
        context,
        'Token refreshed for ${platform.displayName}',
      );
    } else {
      AppSnackbar.error(
        context,
        'Could not refresh token for ${platform.displayName}',
      );
    }
  }

  String _helpFor(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.twitter:
        return 'Twitter/X uses PKCE — only the Client ID is required. '
            'The browser will open for sign-in, then return here automatically.';
      case SocialPlatform.linkedin:
        return 'Create a LinkedIn app at linkedin.com/developers, add the '
            'redirect URL com.linkedif.socialbox://oauth/linkedin, and enable '
            'the "Sign In with LinkedIn" and "Share on LinkedIn" products.';
      case SocialPlatform.facebook:
        return 'Create a Facebook app at developers.facebook.com, add a '
            'Facebook Login product, and add the redirect URL '
            'com.linkedif.socialbox://oauth/facebook to Valid OAuth Redirect URIs.';
    }
  }

  Future<void> _confirmDisconnect(
      BuildContext context, SocialPlatform platform) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Disconnect ${platform.displayName}?'),
        content: const Text(
          'Your stored OAuth credentials will be removed. You can reconnect anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<AuthBloc>().add(AuthDisconnect(platform));
    if (context.mounted) {
      AppSnackbar.info(context, 'Disconnected from ${platform.displayName}');
    }
  }
}

class _OAuthCredentials {
  const _OAuthCredentials({required this.clientId, this.clientSecret});
  final String clientId;
  final String? clientSecret;
}