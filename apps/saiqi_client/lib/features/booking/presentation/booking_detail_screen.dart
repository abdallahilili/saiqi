import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Autres chauffeurs proposés quand la demande est refusée / expirée.
final _alternativesProvider = FutureProvider.autoDispose.family<List<PublicDriver>, Booking>((ref, b) async {
  final list = await ref.watch(publicDriverRepositoryProvider).search(cityId: b.cityId, serviceTypeId: b.serviceTypeId, limit: 8);
  return list.where((d) => d.driverId != b.driverId).take(5).toList();
});

/// Suivi en temps réel : en attente -> acceptée -> en route -> en cours -> terminée.
class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final booking = ref.watch(bookingProvider(bookingId));
    return Scaffold(
      appBar: AppBar(title: Text(l.trackBooking)),
      body: AsyncValueView<Booking>(
        value: booking,
        onRetry: () => ref.invalidate(bookingProvider(bookingId)),
        data: (b) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatusCard(booking: b),
            const SizedBox(height: 12),
            if (b.status == BookingStatus.rejected || b.status == BookingStatus.expired) ...[
              _Alternatives(booking: b),
              const SizedBox(height: 12),
            ],
            if (b.driverId != null) ...[
              _DriverBlock(booking: b),
              const SizedBox(height: 12),
            ],
            SectionCard(
              title: b.serviceName(context.lang),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RouteLines(pickup: b.pickupText, dropoff: b.dropoffText),
                  const Divider(height: 24),
                  InfoRow(label: l.scheduledFor, value: Fmt.dateTime(b.scheduledAt, context.lang), icon: Icons.event_outlined),
                  InfoRow(label: l.city, value: b.cityName(context.lang), icon: Icons.location_city_outlined),
                  InfoRow(label: l.passengers, value: '${b.passengers}', icon: Icons.people_outline),
                  InfoRow(label: l.price, valueWidget: MoneyText(b.price, style: const TextStyle(fontWeight: FontWeight.w900)), icon: Icons.payments_outlined),
                  if (b.notes != null && b.notes!.isNotEmpty) InfoRow(label: l.notes, value: b.notes, icon: Icons.sticky_note_2_outlined),
                  if (b.cancelReason != null && b.cancelReason!.isNotEmpty) InfoRow(label: l.reason, value: b.cancelReason, icon: Icons.info_outline),
                ],
              ),
            ),
            if (b.status == BookingStatus.completed) ...[
              const SizedBox(height: 12),
              _ReviewBlock(booking: b),
            ],
            const SizedBox(height: 16),
            _Actions(booking: b),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final b = booking;
    const steps = [BookingStatus.pending, BookingStatus.accepted, BookingStatus.enRoute, BookingStatus.inProgress, BookingStatus.completed];
    final idx = steps.indexOf(b.status);
    final scheme = Theme.of(context).colorScheme;
    final ended = idx < 0;
    final color = bookingStatusColor(b.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(l.bookingStatusLabel(b.status), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color))),
              if (b.status == BookingStatus.pending) CountdownChip(expiresAt: b.expiresAt),
            ]),
            if (b.status == BookingStatus.pending) ...[
              const SizedBox(height: 6),
              Text(l.waitingDriverHint, style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 10),
              const LinearProgressIndicator(),
            ],
            if (!ended) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    Expanded(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: i <= idx ? AppColors.success : scheme.surfaceContainerHighest,
                            child: Icon(i < idx || b.status == BookingStatus.completed ? Icons.check : Icons.circle, size: 13, color: i <= idx ? Colors.white : scheme.outline),
                          ),
                          const SizedBox(height: 4),
                          Text(l.bookingStatusLabel(steps[i]), textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: 10, fontWeight: i == idx ? FontWeight.w800 : FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ] else if (b.status == BookingStatus.rejected) ...[
              const SizedBox(height: 6),
              Text(l.bookingRejectedHint),
            ] else if (b.status == BookingStatus.expired) ...[
              const SizedBox(height: 6),
              Text(l.bookingExpiredHint),
            ],
          ],
        ),
      ),
    );
  }
}

class _Alternatives extends ConsumerWidget {
  const _Alternatives({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final alts = ref.watch(_alternativesProvider(booking));
    return SectionCard(
      title: l.suggestOthers,
      child: alts.when(
        loading: () => const Padding(padding: EdgeInsets.all(12), child: LoadingView()),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(_alternativesProvider(booking))),
        data: (list) {
          if (list.isEmpty) return Text(l.noAlternatives);
          return Column(
            children: [
              for (final d in list) ...[
                DriverCard(
                  driver: d,
                  onTap: () => context.push('/driver/${d.driverId}?city=${booking.cityId}&service=${booking.serviceTypeId}'),
                ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DriverBlock extends ConsumerWidget {
  const _DriverBlock({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final info = ref.watch(bookingDriverProvider(booking.id));
    return SectionCard(
      title: l.yourDriver,
      child: info.when(
        loading: () => const Padding(padding: EdgeInsets.all(12), child: LoadingView()),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(bookingDriverProvider(booking.id))),
        data: (d) {
          if (d == null) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.push('/driver/${d.driverId}'),
                child: Row(
                  children: [
                    UserAvatar(url: d.avatarUrl, name: d.fullName ?? '', radius: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.fullName ?? '—', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          if (d.ratingCount > 0) StarRating(value: d.ratingAvg, size: 16, showValue: true, count: d.ratingCount),
                          if (d.vehicleTitle.isNotEmpty)
                            Text([d.vehicleTitle, d.vehicleColor, d.vehiclePlate].whereType<String>().where((s) => s.isNotEmpty).join(' · '), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const DirectionalChevron(),
                  ],
                ),
              ),
              const Divider(height: 24),
              if (booking.status.contactVisible)
                _Contact(bookingId: booking.id)
              else
                Text(l.contactAfterAccept, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          );
        },
      ),
    );
  }
}

class _Contact extends ConsumerWidget {
  const _Contact({required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = ref.watch(driverContactProvider(bookingId));
    return contact.when(
      loading: () => const Padding(padding: EdgeInsets.all(8), child: LoadingView()),
      error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(driverContactProvider(bookingId))),
      data: (c) => ContactActions(phone: c.phone),
    );
  }
}

class _ReviewBlock extends ConsumerStatefulWidget {
  const _ReviewBlock({required this.booking});
  final Booking booking;

  @override
  ConsumerState<_ReviewBlock> createState() => _ReviewBlockState();
}

class _ReviewBlockState extends ConsumerState<_ReviewBlock> {
  int _rating = 0;
  final _comment = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    if (_rating == 0) {
      showAppSnack(context, l.tapStarToRate, error: true);
      return;
    }
    setState(() => _busy = true);
    final ok = await runAction(
      context,
      () => ref.read(bookingRepositoryProvider).submitReview(widget.booking.id, _rating, _comment.text.trim().isEmpty ? null : _comment.text.trim()),
      successMessage: l.reviewThanks,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) ref.invalidate(reviewForBookingProvider(widget.booking.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final existing = ref.watch(reviewForBookingProvider(widget.booking.id));
    return existing.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: LoadingView()),
      error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(reviewForBookingProvider(widget.booking.id))),
      data: (r) {
        if (r != null) {
          return SectionCard(
            title: l.yourReview,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StarRating(value: r.rating.toDouble(), size: 24),
                if (r.comment != null && r.comment!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(r.comment!)),
              ],
            ),
          );
        }
        return SectionCard(
          title: l.rateDriver,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RatingInput(value: _rating, onChanged: (v) => setState(() => _rating = v)),
              const SizedBox(height: 10),
              AppTextField(controller: _comment, label: l.ratingCommentHint, maxLines: 3, maxLength: 500),
              const SizedBox(height: 10),
              PrimaryButton(label: l.submitReview, icon: Icons.star_rounded, loading: _busy, onPressed: _submit),
            ],
          ),
        );
      },
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final b = booking;
    final canCancel = b.status == BookingStatus.pending || b.status == BookingStatus.accepted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canCancel)
          DangerButton(
            label: l.cancelBooking,
            icon: Icons.close_rounded,
            onPressed: () async {
              final reason = await promptTextDialog(context, title: l.cancelBooking, hint: l.reasonHint, required: false);
              if (reason == null || !context.mounted) return;
              final ok = await confirmDialog(context, title: l.cancelBooking, message: l.cancelBookingConfirm, destructive: true);
              if (!ok || !context.mounted) return;
              await runAction(
                context,
                () => ref.read(bookingRepositoryProvider).cancel(b.id, reason: reason.isEmpty ? null : reason),
                successMessage: l.bookingCancelledClient,
              );
            },
          )
        else if (b.status == BookingStatus.enRoute || b.status == BookingStatus.inProgress)
          Text(l.cancelUnavailableEnRoute, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        if (b.driverId != null && b.status != BookingStatus.pending) ...[
          const SizedBox(height: 10),
          SecondaryButton(
            label: l.fileComplaint,
            icon: Icons.report_gmailerrorred_outlined,
            onPressed: () async {
              final text = await promptTextDialog(context, title: l.fileComplaint, hint: l.complaintHint, maxLines: 5);
              if (text == null || !context.mounted) return;
              await runAction(context, () => ref.read(bookingRepositoryProvider).fileComplaint(bookingId: b.id, text: text), successMessage: l.complaintSentMsg);
            },
          ),
        ],
      ],
    );
  }
}
