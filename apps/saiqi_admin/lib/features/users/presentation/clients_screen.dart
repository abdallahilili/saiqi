import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../drivers/presentation/driver_detail_screen.dart' show resetPasswordFlow;

final _clientsProvider = FutureProvider.autoDispose<List<ProfileSummary>>(
  (ref) => ref.watch(adminRepositoryProvider).listProfiles(UserRole.client),
);

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final clients = ref.watch(_clientsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.clientsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(hintText: l.searchPeople, prefixIcon: const Icon(Icons.search)),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(_clientsProvider),
              child: AsyncValueView<List<ProfileSummary>>(
                value: clients,
                onRetry: () => ref.invalidate(_clientsProvider),
                data: (all) {
                  final list = _query.isEmpty ? all : all.where((p) => p.displayName.toLowerCase().contains(_query) || p.phone.contains(_query)).toList();
                  if (list.isEmpty) return EmptyView(icon: Icons.people_outline, title: l.noClients);
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final p = list[i];
                      return Card(
                        child: ListTile(
                          leading: UserAvatar(name: p.displayName),
                          title: Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Directionality(textDirection: TextDirection.ltr, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(PhoneUtils.pretty(p.phone)))),
                          trailing: AccountStatusBadge(p.status),
                          onTap: () => showUserActions(context, ref, p, onChanged: () => ref.invalidate(_clientsProvider)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Actions admin sur un compte : suspendre, bloquer, réactiver, réinitialiser le mot de passe, avertir.
Future<void> showUserActions(BuildContext context, WidgetRef ref, ProfileSummary p, {required VoidCallback onChanged}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (sheetContext) {
      final l = sheetContext.l10n;
      final repo = ref.read(adminRepositoryProvider);

      Future<void> setStatus(AccountStatus s) async {
        Navigator.of(sheetContext).pop();
        String? reason;
        if (s != AccountStatus.active) {
          reason = await promptTextDialog(context, title: l.reason, hint: l.reasonHint);
          if (reason == null || !context.mounted) return;
        }
        final ok = await runAction(context, () => repo.setAccountStatus(p.id, s, reason: reason), successMessage: l.accountStatusChanged);
        if (ok) onChanged();
      }

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                UserAvatar(name: p.displayName, radius: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.displayName, style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      AccountStatusBadge(p.status),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              ContactActions(phone: p.phone),
              const Divider(height: 28),
              if (p.status == AccountStatus.active) ...[
                SecondaryButton(label: l.suspendAccount, icon: Icons.pause_circle_outline, onPressed: () => setStatus(AccountStatus.suspended)),
                const SizedBox(height: 10),
                DangerButton(label: l.blockAccount, icon: Icons.block_rounded, onPressed: () => setStatus(AccountStatus.blocked)),
              ] else
                PrimaryButton(label: l.reactivateAccount, icon: Icons.lock_open_rounded, onPressed: () => setStatus(AccountStatus.active)),
              const SizedBox(height: 10),
              SecondaryButton(
                label: l.warnUser,
                icon: Icons.campaign_outlined,
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  final msg = await promptTextDialog(context, title: l.warnUser, hint: l.warnMessageHint);
                  if (msg == null || !context.mounted) return;
                  await runAction(context, () => repo.warnUser(p.id, msg), successMessage: l.warnSentMsg);
                },
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: l.resetPassword,
                icon: Icons.lock_reset_outlined,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  resetPasswordFlow(context, ref, p.id);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
