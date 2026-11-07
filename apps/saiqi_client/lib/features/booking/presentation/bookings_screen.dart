import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final bookings = ref.watch(myBookingsProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.myBookings),
          actions: [NotificationBell(onPressed: () => context.push('/notifications'))],
          bottom: TabBar(tabs: [Tab(text: l.bookingsActive), Tab(text: l.bookingsPast)]),
        ),
        body: AsyncValueView<List<Booking>>(
          value: bookings,
          onRetry: () => ref.invalidate(myBookingsProvider),
          data: (list) {
            final active = list.where((b) => !b.status.isFinal).toList()..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
            final past = list.where((b) => b.status.isFinal).toList();
            return TabBarView(children: [_BookingList(items: active), _BookingList(items: past)]);
          },
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.items});
  final List<Booking> items;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (items.isEmpty) {
      return EmptyView(icon: Icons.event_note_outlined, title: l.noBookingsClient, message: l.noBookingsClientHint);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final b = items[i];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/booking/${b.id}'),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text('${b.serviceName(context.lang)} · ${b.cityName(context.lang)}', style: const TextStyle(fontWeight: FontWeight.w800))),
                    BookingStatusBadge(b.status, dense: true),
                  ]),
                  const SizedBox(height: 8),
                  RouteLines(pickup: b.pickupText, dropoff: b.dropoffText),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.event_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text(Fmt.dateTime(b.scheduledAt, context.lang), style: const TextStyle(fontSize: 12.5)),
                    const Spacer(),
                    MoneyText(b.price, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
