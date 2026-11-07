import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_exception.dart';
import '../l10n/l10n.dart';
import '../providers/core_providers.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/fields.dart';
import '../widgets/language_selector.dart';
import 'shared_screens.dart';

class _AuthFrame extends StatelessWidget {
  const _AuthFrame({required this.title, required this.subtitle, required this.child, this.badge});

  final String title;
  final String subtitle;
  final Widget child;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [LanguageMenuButton()], backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 84)),
                  const SizedBox(height: 18),
                  if (badge != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(badge!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 28),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Connexion : numéro + mot de passe. La redirection après succès est faite par le routeur de l'app.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onRegister, this.roleBadge});

  /// Null = pas d'inscription publique (app Admin).
  final VoidCallback? onRegister;
  final String? roleBadge;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final ok = await ref.read(authControllerProvider.notifier).signIn(phone: _phone.text, password: _password.text);
    if (!ok && mounted) {
      final err = ref.read(authControllerProvider).error;
      if (err != null) showErrorSnack(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final busy = ref.watch(authControllerProvider).isLoading;
    return _AuthFrame(
      title: l.loginTitle,
      subtitle: l.loginSubtitle,
      badge: widget.roleBadge,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PhoneField(controller: _phone, enabled: !busy),
            const SizedBox(height: 14),
            PasswordField(
              controller: _password,
              enabled: !busy,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: l.login, loading: busy, onPressed: _submit),
            if (widget.onRegister != null) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l.noAccountYet),
                  TextButton(onPressed: busy ? null : widget.onRegister, child: Text(l.register)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inscription : numéro + mot de passe + confirmation (sans SMS ni OTP).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.onLogin, this.roleBadge});

  final VoidCallback onLogin;
  final String? roleBadge;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final ok = await ref.read(authControllerProvider.notifier).signUp(phone: _phone.text, password: _password.text);
    if (!ok && mounted) {
      final err = ref.read(authControllerProvider).error;
      if (err != null) showErrorSnack(context, mapError(err));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final busy = ref.watch(authControllerProvider).isLoading;
    return _AuthFrame(
      title: l.registerTitle,
      subtitle: l.registerSubtitle,
      badge: widget.roleBadge,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PhoneField(controller: _phone, enabled: !busy),
            const SizedBox(height: 14),
            PasswordField(
              controller: _password,
              enabled: !busy,
              textInputAction: TextInputAction.next,
              validator: (v) => PasswordField.validateNew(context, v),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: Text(l.passwordHint, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            PasswordField(
              controller: _confirm,
              enabled: !busy,
              label: l.confirmPasswordLabel,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) => v == _password.text ? null : l.vPasswordsMismatch,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: l.register, loading: busy, onPressed: _submit),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l.alreadyHaveAccount),
                TextButton(onPressed: busy ? null : widget.onLogin, child: Text(l.login)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
