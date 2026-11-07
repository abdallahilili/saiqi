import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Course acceptée : détails, contact du client, progression (en route -> démarrer -> terminer), annulation.
class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  bool _busy = false;

  Future<void> _advance(Booking b) async {
    final l = context.l10n;
    final next = switch (b.status) {
      BookingStatus.accepted => BookingStatus.enRoute,
      BookingStatus.enRoute => BookingStatus.inProgress,
      BookingStatus.inProgress => BookingStatus.completed,
      _ => null,
    };
    if (next == null) return;
    if (next == BookingStatus.completed) {
      final ok = await confirmDialog(context, title: l.finishTrip, message: l.areYouSure);
      if (!ok || !mounted) return;
    }
    setState(() => _busy = true);
    await runAction(context, () => ref.read(bookingRepositoryProvider).updateStatus(b.id, next), successMessage: l.statusUpdated);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _cancel(Booking b) async {
    final l = context.l10n;
    final reason = await promptTextDialog(context, title: l.cancelTrip, hint: l.reasonHint);
    if (reason == null || !mounted) return;
    final ok = await confirmDialog(context, title: l.cancelTrip, message: l.cancelTripConfirm, destructive: true);
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    await runAction(context, () => ref.read(bookingRepositoryProvider).cancel(b.id, reason: reason), successMessage: l.tripCancelled);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final trip = ref.watch(tripProvider(widget.bookingId));
    return Scaffold(
      appBar: AppBar(title: Text(l.tripDetails)),
      body: AsyncValueView<Booking>(
        value: trip,
        onRetry: () => ref.invalidate(tripProvider(widget.bookingId)),
        data: (b) {
          final lang = context.lang;
          final action = switch (b.status) {
            BookingStatus.accepted => (l.startEnRoute, Icons.directions_car_rounded),
            BookingStatus.enRoute => (l.startTrip, Icons.play_arrow_rounded),
            BookingStatus.inProgress => (l.finishTrip, Icons.flag_rounded),
            _ => null,
          };
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Timeline(status: b.status),
              const SizedBox(height: 14),
              SectionCard(
                title: b.serviceName(lang),
                trailing: BookingStatusBadge(b.status),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RouteLines(pickup: b.pickupText, dropoff: b.dropoffText),
                    const Divider(height: 24),
                    InfoRow(label: l.scheduledFor, value: Fmt.dateTime(b.scheduledAt, lang), icon: Icons.event_outlined),
                    InfoRow(label: l.city, value: b.cityName(lang), icon: Icons.location_city_outlined),
                    InfoRow(label: l.passengers, value: '${b.passengers}', icon: Icons.people_outline),
                    InfoRow(label: l.agreedPrice, valueWidget: MoneyText(b.price, style: const TextStyle(fontWeight: FontWeight.w900)), icon: Icons.payments_outlined),
                    InfoRow(label: l.channel, value: l.channelLabel(b.channel), icon: Icons.alt_route_outlined),
                    if (b.notes != null && b.notes!.isNotEmpty) InfoRow(label: l.notes, value: b.notes, icon: Icons.sticky_note_2_outlined),
                    if (b.cancelReason != null && b.cancelReason!.isNotEmpty)
                      InfoRow(label: l.reason, value: b.cancelReason, icon: Icons.info_outline),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (b.status.contactVisible) _ClientContact(bookingId: b.id) else const SizedBox.shrink(),
              if (action != null) ...[
                const SizedBox(height: 18),
                PrimaryButton(label: action.$1, icon: action.$2, loading: _busy, onPressed: () => _advance(b)),
              ],
              if (b.status.isActive) ...[
                const SizedBox(height: 10),
                DangerButton(label: l.cancelTrip, icon: Icons.close_rounded, onPressed: _busy ? null : () => _cancel(b)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ClientContact extends ConsumerWidget {
  const _ClientContact({required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final contact = ref.watch(clientContactProvider(bookingId));
    return SectionCard(
      title: l.clientContact,
      child: contact.when(
        loading: () => const Padding(padding: EdgeInsets.all(12), child: LoadingView()),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(clientContactProvider(bookingId))),
        data: (c) => ContactActions(phone: c.phone, name: c.fullName),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    const steps = [BookingStatus.accepted, BookingStatus.enRoute, BookingStatus.inProgress, BookingStatus.completed];
    final idx = steps.indexOf(status);
    final scheme = Theme.of(context).colorScheme;
    if (idx < 0) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: i <= idx ? AppColors.success : scheme.surfaceContainerHighest,
                      child: Icon(i < idx || status == BookingStatus.completed ? Icons.check : Icons.circle, size: 14, color: i <= idx ? Colors.white : scheme.outline),
                    ),
                    const SizedBox(height: 6),
                    Text(l.bookingStatusLabel(steps[i]), textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: i == idx ? FontWeight.w800 : FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
