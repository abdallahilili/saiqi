import 'package:flutter/material.dart';

import '../errors/app_exception.dart';
import '../l10n/l10n.dart';
import '../utils/formatters.dart';

/// Carte avec titre de section optionnel.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, required this.child, this.trailing, this.padding = const EdgeInsets.all(16)});

  final String? title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(child: Text(title!, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                    ?trailing,
                  ],
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

/// Ligne « libellé : valeur » (valeur éventuellement copiable).
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, this.value, this.valueWidget, this.icon, this.bold = false});

  final String label;
  final String? value;
  final Widget? valueWidget;
  final IconData? icon;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[Icon(icon, size: 18, color: scheme.onSurfaceVariant), const SizedBox(width: 10)],
          SizedBox(
            width: 112,
            child: Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '—',
                  style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600),
                ),
          ),
        ],
      ),
    );
  }
}

/// Montant en MRU.
class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, this.style, this.signed = false});
  final int amount;
  final TextStyle? style;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    final text = signed ? Fmt.signedMru(amount, context.lang) : Fmt.mru(amount, context.lang);
    return Text(text, style: style, textDirection: Directionality.of(context));
  }
}

class DirectionalChevron extends StatelessWidget {
  const DirectionalChevron({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) =>
      Icon(context.isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, size: size);
}

void showAppSnack(BuildContext context, String message, {bool error = false}) {
  final messenger = ScaffoldMessenger.of(context);
  final scheme = Theme.of(context).colorScheme;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? scheme.error : null,
    ));
}

void showErrorSnack(BuildContext context, Object error) =>
    showAppSnack(context, errorMessage(context.l10n, error), error: true);

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String? confirmLabel,
  bool destructive = false,
}) async {
  final l = context.l10n;
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError,
                  minimumSize: const Size(96, 44),
                )
              : FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel ?? l.confirm),
        ),
      ],
    ),
  );
  return res ?? false;
}

/// Demande un texte (motif de refus, raison d'annulation…). Renvoie null si annulé.
Future<String?> promptTextDialog(
  BuildContext context, {
  required String title,
  String? hint,
  bool required = true,
  String? confirmLabel,
  String? initial,
  int maxLines = 3,
}) async {
  final l = context.l10n;
  final controller = TextEditingController(text: initial);
  final formKey = GlobalKey<FormState>();
  final res = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          maxLines: maxLines,
          minLines: 1,
          decoration: InputDecoration(hintText: hint),
          validator: (v) => required && (v == null || v.trim().isEmpty) ? l.vFieldRequired : null,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, controller.text.trim());
          },
          child: Text(confirmLabel ?? l.confirm),
        ),
      ],
    ),
  );
  controller.dispose();
  return res;
}

/// Exécute [action] avec indicateur et gestion d'erreur unifiée ; renvoie true si réussie.
Future<bool> runAction(
  BuildContext context,
  Future<void> Function() action, {
  String? successMessage,
}) async {
  try {
    await action();
    if (context.mounted && successMessage != null) showAppSnack(context, successMessage);
    return true;
  } catch (e) {
    if (context.mounted) showErrorSnack(context, e);
    return false;
  }
}
