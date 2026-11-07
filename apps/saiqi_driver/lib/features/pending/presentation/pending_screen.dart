import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Dossier envoyé : statut mis à jour en temps réel (le routeur bascule vers l'accueil à l'approbation).
class PendingScreen extends ConsumerWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final driver = ref.watch(myDriverProvider).value;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        actions: const [LanguageMenuButton()],
        title: Text(l.applicationTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                child: const Icon(Icons.hourglass_top_rounded, size: 52, color: AppColors.warning),
              ),
            ),
            const SizedBox(height: 24),
            Text(l.pendingTitle,
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(l.pendingBody, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5)),
            if (driver?.submittedAt != null) ...[
              const SizedBox(height: 14),
              Center(child: StatusBadge(label: l.pendingSince(Fmt.dateTime(driver!.submittedAt!, context.lang)), color: AppColors.info, icon: Icons.schedule)),
            ],
            const SizedBox(height: 32),
            const _SupportActions(),
            const SizedBox(height: 16),
            SecondaryButton(
              label: l.logout,
              icon: Icons.logout_rounded,
              onPressed: () async {
                final ok = await confirmDialog(context, title: l.logout, message: l.logoutConfirm, destructive: true);
                if (ok) await ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SuspendedScreen extends ConsumerWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final driver = ref.watch(myDriverProvider).value;
    return Scaffold(
      appBar: AppBar(actions: const [LanguageMenuButton()], title: Text(l.suspendedTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                child: const Icon(Icons.block_rounded, size: 52, color: AppColors.danger),
              ),
            ),
            const SizedBox(height: 24),
            Text(l.suspendedBody, textAlign: TextAlign.center),
            if (driver?.rejectionReason != null) ...[
              const SizedBox(height: 14),
              InfoBanner(message: '${l.reason} : ${driver!.rejectionReason}', color: AppColors.danger, icon: Icons.info_outline),
            ],
            const SizedBox(height: 28),
            const _SupportActions(),
            const SizedBox(height: 16),
            SecondaryButton(
              label: l.logout,
              icon: Icons.logout_rounded,
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Appel / WhatsApp du support si le numéro est configuré par l'admin (app_settings).
class _SupportActions extends ConsumerWidget {
  const _SupportActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = ref.watch(appSettingsProvider).value ?? AppSettings.empty;
    final call = settings.supportPhone;
    final wa = settings.supportWhatsapp.isNotEmpty ? settings.supportWhatsapp : call;
    if (call.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SecondaryButton(label: l.contactSupportCall, icon: Icons.call_outlined, onPressed: () => Launchers.call(call)),
        const SizedBox(height: 10),
        SecondaryButton(label: l.contactSupportWhatsapp, icon: Icons.chat_outlined, onPressed: () => Launchers.whatsapp(wa)),
      ],
    );
  }
}

/// Écran de compte accessible pendant l'attente (langue, mot de passe, déconnexion).
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(padding: const EdgeInsets.all(16), children: const [AccountSettingsSection()]),
    );
  }
}
