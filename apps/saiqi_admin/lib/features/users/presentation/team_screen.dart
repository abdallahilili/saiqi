import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import 'clients_screen.dart' show showUserActions;

final _teamProvider = FutureProvider.autoDispose<List<ProfileSummary>>(
  (ref) => ref.watch(adminRepositoryProvider).listProfiles(UserRole.admin),
);

/// Équipe admin : création de comptes avec rôle (super_admin, validator, support).
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final team = ref.watch(_teamProvider);
    final me = ref.watch(profileProvider).value?.id;
    return Scaffold(
      appBar: AppBar(title: Text(l.teamTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => _AddMemberSheet(onCreated: () => ref.invalidate(_teamProvider)),
        ),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: Text(l.addMember),
      ),
      body: AsyncValueView<List<ProfileSummary>>(
        value: team,
        onRetry: () => ref.invalidate(_teamProvider),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final p = list[i];
            final isMe = p.id == me;
            return Card(
              child: ListTile(
                leading: UserAvatar(name: p.displayName),
                title: Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Directionality(textDirection: TextDirection.ltr, child: Text(PhoneUtils.pretty(p.phone))),
                    const SizedBox(height: 4),
                    Wrap(spacing: 6, children: [
                      if (p.adminRole != null) StatusBadge(label: l.adminRoleLabel(p.adminRole!), color: AppColors.primary, icon: Icons.shield_outlined, dense: true),
                      AccountStatusBadge(p.status),
                    ]),
                  ],
                ),
                isThreeLine: true,
                trailing: isMe ? null : const Icon(Icons.more_vert),
                onTap: isMe ? null : () => _memberActions(context, ref, p),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _memberActions(BuildContext context, WidgetRef ref, ProfileSummary p) async {
    final l = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded),
              title: Text(l.changeRole),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final role = await showDialog<AdminRole>(
                  context: context,
                  builder: (ctx) => SimpleDialog(
                    title: Text(l.changeRole),
                    children: [
                      for (final r in AdminRole.values)
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, r),
                          child: ListTile(
                            leading: Icon(r == p.adminRole ? Icons.radio_button_checked : Icons.radio_button_off),
                            title: Text(l.adminRoleLabel(r)),
                            subtitle: Text(_roleDesc(l, r)),
                          ),
                        ),
                    ],
                  ),
                );
                if (role == null || role == p.adminRole || !context.mounted) return;
                final ok = await runAction(context, () => ref.read(adminRepositoryProvider).setAdminRole(p.id, role), successMessage: l.roleChanged);
                if (ok) ref.invalidate(_teamProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: Text(l.accountActions),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showUserActions(context, ref, p, onChanged: () => ref.invalidate(_teamProvider));
              },
            ),
          ],
        ),
      ),
    );
  }
}

String _roleDesc(AppLocalizations l, AdminRole r) => switch (r) {
      AdminRole.superAdmin => l.roleSuperAdminDesc,
      AdminRole.validator => l.roleValidatorDesc,
      AdminRole.support => l.roleSupportDesc,
    };

class _AddMemberSheet extends ConsumerStatefulWidget {
  const _AddMemberSheet({required this.onCreated});
  final VoidCallback onCreated;

  @override
  ConsumerState<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<_AddMemberSheet> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  AdminRole _role = AdminRole.support;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l = context.l10n;
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final ok = await runAction(
      context,
      () => ref.read(adminRepositoryProvider).createAdmin(phone: _phone.text, password: _password.text, fullName: _name.text.trim(), role: _role),
      successMessage: l.memberCreated,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      widget.onCreated();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.addMember, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              AppTextField(controller: _name, label: l.fullNameLabel, icon: Icons.person_outline, validator: (v) => (v == null || v.trim().length < 3) ? l.vFieldRequired : null),
              const SizedBox(height: 12),
              PhoneField(controller: _phone),
              const SizedBox(height: 12),
              PasswordField(controller: _password, validator: (v) => PasswordField.validateNew(context, v)),
              const SizedBox(height: 12),
              DropdownButtonFormField<AdminRole>(
                initialValue: _role,
                decoration: InputDecoration(labelText: l.roleField, prefixIcon: const Icon(Icons.shield_outlined)),
                items: [for (final r in AdminRole.values) DropdownMenuItem(value: r, child: Text('${l.adminRoleLabel(r)} — ${_roleDesc(l, r)}', overflow: TextOverflow.ellipsis))],
                isExpanded: true,
                onChanged: (r) => setState(() => _role = r ?? AdminRole.support),
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: l.register, loading: _busy, onPressed: _create),
            ],
          ),
        ),
      ),
    );
  }
}
