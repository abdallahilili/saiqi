import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

typedef BookingFilter = ({BookingStatus? status, String? cityId, BookingChannel? channel, DateTime? day});

final adminBookingsProvider = FutureProvider.autoDispose.family<List<Booking>, BookingFilter>((ref, f) {
  ref.watch(adminLiveTickProvider);
  final from = f.day == null ? null : DateTime(f.day!.year, f.day!.month, f.day!.day);
  return ref.watch(adminRepositoryProvider).listBookings(
        status: f.status,
        cityId: f.cityId,
        channel: f.channel,
        from: from,
        to: from?.add(const Duration(days: 1)),
      );
});

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  BookingStatus? _status;
  String? _cityId;
  BookingChannel? _channel;
  DateTime? _day;
  String _query = '';

  BookingFilter get _filter => (status: _status, cityId: _cityId, channel: _channel, day: _day);
  bool get _hasFilter => _status != null || _cityId != null || _channel != null || _day != null;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bookings = ref.watch(adminBookingsProvider(_filter));
    final perms = ref.watch(permsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.bookingsTitle)),
      floatingActionButton: perms.canManageBookings
          ? FloatingActionButton.extended(onPressed: () => context.push('/booking/new'), icon: const Icon(Icons.add_call), label: Text(l.createRequest))
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: InputDecoration(hintText: l.searchPeople, prefixIcon: const Icon(Icons.search)),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _menuChip<BookingStatus>(
                  label: _status == null ? l.filterStatus : l.bookingStatusLabel(_status!),
                  active: _status != null,
                  values: BookingStatus.values,
                  labelOf: l.bookingStatusLabel,
                  onSelected: (v) => setState(() => _status = v),
                ),
                _menuChip<BookingChannel>(
                  label: _channel == null ? l.filterChannel : l.channelLabel(_channel!),
                  active: _channel != null,
                  values: BookingChannel.values,
                  labelOf: l.channelLabel,
                  onSelected: (v) => setState(() => _channel = v),
                ),
                _CityChip(value: _cityId, onChanged: (v) => setState(() => _cityId = v)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    avatar: const Icon(Icons.event_outlined, size: 18),
                    label: Text(_day == null ? l.filterDate : Fmt.date(_day!, context.lang)),
                    backgroundColor: _day != null ? Theme.of(context).colorScheme.primaryContainer : null,
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _day ?? DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _day = d);
                    },
                  ),
                ),
                if (_hasFilter)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      avatar: const Icon(Icons.clear, size: 18),
                      label: Text(l.clearFilters),
                      onPressed: () => setState(() {
                        _status = null;
                        _cityId = null;
                        _channel = null;
                        _day = null;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(adminBookingsProvider(_filter)),
              child: AsyncValueView<List<Booking>>(
                value: bookings,
                onRetry: () => ref.invalidate(adminBookingsProvider(_filter)),
                data: (all) {
                  final list = _query.isEmpty
                      ? all
                      : all
                          .where((b) =>
                              b.clientName.toLowerCase().contains(_query) ||
                              (b.clientPhone ?? '').contains(_query) ||
                              (b.driverName ?? '').toLowerCase().contains(_query))
                          .toList();
                  if (list.isEmpty) return EmptyView(icon: Icons.event_busy_outlined, title: l.noBookings);
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => BookingTile(booking: list[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuChip<T>({
    required String label,
    required bool active,
    required List<T> values,
    required String Function(T) labelOf,
    required ValueChanged<T?> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: PopupMenuButton<T?>(
        onSelected: onSelected,
        itemBuilder: (_) => [
          PopupMenuItem<T?>(value: null, child: Text(context.l10n.all)),
          for (final v in values) PopupMenuItem<T?>(value: v, child: Text(labelOf(v))),
        ],
        child: Chip(
          label: Text(label),
          backgroundColor: active ? Theme.of(context).colorScheme.primaryContainer : null,
          deleteIcon: const Icon(Icons.arrow_drop_down),
          onDeleted: null,
        ),
      ),
    );
  }
}

class _CityChip extends ConsumerWidget {
  const _CityChip({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cities = ref.watch(citiesProvider).value ?? const <City>[];
    final current = cities.where((c) => c.id == value).firstOrNull;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: PopupMenuButton<String?>(
        onSelected: onChanged,
        itemBuilder: (_) => [
          PopupMenuItem<String?>(value: null, child: Text(l.all)),
          for (final c in cities) PopupMenuItem<String?>(value: c.id, child: Text(c.name(context.lang))),
        ],
        child: Chip(
          label: Text(current?.name(context.lang) ?? l.filterCity),
          backgroundColor: current != null ? Theme.of(context).colorScheme.primaryContainer : null,
        ),
      ),
    );
  }
}

class BookingTile extends StatelessWidget {
  const BookingTile({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final b = booking;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/booking/${b.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('${b.serviceName(lang)} · ${b.cityName(lang)}', style: const TextStyle(fontWeight: FontWeight.w800))),
                  BookingStatusBadge(b.status, dense: true),
                ],
              ),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(b.clientName)),
                MoneyText(b.price, style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.directions_car_outlined, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(b.driverName ?? l.noDriverAssigned, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
              ]),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(Fmt.dateTime(b.scheduledAt, lang), style: const TextStyle(fontSize: 12.5)),
                  const Spacer(),
                  StatusBadge(label: l.channelLabel(b.channel), color: AppColors.neutral, dense: true),
                  if (b.createdByAdmin) ...[const SizedBox(width: 6), StatusBadge(label: l.createdByAdmin, color: AppColors.info, dense: true)],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
