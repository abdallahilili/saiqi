import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../providers/core_providers.dart';

/// Bascule arabe / français (la langue est mémorisée et envoyée au profil si connecté).
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;
    final l = context.l10n;
    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: 'ar', label: Text(l.languageArabic)),
        ButtonSegment(value: 'fr', label: Text(l.languageFrench)),
      ],
      selected: {current},
      onSelectionChanged: (s) => ref.read(localeProvider.notifier).setLanguage(s.first),
    );
  }
}

/// Petit bouton « langue » pour les barres d'application.
class LanguageMenuButton extends ConsumerWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;
    return PopupMenuButton<String>(
      tooltip: context.l10n.language,
      icon: const Icon(Icons.translate_rounded),
      onSelected: (code) => ref.read(localeProvider.notifier).setLanguage(code),
      itemBuilder: (_) => [
        CheckedPopupMenuItem(value: 'ar', checked: current == 'ar', child: Text(context.l10n.languageArabic)),
        CheckedPopupMenuItem(value: 'fr', checked: current == 'fr', child: Text(context.l10n.languageFrench)),
      ],
    );
  }
}

/// Réglages d'apparence (langue + thème), à placer dans l'écran Profil.
class AppearanceSettings extends ConsumerWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final mode = ref.watch(themeModeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.language, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        const SizedBox(width: double.infinity, child: LanguageSelector()),
        const SizedBox(height: 16),
        Text(l.theme, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(l.themeSystem), icon: const Icon(Icons.brightness_auto_outlined)),
              ButtonSegment(value: ThemeMode.light, label: Text(l.themeLight), icon: const Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark), icon: const Icon(Icons.dark_mode_outlined)),
            ],
            selected: {mode},
            onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
          ),
        ),
      ],
    );
  }
}
