import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Hub du dossier : 5 étapes, progression, soumission pour validation.
class ApplicationHubScreen extends ConsumerStatefulWidget {
  const ApplicationHubScreen({super.key});

  @override
  ConsumerState<ApplicationHubScreen> createState() => _ApplicationHubScreenState();
}

class _ApplicationHubScreenState extends ConsumerState<ApplicationHubScreen> {
  bool _submitting = false;

  Future<void> _submit() async {
    final l = context.l10n;
    final ok = await confirmDialog(context, title: l.submitApplication, message: l.submitApplicationConfirm);
    if (!ok || !mounted) return;
    setState(() => _submitting = true);
    try {
      await ref.read(driverRepositoryProvider).submitApplication();
      if (mounted) showAppSnack(context, l.applicationSubmitted);
    } on AppException catch (e) {
      if (!mounted) return;
      if (e.code == 'application_incomplete') {
        final missing = (e.params['missing'] ?? '').split(',').where((s) => s.isNotEmpty).map((s) => _label(l, s)).join('، ');
        showAppSnack(context, '${l.err_application_incomplete}\n${l.missingItems(missing)}', error: true);
      } else {
        showErrorSnack(context, e);
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _label(AppLocalizations l, String key) {
    if (key.startsWith('doc:')) {
      final t = DocumentType.values.where((d) => d.db == key.substring(4));
      return t.isEmpty ? key : l.documentTypeLabel(t.first);
    }
    return switch (key) {
      'full_name' || 'city' => l.stepPersonal,
      'vehicle' => l.stepVehicle,
      'services' => l.stepServices,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final progress = ref.watch(applicationProgressProvider);
    final driver = ref.watch(myDriverProvider).value;
    final rejected = driver?.status == DriverStatus.rejected;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.applicationTitle),
        actions: [
          const LanguageMenuButton(),
          IconButton(
            tooltip: l.logout,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final ok = await confirmDialog(context, title: l.logout, message: l.logoutConfirm, destructive: true);
              if (ok) await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: AsyncValueView<ApplicationProgress>(
        value: progress,
        onRetry: () => ref.invalidate(vehicleProvider),
        data: (p) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (rejected) ...[
              InfoBanner(
                icon: Icons.report_gmailerrorred_rounded,
                color: AppColors.danger,
                message: '${l.applicationRejectedTitle}\n${driver?.rejectionReason ?? ''}\n${l.applicationRejectedHint}',
              ),
              const SizedBox(height: 12),
            ],
            Text(l.applicationIntro, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            _StepTile(icon: Icons.person_outline, title: l.stepPersonal, done: p.personal, onTap: () => context.push('/edit/info')),
            _StepTile(icon: Icons.badge_outlined, title: l.stepDocuments, done: p.documents, onTap: () => context.push('/edit/documents')),
            _StepTile(icon: Icons.directions_car_outlined, title: l.stepVehicle, done: p.vehicle, onTap: () => context.push('/edit/vehicle')),
            _StepTile(icon: Icons.payments_outlined, title: l.stepServices, done: p.services, onTap: () => context.push('/edit/services')),
            _StepTile(
              icon: Icons.schedule_outlined,
              title: l.stepAvailability,
              done: p.availability,
              optional: true,
              onTap: () => context.push('/edit/availability'),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l.submitApplication,
              icon: Icons.send_rounded,
              loading: _submitting,
              onPressed: p.canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.icon, required this.title, required this.done, required this.onTap, this.optional = false});

  final IconData icon;
  final String title;
  final bool done;
  final bool optional;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color = done ? AppColors.success : (optional ? AppColors.neutral : AppColors.warning);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 6, 10, 6),
          leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.14), child: Icon(icon, color: color)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: StatusBadge(
                label: done ? l.stepComplete : (optional ? l.stepOptional : l.stepTodo),
                color: color,
                icon: done ? Icons.check_circle_rounded : null,
                dense: true,
              ),
            ),
          ),
          trailing: const DirectionalChevron(),
          onTap: onTap,
        ),
      ),
    );
  }
}
