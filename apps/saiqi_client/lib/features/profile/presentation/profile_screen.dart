import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  bool _filled = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final l = context.l10n;
    final value = _name.text.trim();
    if (value.length < 3) {
      showAppSnack(context, l.vFieldRequired, error: true);
      return;
    }
    setState(() => _saving = true);
    await runAction(context, () async {
      await ref.read(authRepositoryProvider).updateProfile(fullName: value);
      await ref.read(profileProvider.notifier).reload();
    }, successMessage: l.saved);
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _changeAvatar() async {
    final l = context.l10n;
    final file = await pickImageSheet(context, ref);
    if (file == null || !mounted) return;
    await runAction(context, () async {
      final path = await ref.read(storageRepositoryProvider).uploadImage(bucket: Buckets.avatars, folder: 'profile', file: file);
      await ref.read(authRepositoryProvider).updateProfile(avatarUrl: StorageUrls.avatar(path));
      await ref.read(profileProvider.notifier).reload();
    }, successMessage: l.photoUploaded);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final profile = ref.watch(profileProvider).value;
    if (!_filled && profile != null) {
      _name.text = profile.fullName ?? '';
      _filled = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l.myAccount),
        actions: [NotificationBell(onPressed: () => context.push('/notifications'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                UserAvatar(url: profile?.avatarUrl, name: profile?.displayName ?? '', radius: 46),
                TextButton.icon(onPressed: _changeAvatar, icon: const Icon(Icons.photo_camera_outlined), label: Text(l.changePhoto)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SectionCard(
            child: Column(
              children: [
                AppTextField(controller: _name, label: l.editName, icon: Icons.person_outline),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(padding: const EdgeInsets.only(top: 6, bottom: 12), child: Text(l.nameHelp, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                ),
                InfoRow(label: l.phoneLabel, valueWidget: Directionality(textDirection: TextDirection.ltr, child: Text(PhoneUtils.pretty(profile?.phone), style: const TextStyle(fontWeight: FontWeight.w700))), icon: Icons.phone_outlined),
                const SizedBox(height: 8),
                PrimaryButton(label: l.save, loading: _saving, onPressed: _saveName),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: Text(l.helpClient),
              trailing: const DirectionalChevron(),
              onTap: () => context.push('/help'),
            ),
          ),
          const SizedBox(height: 12),
          const AccountSettingsSection(),
        ],
      ),
    );
  }
}
