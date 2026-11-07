import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Menu « Plus » : modules secondaires selon le rôle + réglages du compte.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final perms = ref.watch(permsProvider);
    final profile = ref.watch(profileProvider).value;

    final entries = <(IconData, String, String)>[
      if (perms.canConfigure) (Icons.percent_rounded, l.commissionsTitle, '/commissions'),
      if (perms.canHandleComplaints) (Icons.report_gmailerrorred_outlined, l.complaintsTitle, '/complaints'),
      if (perms.canHandleComplaints) (Icons.reviews_outlined, l.reviewsModeration, '/reviews'),
      if (perms.canManageClients) (Icons.people_outline, l.clientsTitle, '/clients'),
      if (perms.canConfigure) (Icons.location_city_outlined, l.catalogTitle, '/catalog'),
      if (perms.canConfigure) (Icons.admin_panel_settings_outlined, l.teamTitle, '/team'),
      if (perms.canSendAnnouncements) (Icons.campaign_outlined, l.announcementsTitle, '/announcements'),
      if (perms.canConfigure) (Icons.fact_check_outlined, l.auditTitle, '/audit'),
      (Icons.notifications_outlined, l.notifications, '/notifications'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.more)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: UserAvatar(name: profile?.displayName ?? '', radius: 24),
              title: Text(profile?.displayName ?? '', style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Wrap(
                spacing: 6,
                children: [
                  Directionality(textDirection: TextDirection.ltr, child: Text(PhoneUtils.pretty(profile?.phone))),
                  if (profile?.adminRole != null) StatusBadge(label: l.adminRoleLabel(profile!.adminRole!), color: AppColors.primary, dense: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  ListTile(
                    leading: Icon(entries[i].$1),
                    title: Text(entries[i].$2),
                    trailing: const DirectionalChevron(),
                    onTap: () => context.push(entries[i].$3),
                  ),
                  if (i != entries.length - 1) const Divider(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AccountSettingsSection(),
        ],
      ),
    );
  }
}
