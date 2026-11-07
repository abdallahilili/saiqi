import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Demande de réservation à un chauffeur : service, date/heure, départ/arrivée, passagers, note.
class BookingFormScreen extends ConsumerStatefulWidget {
  const BookingFormScreen({super.key, required this.driverId, this.serviceTypeId, this.cityId});
  final String driverId;
  final String? serviceTypeId;
  final String? cityId;

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _pickup = TextEditingController();
  final _dropoff = TextEditingController();
  final _notes = TextEditingController();
  final _passengers = TextEditingController(text: '1');
  String? _serviceId;
  String? _cityId;
  DateTime? _when;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _serviceId = widget.serviceTypeId;
    _cityId = widget.cityId ?? ref.read(effectiveCityProvider);
  }

  @override
  void dispose() {
    for (final c in [_name, _pickup, _dropoff, _notes, _passengers]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(PublicDriver driver) async {
    final l = context.l10n;
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    Booking? created;
    final ok = await runAction(context, () async {
      final profile = ref.read(profileProvider).value;
      if ((profile?.fullName ?? '').trim().isEmpty && _name.text.trim().isNotEmpty) {
        await ref.read(authRepositoryProvider).updateProfile(fullName: _name.text.trim());
        await ref.read(profileProvider.notifier).reload();
      }
      created = await ref.read(bookingRepositoryProvider).createBooking(
            driverId: driver.driverId,
            serviceTypeId: _serviceId!,
            cityId: _cityId!,
            pickupText: _pickup.text.trim(),
            dropoffText: _dropoff.text.trim().isEmpty ? null : _dropoff.text.trim(),
            scheduledAt: _when!,
            passengers: int.parse(_passengers.text.trim()),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
    }, successMessage: l.bookingSentMsg);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok && created != null) {
      ref.invalidate(myBookingsProvider);
      context.go('/bookings');
      unawaited(context.push('/booking/${created!.id}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final driver = ref.watch(publicDriverProvider(widget.driverId));
    final services = ref.watch(publicServicesProvider(widget.driverId));
    final profile = ref.watch(profileProvider).value;
    final needsName = (profile?.fullName ?? '').trim().isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l.bookingRequestTitle)),
      body: AsyncValueView<PublicDriver?>(
        value: driver,
        onRetry: () => ref.invalidate(publicDriverProvider(widget.driverId)),
        data: (d) {
          if (d == null) return EmptyView(icon: Icons.person_off_outlined, title: l.driverNotFoundClient);
          final all = services.value ?? const <PublicDriverService>[];
          final inCity = all.where((s) => _cityId == null || s.cityIds.contains(_cityId)).toList();
          _serviceId ??= inCity.firstOrNull?.serviceTypeId;
          final chosen = inCity.where((s) => s.serviceTypeId == _serviceId).firstOrNull;
          final maxSeats = d.seats ?? 80;

          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DriverCard(driver: d),
                const SizedBox(height: 16),
                if (needsName) ...[
                  AppTextField(
                    controller: _name,
                    label: l.fullNameLabel,
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().length < 3) ? l.vFieldRequired : null,
                  ),
                  Padding(padding: const EdgeInsets.only(top: 6, bottom: 12), child: Text(l.completeNameFirst, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                ],
                CityDropdown(
                  value: _cityId,
                  onChanged: (v) => setState(() {
                    _cityId = v;
                    _serviceId = null;
                  }),
                  validator: (v) => v == null ? l.vFieldRequired : null,
                ),
                const SizedBox(height: 12),
                ServiceTypeDropdown(
                  value: _serviceId,
                  onlyIds: inCity.map((s) => s.serviceTypeId).toSet(),
                  onChanged: (v) => setState(() => _serviceId = v),
                  validator: (v) => v == null ? l.serviceNotInCity : null,
                ),
                const SizedBox(height: 12),
                DateTimeField(
                  value: _when,
                  onChanged: (v) => setState(() => _when = v),
                  validator: (v) => v == null ? l.vFieldRequired : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _pickup,
                  label: l.pickup,
                  hint: l.pickupHint,
                  icon: Icons.trip_origin_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? l.vFieldRequired : null,
                ),
                const SizedBox(height: 12),
                AppTextField(controller: _dropoff, label: l.dropoff, icon: Icons.place_outlined),
                const SizedBox(height: 12),
                IntField(controller: _passengers, label: l.passengers, icon: Icons.people_outline, min: 1, max: maxSeats),
                Padding(padding: const EdgeInsets.only(top: 6, bottom: 12), child: Text(l.maxPassengersHint('$maxSeats'), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                AppTextField(controller: _notes, label: l.notes, icon: Icons.sticky_note_2_outlined, maxLines: 3),
                const SizedBox(height: 18),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.estimatedPrice, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(
                          chosen == null ? '—' : '${Fmt.mru(chosen.price, lang)} ${l.priceUnitLabel(chosen.priceUnit)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(l.payDriverDirectly, style: const TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(label: l.submitBooking, icon: Icons.send_rounded, loading: _busy, onPressed: chosen == null ? null : () => _submit(d)),
              ],
            ),
          );
        },
      ),
    );
  }
}
