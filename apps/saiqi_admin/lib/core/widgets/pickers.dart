import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../models/booking_models.dart';
import '../models/catalog_models.dart';
import '../providers/core_providers.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/launchers.dart';
import '../utils/phone.dart';
import 'common.dart';
import 'rating.dart';

/// Nom d'icône Material (stocké en base dans service_types.icon) -> IconData.
IconData serviceIconFor(String name) => switch (name) {
      'local_taxi' => Icons.local_taxi_rounded,
      'directions_car' => Icons.directions_car_rounded,
      'terrain' => Icons.terrain_rounded,
      'route' => Icons.route_rounded,
      'business_center' => Icons.business_center_rounded,
      'celebration' => Icons.celebration_rounded,
      'groups' => Icons.groups_rounded,
      'delivery_dining' => Icons.delivery_dining_rounded,
      'airport_shuttle' => Icons.airport_shuttle_rounded,
      'directions_bus' => Icons.directions_bus_rounded,
      _ => Icons.directions_car_rounded,
    };

const serviceIconChoices = [
  'local_taxi', 'directions_car', 'terrain', 'route', 'business_center', 'celebration', 'groups',
  'delivery_dining', 'airport_shuttle', 'directions_bus',
];

/// Liste déroulante de villes (catalogue mis en cache).
class CityDropdown extends ConsumerWidget {
  const CityDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.validator,
    this.allowAll = false,
    this.enabled = true,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String? label;
  final String? Function(String?)? validator;

  /// Ajoute l'entrée « Tous » (valeur null) pour les filtres.
  final bool allowAll;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cities = ref.watch(citiesProvider);
    final items = cities.value ?? const <City>[];
    return DropdownButtonFormField<String?>(
      key: ValueKey('city-$value-${items.length}'),
      initialValue: items.any((c) => c.id == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label ?? l.city, prefixIcon: const Icon(Icons.location_city_outlined)),
      validator: validator,
      items: [
        if (allowAll) DropdownMenuItem<String?>(value: null, child: Text(l.all)),
        for (final c in items) DropdownMenuItem<String?>(value: c.id, child: Text(c.name(context.lang))),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

class ServiceTypeDropdown extends ConsumerWidget {
  const ServiceTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.validator,
    this.allowAll = false,
    this.enabled = true,
    this.onlyIds,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String? label;
  final String? Function(String?)? validator;
  final bool allowAll;
  final bool enabled;

  /// Restreint la liste (ex. services déjà proposés).
  final Set<String>? onlyIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final all = ref.watch(serviceTypesProvider).value ?? const <ServiceType>[];
    final items = onlyIds == null ? all : all.where((s) => onlyIds!.contains(s.id)).toList();
    return DropdownButtonFormField<String?>(
      key: ValueKey('svc-$value-${items.length}'),
      initialValue: items.any((s) => s.id == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label ?? l.serviceType, prefixIcon: const Icon(Icons.category_outlined)),
      validator: validator,
      items: [
        if (allowAll) DropdownMenuItem<String?>(value: null, child: Text(l.all)),
        for (final s in items)
          DropdownMenuItem<String?>(
            value: s.id,
            child: Row(children: [
              Icon(serviceIconFor(s.icon), size: 20),
              const SizedBox(width: 10),
              Flexible(child: Text(s.name(context.lang), overflow: TextOverflow.ellipsis)),
            ]),
          ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

/// Champ date + heure (deux sélecteurs successifs).
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.allowPast = false,
    this.validator,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final bool allowPast;
  final String? Function(DateTime?)? validator;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final initial = value ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) && !allowPast ? now : initial,
      firstDate: allowPast ? DateTime(now.year - 1) : DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null) return;
    onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return FormField<DateTime>(
      initialValue: value,
      validator: (_) => validator?.call(value),
      builder: (state) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _pick(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label ?? l.dateAndTime,
            prefixIcon: const Icon(Icons.event_outlined),
            errorText: state.errorText,
          ),
          child: Text(value == null ? l.select : Fmt.dateTime(value!, context.lang)),
        ),
      ),
    );
  }
}

/// Boutons « Appeler » + « WhatsApp » pour un numéro (visibles après acceptation seulement).
class ContactActions extends StatelessWidget {
  const ContactActions({super.key, required this.phone, this.name, this.whatsappMessage});

  final String phone;
  final String? name;
  final String? whatsappMessage;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Future<void> open(Future<bool> Function() action) async {
      final ok = await action();
      if (!ok && context.mounted) showAppSnack(context, l.cannotOpenLink, error: true);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name != null) Text(name!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SelectableText(PhoneUtils.pretty(phone), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => open(() => Launchers.call(phone)),
                icon: const Icon(Icons.call_rounded),
                label: Text(l.call),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                onPressed: () => open(() => Launchers.whatsapp(phone, message: whatsappMessage)),
                icon: const Icon(Icons.chat_rounded),
                label: Text(l.whatsapp),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Avis d'un client sur un chauffeur.
class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StarRating(value: review.rating.toDouble(), size: 18),
                const Spacer(),
                Text(Fmt.date(review.createdAt, context.lang), style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              ],
            ),
            if (review.reviewerName != null) ...[
              const SizedBox(height: 6),
              Text(review.reviewerName!, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(review.comment!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Carte de synthèse d'une ligne de trajet (départ -> arrivée).
class RouteLines extends StatelessWidget {
  const RouteLines({super.key, required this.pickup, this.dropoff});
  final String pickup;
  final String? dropoff;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget line(IconData icon, Color color, String text) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line(Icons.trip_origin_rounded, AppColors.success, pickup),
        if (dropoff != null && dropoff!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: Container(width: 2, height: 14, color: scheme.outlineVariant),
          ),
          line(Icons.place_rounded, AppColors.danger, dropoff!),
        ],
      ],
    );
  }
}
