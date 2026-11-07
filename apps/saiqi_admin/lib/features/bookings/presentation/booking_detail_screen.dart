import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';
import 'driver_picker.dart';

final adminBookingProvider = StreamProvider.autoDispose.family<Booking, String>(
  (ref, id) => ref.watch(adminRepositoryProvider).watchBooking(id),
);

final adminOffersProvider = FutureProvider.autoDispose.family<List<BookingOffer>, String>((ref, id) {
  ref.watch(adminBookingProvider(id)); // se recharge quand la réservation change
  return ref.watch(adminRepositoryProvider).bookingOffers(id);
});

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final booking = ref.watch(adminBookingProvider(bookingId));
    return Scaffold(
      appBar: AppBar(title: Text(l.bookingDetail)),
      body: AsyncValueView<Booking>(
        value: booking,
        onRetry: () => ref.invalidate(adminBookingProvider(bookingId)),
        data: (b) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              title: b.serviceName(context.lang),
              trailing: BookingStatusBadge(b.status),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RouteLines(pickup: b.pickupText, dropoff: b.dropoffText),
                  const Divider(height: 24),
                  InfoRow(label: l.scheduledFor, value: Fmt.dateTime(b.scheduledAt, context.lang), icon: Icons.event_outlined),
                  InfoRow(label: l.city, value: b.cityName(context.lang), icon: Icons.location_city_outlined),
                  InfoRow(label: l.passengers, value: '${b.passengers}', icon: Icons.people_outline),
                  InfoRow(label: l.agreedPrice, valueWidget: MoneyText(b.price, style: const TextStyle(fontWeight: FontWeight.w900)), icon: Icons.payments_outlined),
                  InfoRow(label: l.channel, value: l.channelLabel(b.channel), icon: Icons.alt_route_outlined),
                  InfoRow(label: l.createdBy, value: b.createdByAdmin ? l.createdByAdmin : l.roleClient, icon: Icons.badge_outlined),
                  if (b.expiresAt != null && b.status == BookingStatus.pending)
                    InfoRow(label: l.status, valueWidget: CountdownChip(expiresAt: b.expiresAt), icon: Icons.timer_outlined),
                  if (b.notes != null && b.notes!.isNotEmpty) InfoRow(label: l.notes, value: b.notes, icon: Icons.sticky_note_2_outlined),
                  if (b.cancelReason != null && b.cancelReason!.isNotEmpty) InfoRow(label: l.reason, value: b.cancelReason, icon: Icons.info_outline),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: l.client,
              trailing: StatusBadge(label: b.clientId == null ? l.guestClient : l.registeredClient, color: b.clientId == null ? AppColors.neutral : AppColors.success, dense: true),
              child: b.clientPhone == null ? Text(b.clientName) : ContactActions(phone: b.clientPhone!, name: b.clientName),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: l.driver,
              child: b.driverId == null
                  ? Text(l.noDriverAssigned)
                  : (b.driverPhone == null
                      ? Text(b.driverName ?? '—')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ContactActions(phone: b.driverPhone!, name: b.driverName),
                            TextButton.icon(
                              onPressed: () => context.push('/driver/${b.driverId}'),
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: Text(l.driverDetail),
                            ),
                          ],
                        )),
            ),
            const SizedBox(height: 12),
            _Offers(bookingId: bookingId),
            const SizedBox(height: 16),
            _Actions(booking: b),
          ],
        ),
      ),
    );
  }
}

class _Offers extends ConsumerWidget {
  const _Offers({required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final offers = ref.watch(adminOffersProvider(bookingId));
    return SectionCard(
      title: l.offersSent,
      child: offers.when(
        loading: () => const Padding(padding: EdgeInsets.all(12), child: LoadingView()),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(adminOffersProvider(bookingId))),
        data: (list) {
          if (list.isEmpty) return Text(l.noData);
          return Column(
            children: [
              for (final o in list)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.send_outlined),
                  title: Text(o.driverName ?? '—'),
                  subtitle: o.driverPhone == null ? null : Directionality(textDirection: TextDirection.ltr, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(PhoneUtils.pretty(o.driverPhone)))),
                  trailing: StatusBadge(
                    label: switch (o.status) {
                      'accepted' => l.offerStatus_accepted,
                      'declined' => l.offerStatus_declined,
                      'expired' => l.offerStatus_expired,
                      _ => l.offerStatus_pending,
                    },
                    color: switch (o.status) {
                      'accepted' => AppColors.success,
                      'declined' => AppColors.danger,
                      'expired' => AppColors.neutral,
                      _ => AppColors.warning,
                    },
                    dense: true,
                  ),
                  onTap: () => context.push('/driver/${o.driverId}'),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final perms = ref.watch(permsProvider);
    if (!perms.canManageBookings) return const SizedBox.shrink();
    final b = booking;
    final canReassign = const {BookingStatus.pending, BookingStatus.accepted, BookingStatus.enRoute, BookingStatus.expired, BookingStatus.rejected}.contains(b.status);
    final canCancel = !b.status.isFinal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canReassign)
          PrimaryButton(
            label: l.reassignDriver,
            icon: Icons.swap_horiz_rounded,
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => _ReassignSheet(booking: b),
            ),
          ),
        if (canCancel) ...[
          const SizedBox(height: 10),
          DangerButton(
            label: l.cancelBookingAdmin,
            icon: Icons.cancel_outlined,
            onPressed: () async {
              final reason = await promptTextDialog(context, title: l.cancelReasonPrompt, hint: l.reasonHint);
              if (reason == null || !context.mounted) return;
              final ok = await confirmDialog(context, title: l.cancelBookingAdmin, message: l.cancelTripConfirm, destructive: true);
              if (!ok || !context.mounted) return;
              await runAction(context, () => ref.read(adminRepositoryProvider).cancelBooking(b.id, reason: reason), successMessage: l.bookingCancelledMsg);
            },
          ),
        ],
      ],
    );
  }
}

class _ReassignSheet extends ConsumerStatefulWidget {
  const _ReassignSheet({required this.booking});
  final Booking booking;

  @override
  ConsumerState<_ReassignSheet> createState() => _ReassignSheetState();
}

class _ReassignSheetState extends ConsumerState<_ReassignSheet> {
  Set<String> _selected = {};
  bool _busy = false;

  Future<void> _send() async {
    final l = context.l10n;
    setState(() => _busy = true);
    final ok = await runAction(
      context,
      () => ref.read(adminRepositoryProvider).reassignBooking(widget.booking.id, _selected.toList()),
      successMessage: l.reassignedMsg,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final b = widget.booking;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(l.reassignDriver, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(l.multiDriverHint, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12.5)),
            const SizedBox(height: 10),
            DriverMultiPicker(cityId: b.cityId, serviceTypeId: b.serviceTypeId, selected: _selected, onChanged: (s) => setState(() => _selected = s)),
            const SizedBox(height: 16),
            PrimaryButton(
              label: '${l.sendRequest} (${l.selectedCount('${_selected.length}')})',
              loading: _busy,
              onPressed: _selected.isEmpty ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
