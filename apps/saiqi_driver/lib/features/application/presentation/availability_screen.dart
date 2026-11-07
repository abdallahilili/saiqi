import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

class _Day {
  _Day({required this.enabled, required this.start, required this.end});
  bool enabled;
  String start;
  String end;
}

/// Jours et horaires de travail (un créneau par jour, lundi = 1 … dimanche = 7).
class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  final Map<int, _Day> _days = {for (var d = 1; d <= 7; d++) d: _Day(enabled: d <= 6, start: '08:00', end: '20:00')};
  bool _loaded = false;
  bool _saving = false;

  void _fill(List<DriverAvailability> slots) {
    if (_loaded) return;
    _loaded = true;
    if (slots.isEmpty) return;
    for (final d in _days.values) {
      d.enabled = false;
    }
    for (final s in slots) {
      _days[s.weekday] = _Day(enabled: true, start: s.start, end: s.end);
    }
  }

  Future<void> _pickTime(int weekday, bool start) async {
    final day = _days[weekday]!;
    final current = (start ? day.start : day.end).split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(current[0]), minute: int.parse(current[1])),
      builder: (ctx, child) => MediaQuery(data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (picked == null) return;
    final text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() => start ? day.start = text : day.end = text);
  }

  Future<void> _save() async {
    final l = context.l10n;
    final slots = <DriverAvailability>[];
    for (final e in _days.entries) {
      if (!e.value.enabled) continue;
      if (e.value.start.compareTo(e.value.end) >= 0) {
        showAppSnack(context, '${l.weekdayLabel(e.key)} : ${l.invalidTimeRange}', error: true);
        return;
      }
      slots.add(DriverAvailability(weekday: e.key, start: e.value.start, end: e.value.end));
    }
    final driverId = ref.read(driverIdProvider);
    if (driverId == null) return;
    setState(() => _saving = true);
    final ok = await runAction(context, () async {
      await ref.read(driverRepositoryProvider).replaceAvailability(driverId, slots);
      ref.invalidate(availabilityProvider);
    }, successMessage: l.saved);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final slots = ref.watch(availabilityProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.stepAvailability)),
      body: AsyncValueView<List<DriverAvailability>>(
        value: slots,
        onRetry: () => ref.invalidate(availabilityProvider),
        data: (list) {
          _fill(list);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l.availabilityIntro, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 14),
              for (var weekday = 1; weekday <= 7; weekday++) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(l.weekdayLabel(weekday), style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        if (_days[weekday]!.enabled) ...[
                          ActionChip(label: Text('${l.timeFrom} ${_days[weekday]!.start}'), onPressed: () => _pickTime(weekday, true)),
                          const SizedBox(width: 6),
                          ActionChip(label: Text('${l.timeTo} ${_days[weekday]!.end}'), onPressed: () => _pickTime(weekday, false)),
                        ] else
                          Text(l.dayOff, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        Switch(value: _days[weekday]!.enabled, onChanged: (v) => setState(() => _days[weekday]!.enabled = v)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 12),
              PrimaryButton(label: l.save, loading: _saving, onPressed: _save),
            ],
          );
        },
      ),
    );
  }
}
