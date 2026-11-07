import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';
import 'request_actions.dart';

class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final requests = ref.watch(incomingRequestsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.requestDetails)),
      body: AsyncValueView<List<IncomingRequest>>(
        value: requests,
        onRetry: () => ref.invalidate(incomingRequestsProvider),
        data: (list) {
          final request = list.where((r) => r.bookingId == bookingId).firstOrNull;
          if (request == null) {
            return EmptyView(
              icon: Icons.event_busy_outlined,
              title: l.requestGone,
              action: SizedBox(width: 200, child: SecondaryButton(label: l.back, onPressed: () => context.go('/home'))),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              IncomingRequestCard(request: request, detailed: true),
              if (request.channel != BookingChannel.app) ...[
                const SizedBox(height: 12),
                InfoBanner(icon: Icons.groups_2_outlined, message: l.firstAcceptWins),
              ],
            ],
          );
        },
      ),
    );
  }
}
