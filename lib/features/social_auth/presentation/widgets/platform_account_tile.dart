import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/connected_account.dart';

class PlatformAccountTile extends StatelessWidget {
  const PlatformAccountTile({
    super.key,
    required this.platform,
    required this.account,
    required this.onConnect,
    required this.onDisconnect,
    this.onRefresh,
    this.isConnecting = false,
  });

  final SocialPlatform platform;
  final ConnectedAccount? account;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback? onRefresh;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    final connected = account?.isConnected == true;
    final narrow = MediaQuery.of(context).size.width < 400;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: platform.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(platform.icon, color: platform.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isConnecting
                      ? 'Opening browser…'
                      : (connected
                          ? (account!.displayName ??
                              account!.username ??
                              'Connected')
                          : 'Not connected'),
                  style: TextStyle(
                    color: isConnecting
                        ? Theme.of(context).colorScheme.primary
                        : (connected
                            ? Theme.of(context).hintColor
                            : Colors.grey),
                    fontSize: 12,
                    fontWeight:
                        isConnecting ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (connected && account!.expiresAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    account!.isExpired
                        ? 'Token expired — please reconnect'
                        : 'Expires ${AppDateUtils.formatRelative(account!.expiresAt!)}',
                    style: TextStyle(
                      color:
                          account!.isExpired ? Colors.redAccent : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isConnecting)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else if (connected)
            narrow
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onRefresh != null)
                        IconButton(
                          tooltip: 'Refresh token',
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: onRefresh,
                        ),
                      IconButton(
                        tooltip: 'Disconnect',
                        icon: const Icon(Icons.link_off_rounded),
                        onPressed: onDisconnect,
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onRefresh != null)
                        IconButton(
                          tooltip: 'Refresh token',
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: onRefresh,
                        ),
                      FilledButton.tonal(
                        onPressed: onDisconnect,
                        child: const Text('Disconnect'),
                      ),
                    ],
                  )
          else
            narrow
                ? IconButton(
                    tooltip: 'Connect',
                    icon: const Icon(Icons.link_rounded),
                    onPressed: onConnect,
                  )
                : FilledButton(
                    onPressed: onConnect,
                    child: const Text('Connect'),
                  ),
        ],
      ),
    );
  }
}