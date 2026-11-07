import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Nom, ville, expérience, présentation et photo de profil.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _years = TextEditingController();
  final _bio = TextEditingController();
  String? _cityId;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _years.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _fill() {
    if (_loaded) return;
    final profile = ref.read(profileProvider).value;
    final driver = ref.read(myDriverProvider).value;
    if (profile == null || driver == null) return;
    _name.text = profile.fullName ?? '';
    _years.text = driver.yearsExperience?.toString() ?? '';
    _bio.text = driver.bio ?? '';
    _cityId = driver.cityId;
    _loaded = true;
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final ok = await runAction(context, () async {
      await ref.read(authRepositoryProvider).updateProfile(fullName: _name.text);
      await ref.read(driverRepositoryProvider).updateDriverInfo(
            cityId: _cityId,
            bio: _bio.text,
            yearsExperience: int.tryParse(_years.text.trim()),
          );
      await ref.read(profileProvider.notifier).reload();
    }, successMessage: context.l10n.saved);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final profile = ref.watch(profileProvider).value;
    ref.watch(myDriverProvider);
    _fill();

    return Scaffold(
      appBar: AppBar(title: Text(l.stepPersonal)),
      body: !_loaded
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      UserAvatar(url: profile?.avatarUrl, name: _name.text.isEmpty ? (profile?.phone ?? '') : _name.text, radius: 48),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(l.changePhoto),
                        onPressed: () async {
                          final file = await pickImageSheet(context, ref);
                          if (file == null || !context.mounted) return;
                          await runAction(context, () async {
                            final path = await ref
                                .read(storageRepositoryProvider)
                                .uploadImage(bucket: Buckets.avatars, folder: 'profile', file: file);
                            await ref.read(authRepositoryProvider).updateProfile(avatarUrl: StorageUrls.avatar(path));
                            await ref.read(profileProvider.notifier).reload();
                          }, successMessage: l.photoUploaded);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Form(
                  key: _form,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _name,
                        label: l.fullNameLabel,
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().length < 3) ? l.vFieldRequired : null,
                      ),
                      const SizedBox(height: 14),
                      CityDropdown(
                        value: _cityId,
                        label: l.cityOfWork,
                        onChanged: (v) => setState(() => _cityId = v),
                        validator: (v) => v == null ? l.vFieldRequired : null,
                      ),
                      const SizedBox(height: 14),
                      IntField(controller: _years, label: l.yearsExperienceLabel, icon: Icons.workspace_premium_outlined, min: 0, max: 60, required: false),
                      const SizedBox(height: 14),
                      AppTextField(controller: _bio, label: l.bioLabel, hint: l.bioHint, icon: Icons.notes_outlined, maxLines: 4, maxLength: 400),
                      const SizedBox(height: 20),
                      PrimaryButton(label: l.save, loading: _saving, onPressed: _save),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
