import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Fiche chauffeur : photos du véhicule, infos, tarifs, avis, favori, réservation.
class DriverDetailScreen extends ConsumerWidget {
  const DriverDetailScreen({super.key, required this.driverId, this.serviceTypeId, this.cityId});
  final String driverId;
  final String? serviceTypeId;
  final String? cityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final driver = ref.watch(publicDriverProvider(driverId));
    final favorites = ref.watch(favoritesProvider).value ?? const <String>{};
    final isFav = favorites.contains(driverId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.driverDetail),
        actions: [
          IconButton(
            tooltip: isFav ? l.removeFavorite : l.addFavorite,
            icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFav ? AppColors.danger : null),
            onPressed: () async {
              try {
                final added = await ref.read(favoritesProvider.notifier).toggle(driverId);
                if (context.mounted) showAppSnack(context, added ? l.favoriteAdded : l.favoriteRemoved);
              } catch (e) {
                if (context.mounted) showErrorSnack(context, e);
              }
            },
          ),
        ],
      ),
      body: AsyncValueView<PublicDriver?>(
        value: driver,
        onRetry: () => ref.invalidate(publicDriverProvider(driverId)),
        data: (d) {
          if (d == null) return EmptyView(icon: Icons.person_off_outlined, title: l.driverNotFoundClient);
          return _Body(driver: d, serviceTypeId: serviceTypeId, cityId: cityId);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.driver, this.serviceTypeId, this.cityId});
  final PublicDriver driver;
  final String? serviceTypeId;
  final String? cityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final services = ref.watch(publicServicesProvider(driver.driverId));
    final reviews = ref.watch(publicReviewsProvider(driver.driverId));
    final types = ref.watch(serviceTypesProvider).value ?? const <ServiceType>[];
    final cities = ref.watch(citiesProvider).value ?? const <City>[];
    final scheme = Theme.of(context).colorScheme;
    final name = driver.fullName ?? '—';

    final bookQuery = [
      if (cityId != null) 'city=$cityId',
      if (serviceTypeId != null) 'service=$serviceTypeId',
    ].join('&');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (driver.vehiclePhotos.isNotEmpty) ...[
                SizedBox(
                  height: 190,
                  child: PageView.builder(
                    itemCount: driver.vehiclePhotos.length,
                    controller: PageController(viewportFraction: 0.92),
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (_) => ImageViewerPage(title: driver.vehicleTitle, bucket: Buckets.vehiclePhotos, path: driver.vehiclePhotos[i]),
                        )),
                        child: AppNetworkImage(url: StorageUrls.vehiclePhoto(driver.vehiclePhotos[i]), radius: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  UserAvatar(url: driver.avatarUrl, name: name, radius: 34),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(child: Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: AppColors.success, size: 22),
                        ]),
                        const SizedBox(height: 4),
                        if (driver.ratingCount > 0) StarRating(value: driver.ratingAvg, size: 18, showValue: true, count: driver.ratingCount) else Text(l.noRatingYet),
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, runSpacing: 4, children: [
                          StatusBadge(label: driver.isAvailable ? l.availableNow : l.unavailableNow, color: driver.isAvailable ? AppColors.success : AppColors.neutral, dense: true),
                          StatusBadge(label: '${driver.completedCount} ${l.tripsDone}', color: AppColors.info, dense: true),
                          if (driver.yearsExperience != null) StatusBadge(label: l.yearsExperience('${driver.yearsExperience}'), color: AppColors.neutral, dense: true),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              if (driver.bio != null && driver.bio!.isNotEmpty) ...[
                const SizedBox(height: 16),
                SectionCard(title: l.aboutDriver, child: Text(driver.bio!)),
              ],
              if (driver.vehicleTitle.isNotEmpty) ...[
                const SizedBox(height: 12),
                SectionCard(
                  title: l.vehicleTitle,
                  child: Column(children: [
                    InfoRow(label: l.vehicleBrand, value: driver.vehicleTitle, icon: Icons.directions_car_outlined),
                    if (driver.vehicleType != null) InfoRow(label: l.vehicleType, value: l.vehicleTypeLabel(driver.vehicleType!)),
                    if (driver.vehicleYear != null) InfoRow(label: l.vehicleYear, value: '${driver.vehicleYear}'),
                    if (driver.vehicleColor != null) InfoRow(label: l.vehicleColor, value: driver.vehicleColor),
                    if (driver.seats != null) InfoRow(label: l.vehicleSeats, value: '${driver.seats}', icon: Icons.event_seat_outlined),
                  ]),
                ),
              ],
              const SizedBox(height: 12),
              SectionCard(
                title: l.tariffs,
                child: services.when(
                  loading: () => const Padding(padding: EdgeInsets.all(12), child: LoadingView()),
                  error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(publicServicesProvider(driver.driverId))),
                  data: (list) {
                    if (list.isEmpty) return Text(l.noTariffs);
                    return Column(
                      children: [
                        for (final s in list)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: scheme.primaryContainer,
                              child: Icon(serviceIconFor(types.where((t) => t.id == s.serviceTypeId).firstOrNull?.icon ?? ''), color: scheme.primary),
                            ),
                            title: Text(types.where((t) => t.id == s.serviceTypeId).firstOrNull?.name(lang) ?? '—', style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(cities.where((c) => s.cityIds.contains(c.id)).map((c) => c.name(lang)).join('، ')),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(Fmt.mru(s.price, lang), style: const TextStyle(fontWeight: FontWeight.w900)),
                                Text(l.priceUnitLabel(s.priceUnit), style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
                              ],
                            ),
                            onTap: driver.isAvailable
                                ? () => context.push('/book/${driver.driverId}?service=${s.serviceTypeId}${cityId != null ? '&city=$cityId' : ''}')
                                : null,
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                title: l.reviewsTitle,
                child: reviews.when(
                  loading: () => const Padding(padding: EdgeInsets.all(12), child: LoadingView()),
                  error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(publicReviewsProvider(driver.driverId))),
                  data: (list) => list.isEmpty
                      ? Text(l.noReviewsClient)
                      : Column(children: [for (final r in list.take(6)) ...[ReviewTile(review: r), const SizedBox(height: 8)]]),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: PrimaryButton(
              label: driver.isAvailable ? l.bookNow : l.unavailableNow,
              icon: Icons.event_available_rounded,
              onPressed: driver.isAvailable ? () => context.push('/book/${driver.driverId}${bookQuery.isEmpty ? '' : '?$bookQuery'}') : null,
            ),
          ),
        ),
      ],
    );
  }
}
