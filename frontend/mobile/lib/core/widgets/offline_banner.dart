import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connectivity/connectivity_service.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConnectivityProvider>().isOnline;
    if (online) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: cs.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: cs.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "You're offline — showing saved data.",
              style: TextStyle(color: cs.onErrorContainer, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
