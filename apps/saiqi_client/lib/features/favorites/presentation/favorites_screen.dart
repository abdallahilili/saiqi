import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final favorites = ref.watch(favoriteDriversProvider);
    final cities = ref.watch(citiesProvider).value ?? const <City>[];
    return Scaffold(
      appBar: AppBar(title: Text(l.favoritesTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(favoriteDriversProvider),
        child: AsyncValueView<List<PublicDriver>>(
          value: favorites,
          onRetry: () => ref.invalidate(favoriteDriversProvider),
          isEmpty: (list) => list.isEmpty,
          emptyTitle: l.noFavorites,
          emptyMessage: l.noFavoritesHint,
          emptyIcon: Icons.favorite_border_rounded,
          data: (list) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final d = list[i];
              return DriverCard(
                driver: d,
                isFavorite: true,
                cityName: cities.where((c) => c.id == d.cityId).firstOrNull?.name(context.lang),
                onTap: () => context.push('/driver/${d.driverId}'),
                trailing: IconButton(
                  tooltip: l.removeFavorite,
                  icon: const Icon(Icons.favorite_rounded, color: AppColors.danger),
                  onPressed: () => runAction(context, () => ref.read(favoritesProvider.notifier).toggle(d.driverId), successMessage: l.favoriteRemoved),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
