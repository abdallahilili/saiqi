import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../utils/phone.dart';

/// Champ texte standard (étiquette flottante, icône, validation).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.obscureText = false,
    this.suffix,
    this.onChanged,
    this.textDirection,
    this.autofillHints,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final TextDirection? textDirection;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      onChanged: onChanged,
      textDirection: textDirection,
      autofillHints: autofillHints,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffix,
      ),
    );
  }
}

/// Numéro mauritanien : préfixe +222 fixe, saisie des 8 chiffres (sens gauche-droite même en arabe).
class PhoneField extends StatelessWidget {
  const PhoneField({super.key, required this.controller, this.label, this.enabled = true, this.textInputAction});

  final TextEditingController controller;
  final String? label;
  final bool enabled;
  final TextInputAction? textInputAction;

  static String? validate(BuildContext context, String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.vFieldRequired;
    return PhoneUtils.isValid(v) ? null : context.l10n.vPhoneInvalid;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      textDirection: TextDirection.ltr,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction ?? TextInputAction.next,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')), LengthLimitingTextInputFormatter(17)],
      validator: (v) => validate(context, v),
      decoration: InputDecoration(
        labelText: label ?? l.phoneLabel,
        hintText: l.phoneHint,
        prefixIcon: const Icon(Icons.phone_outlined),
        prefixText: '${l.phonePrefix}  ',
        prefixStyle: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

/// Mot de passe avec bouton afficher/masquer.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String? label;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final Iterable<String>? autofillHints;

  /// Règle commune : 8 caractères minimum.
  static String? validateNew(BuildContext context, String? v) {
    if (v == null || v.isEmpty) return context.l10n.vFieldRequired;
    return v.length < 8 ? context.l10n.vPasswordMin : null;
  }

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label ?? context.l10n.passwordLabel,
      icon: Icons.lock_outline,
      obscureText: _hidden,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      autofillHints: widget.autofillHints,
      textDirection: TextDirection.ltr,
      validator: widget.validator ??
          (v) => (v == null || v.isEmpty) ? context.l10n.vFieldRequired : null,
      suffix: IconButton(
        icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        onPressed: () => setState(() => _hidden = !_hidden),
      ),
    );
  }
}

/// Champ entier (montant, nombre de places…).
class IntField extends StatelessWidget {
  const IntField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.min,
    this.max,
    this.required = true,
    this.suffixText,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final int? min;
  final int? max;
  final bool required;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.ltr,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return required ? l.vFieldRequired : null;
        final n = int.tryParse(v.trim());
        if (n == null) return l.vNumberInvalid;
        if (min != null && n < min!) return l.vNumberInvalid;
        if (max != null && n > max!) return l.vNumberInvalid;
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixText: suffixText,
      ),
    );
  }
}
