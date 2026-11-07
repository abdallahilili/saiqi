import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/driver_models.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/storage_urls.dart';
import 'avatar.dart';
import 'badges.dart';
import 'rating.dart';

/// Carte chauffeur : photo, nom, véhicule, prix, note, disponibilité, badge vérifié.
class DriverCard extends StatelessWidget {
  const DriverCard({
    super.key,
    required this.driver,
    this.cityName,
    this.onTap,
    this.trailing,
    this.isFavorite = false,
  });

  final PublicDriver driver;
  final String? cityName;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final lang = context.lang;
    final name = driver.fullName ?? '—';
    final photo = driver.vehiclePhotos.isEmpty ? null : StorageUrls.vehiclePhoto(driver.vehiclePhotos.first);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(url: driver.avatarUrl, name: name, radius: 30),
                  PositionedDirectional(
                    end: -2,
                    bottom: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: driver.isAvailable ? AppColors.success : AppColors.neutral,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, size: 18, color: AppColors.success),
                        if (isFavorite) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.favorite_rounded, size: 16, color: AppColors.danger),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (driver.ratingCount > 0)
                      StarRating(value: driver.ratingAvg, size: 16, showValue: true, count: driver.ratingCount)
                    else
                      Text(l.noRatingYet, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5)),
                    const SizedBox(height: 6),
                    if (driver.vehicleTitle.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.directions_car_filled_outlined, size: 16, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              [
                                driver.vehicleTitle,
                                if (driver.vehicleYear != null) '${driver.vehicleYear}',
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (driver.price != null && driver.priceUnit != null)
                          StatusBadge(
                            label: '${Fmt.mru(driver.price!, lang)} ${l.priceUnitLabel(driver.priceUnit!)}',
                            color: scheme.primary,
                            dense: true,
                          ),
                        if (driver.seats != null)
                          StatusBadge(
                            label: l.seatsCount('${driver.seats}'),
                            color: AppColors.neutral,
                            icon: Icons.event_seat_outlined,
                            dense: true,
                          ),
                        StatusBadge(
                          label: driver.isAvailable ? l.availableNow : l.unavailableNow,
                          color: driver.isAvailable ? AppColors.success : AppColors.neutral,
                          dense: true,
                        ),
                        if (cityName != null)
                          StatusBadge(label: cityName!, color: AppColors.info, icon: Icons.place_outlined, dense: true),
                      ],
                    ),
                  ],
                ),
              ),
              if (photo != null || trailing != null) const SizedBox(width: 8),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
