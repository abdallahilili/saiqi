import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Accueil : ville, types de service, accès à la recherche.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final profile = ref.watch(profileProvider).value;
    final services = ref.watch(serviceTypesProvider);
    final cities = ref.watch(citiesProvider);
    final cityId = ref.watch(effectiveCityProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appName),
        actions: [NotificationBell(onPressed: () => context.push('/notifications'))],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(citiesProvider);
          ref.invalidate(serviceTypesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(colors: [scheme.primary, scheme.primary.withValues(alpha: 0.78)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.hello(profile?.fullName ?? ''), style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.85))),
                  const SizedBox(height: 4),
                  Text(l.findDriverTitle, style: TextStyle(color: scheme.onPrimary, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(l.findDriverSubtitle, style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.85), fontSize: 13)),
                  const SizedBox(height: 16),
                  AsyncValueView(
                    value: cities,
                    onRetry: () => ref.invalidate(citiesProvider),
                    data: (list) => DropdownButtonFormField<String>(
                      key: ValueKey('home-city-$cityId-${list.length}'),
                      initialValue: cityId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l.chooseCity,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      items: [for (final c in list) DropdownMenuItem(value: c.id, child: Text(c.name(context.lang)))],
                      onChanged: (v) => ref.read(selectedCityProvider.notifier).set(v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                    onPressed: cityId == null ? null : () => context.push('/drivers?city=$cityId'),
                    icon: const Icon(Icons.search_rounded),
                    label: Text(l.searchDrivers),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(l.whatDoYouNeed, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            services.when(
              loading: () => const Padding(padding: EdgeInsets.all(24), child: LoadingView()),
              error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(serviceTypesProvider)),
              data: (list) {
                if (list.isEmpty) return EmptyView(icon: Icons.category_outlined, title: l.noServiceTypes);
                return GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.95,
                  children: [
                    for (final s in list)
                      Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: cityId == null ? null : () => context.push('/drivers?city=$cityId&service=${s.id}'),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: scheme.primaryContainer,
                                  child: Icon(serviceIconFor(s.icon), color: scheme.primary),
                                ),
                                const SizedBox(height: 8),
                                Text(s.name(context.lang), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
