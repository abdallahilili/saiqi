import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final bookings = ref.watch(driverBookingsProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.myTrips),
          bottom: TabBar(tabs: [Tab(text: l.tripsUpcoming), Tab(text: l.tripsHistory)]),
        ),
        body: AsyncValueView<List<Booking>>(
          value: bookings,
          onRetry: () => ref.invalidate(driverBookingsProvider),
          data: (list) {
            final upcoming = list.where((b) => b.status.isActive).toList()..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
            final history = list.where((b) => !b.status.isActive).toList();
            return TabBarView(children: [_TripList(trips: upcoming), _TripList(trips: history)]);
          },
        ),
      ),
    );
  }
}

class _TripList extends StatelessWidget {
  const _TripList({required this.trips});
  final List<Booking> trips;

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) return EmptyView(icon: Icons.route_outlined, title: context.l10n.noTrips);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => TripCard(booking: trips[i]),
    );
  }
}

class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final b = booking;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/trip/${b.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(b.serviceName(lang), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                  BookingStatusBadge(b.status, dense: true),
                ],
              ),
              const SizedBox(height: 8),
              RouteLines(pickup: b.pickupText, dropoff: b.dropoffText),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(Fmt.dateTime(b.scheduledAt, lang)),
                  const Spacer(),
                  MoneyText(b.price, style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
