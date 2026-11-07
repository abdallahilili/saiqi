import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import 'driver_picker.dart';

/// Création d'une demande pour un client hors application (appel, WhatsApp…), envoyée à 1..n chauffeurs.
class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pickup = TextEditingController();
  final _dropoff = TextEditingController();
  final _notes = TextEditingController();
  final _price = TextEditingController();
  final _passengers = TextEditingController(text: '1');
  String? _serviceId;
  String? _cityId;
  DateTime? _when;
  BookingChannel _channel = BookingChannel.phone;
  Set<String> _drivers = {};
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _pickup, _dropoff, _notes, _price, _passengers]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_drivers.isEmpty) {
      showAppSnack(context, l.selectAtLeastOneDriver, error: true);
      return;
    }
    setState(() => _busy = true);
    Booking? created;
    final ok = await runAction(context, () async {
      created = await ref.read(adminRepositoryProvider).createBooking(
            clientName: _name.text.trim(),
            clientPhone: _phone.text.trim(),
            serviceTypeId: _serviceId!,
            cityId: _cityId!,
            pickupText: _pickup.text.trim(),
            dropoffText: _dropoff.text.trim().isEmpty ? null : _dropoff.text.trim(),
            scheduledAt: _when!,
            passengers: int.tryParse(_passengers.text.trim()) ?? 1,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            price: int.parse(_price.text.trim()),
            channel: _channel,
            driverIds: _drivers.toList(),
          );
    }, successMessage: l.requestCreatedMsg);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok && created != null) {
      context.pushReplacement('/booking/${created!.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.newRequest)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.newRequestIntro, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            AppTextField(
              controller: _name,
              label: l.clientNameLabel,
              icon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty) ? l.vFieldRequired : null,
            ),
            const SizedBox(height: 12),
            PhoneField(controller: _phone, label: l.clientPhoneLabel),
            const SizedBox(height: 12),
            DropdownButtonFormField<BookingChannel>(
              initialValue: _channel,
              decoration: InputDecoration(labelText: l.originChannel, prefixIcon: const Icon(Icons.alt_route_outlined)),
              items: [
                for (final c in BookingChannel.values.where((c) => c != BookingChannel.app))
                  DropdownMenuItem(value: c, child: Text(l.channelLabel(c))),
              ],
              onChanged: (c) => setState(() => _channel = c ?? BookingChannel.phone),
            ),
            const SizedBox(height: 12),
            ServiceTypeDropdown(
              value: _serviceId,
              onChanged: (v) => setState(() {
                _serviceId = v;
                _drivers = {};
              }),
              validator: (v) => v == null ? l.vFieldRequired : null,
            ),
            const SizedBox(height: 12),
            CityDropdown(
              value: _cityId,
              onChanged: (v) => setState(() {
                _cityId = v;
                _drivers = {};
              }),
              validator: (v) => v == null ? l.vFieldRequired : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _pickup,
              label: l.pickup,
              icon: Icons.trip_origin_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? l.vFieldRequired : null,
            ),
            const SizedBox(height: 12),
            AppTextField(controller: _dropoff, label: l.dropoff, icon: Icons.place_outlined),
            const SizedBox(height: 12),
            DateTimeField(
              value: _when,
              onChanged: (d) => setState(() => _when = d),
              validator: (d) => d == null ? l.vFieldRequired : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: IntField(controller: _passengers, label: l.passengers, icon: Icons.people_outline, min: 1, max: 80)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: IntField(controller: _price, label: l.agreedPriceField, icon: Icons.payments_outlined, min: 1)),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(controller: _notes, label: l.notes, icon: Icons.sticky_note_2_outlined, maxLines: 3),
            const SizedBox(height: 22),
            Text(l.chooseDrivers, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            InfoBanner(icon: Icons.groups_2_outlined, message: l.multiDriverHint),
            const SizedBox(height: 10),
            if (_cityId == null || _serviceId == null)
              Text(l.driversInCityHint, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
            else
              DriverMultiPicker(cityId: _cityId, serviceTypeId: _serviceId, selected: _drivers, onChanged: (s) => setState(() => _drivers = s)),
            const SizedBox(height: 22),
            PrimaryButton(
              label: '${l.sendRequest} (${l.selectedCount('${_drivers.length}')})',
              icon: Icons.send_rounded,
              loading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
