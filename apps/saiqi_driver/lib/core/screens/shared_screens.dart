import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../providers/core_providers.dart';
import '../utils/formatters.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/fields.dart';
import '../widgets/language_selector.dart';
import '../widgets/state_views.dart';

/// Logo SAIQI (pastille verte + volant stylisé).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 88});
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.75)],
        ),
        boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: size * 0.52),
    );
  }
}

/// Écran de démarrage pendant la lecture de la session.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 104),
            const SizedBox(height: 20),
            Text(l.appName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(l.appTagline, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
          ],
        ),
      ),
    );
  }
}

/// Choix de la langue au premier lancement (arabe par défaut).
class LanguageWelcomeScreen extends ConsumerWidget {
  const LanguageWelcomeScreen({super.key, required this.onContinue, this.subtitle});

  final VoidCallback onContinue;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final current = ref.watch(localeProvider).languageCode;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const AppLogo(size: 110),
              const SizedBox(height: 24),
              Text(l.appName, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(subtitle ?? l.appTagline, textAlign: TextAlign.center),
              const Spacer(),
              Text(l.chooseLanguage, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (final code in const ['ar', 'fr'])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          selected: current == code,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(
                              code == 'ar' ? l.languageArabic : l.languageFrench,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                          ),
                          onSelected: (_) => ref.read(localeProvider.notifier).setLanguage(code),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l.welcomeContinue,
                onPressed: () async {
                  // confirme le choix (même si l'utilisateur garde la langue par défaut) : le routeur prend le relais
                  await ref.read(languageChosenProvider.notifier).confirm();
                  onContinue();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Changement de mot de passe (ancien + nouveau + confirmation).
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final ok = await runAction(
      context,
      () => ref.read(authRepositoryProvider).changePassword(currentPassword: _current.text, newPassword: _new.text),
      successMessage: context.l10n.passwordChanged,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.changePassword)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Form(
              key: _form,
              child: Column(
                children: [
                  PasswordField(controller: _current, label: l.currentPassword, textInputAction: TextInputAction.next),
                  const SizedBox(height: 14),
                  PasswordField(
                    controller: _new,
                    label: l.newPassword,
                    textInputAction: TextInputAction.next,
                    validator: (v) => PasswordField.validateNew(context, v),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(l.passwordHint, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 14),
                  PasswordField(
                    controller: _confirm,
                    label: l.confirmNewPassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: (v) => v == _new.text ? null : l.vPasswordsMismatch,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: l.save, loading: _busy, onPressed: _submit),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Boîte de réception des notifications (Realtime). [onOpen] reçoit `data` pour naviguer.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key, this.onOpen});

  final void Function(BuildContext context, Map<String, dynamic> data)? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final stream = ref.watch(_notificationsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.notifications),
        actions: [
          IconButton(
            tooltip: l.markAllRead,
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () => runAction(context, () => ref.read(notificationRepositoryProvider).markAllRead()),
          ),
        ],
      ),
      body: AsyncValueView(
        value: stream,
        onRetry: () => ref.invalidate(_notificationsStreamProvider),
        isEmpty: (list) => list.isEmpty,
        emptyTitle: l.noNotifications,
        emptyMessage: l.notificationsEmptyHint,
        emptyIcon: Icons.notifications_none_rounded,
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final n = list[i];
            final scheme = Theme.of(context).colorScheme;
            return Dismissible(
              key: ValueKey(n.id),
              background: Container(
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
              ),
              onDismissed: (_) => ref.read(notificationRepositoryProvider).delete(n.id),
              child: Card(
                color: n.isRead ? null : scheme.primaryContainer.withValues(alpha: 0.35),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.notifications_rounded, color: scheme.primary),
                  ),
                  title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.body),
                      const SizedBox(height: 4),
                      Text(Fmt.dateTime(n.createdAt, context.lang),
                          style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                  onTap: () {
                    if (!n.isRead) ref.read(notificationRepositoryProvider).markRead(n.id);
                    onOpen?.call(context, n.data);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final _notificationsStreamProvider =
    StreamProvider.autoDispose((ref) => ref.watch(notificationRepositoryProvider).watch());

/// Pastille de notifications avec compteur, pour les AppBar.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsProvider).value ?? 0;
    return IconButton(
      tooltip: context.l10n.notifications,
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

/// Bloc « Mon compte » commun : langue, thème, mot de passe, déconnexion.
class AccountSettingsSection extends ConsumerWidget {
  const AccountSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Column(
      children: [
        const SectionCard(child: AppearanceSettings()),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_reset_outlined),
                title: Text(l.changePassword),
                trailing: const DirectionalChevron(),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ChangePasswordScreen())),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
                title: Text(l.logout, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () async {
                  final ok = await confirmDialog(context, title: l.logout, message: l.logoutConfirm, destructive: true);
                  if (ok) await ref.read(authControllerProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Affichée quand SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY ne sont pas fournis au build.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings_suggest_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('Configuration manquante / إعداد ناقص',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  SizedBox(height: 12),
                  Text(
                    'SUPABASE_URL et SUPABASE_PUBLISHABLE_KEY ne sont pas définis.\n'
                    'Lancez : flutter run --dart-define-from-file=.env',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
