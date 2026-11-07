import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/core.dart';
import 'router.dart';

class SaiqiAdminApp extends ConsumerWidget {
  const SaiqiAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appName,
      routerConfig: router,
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      builder: (context, child) => _PushBootstrap(router: router, child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Démarre les notifications push une fois connecté et ouvre l'écran concerné au tap.
class _PushBootstrap extends ConsumerStatefulWidget {
  const _PushBootstrap({required this.router, required this.child});
  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<_PushBootstrap> createState() => _PushBootstrapState();
}

class _PushBootstrapState extends ConsumerState<_PushBootstrap> {
  @override
  void initState() {
    super.initState();
    ref.read(pushServiceProvider).onOpen = (data) {
      final ctx = widget.router.routerDelegate.navigatorKey.currentContext;
      if (ctx != null) openFromNotification(ctx, data);
    };
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileProvider, (prev, next) {
      final profile = next.value;
      if (profile != null && prev?.value?.id != profile.id) {
        ref.read(pushServiceProvider).start(channelName: context.l10n.notificationChannelName);
      }
    });
    return widget.child;
  }
}
