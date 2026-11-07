import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';

typedef _PickerQuery = ({String? cityId, String? serviceTypeId, bool onlyAvailable});

final _pickerDriversProvider = FutureProvider.autoDispose.family<List<PublicDriver>, _PickerQuery>((ref, q) {
  return ref.watch(publicDriverRepositoryProvider).search(
        cityId: q.cityId,
        serviceTypeId: q.serviceTypeId,
        onlyAvailable: q.onlyAvailable,
        limit: 100,
      );
});

/// Sélection d'un ou plusieurs chauffeurs (approuvés, de la ville / du service choisis).
class DriverMultiPicker extends ConsumerStatefulWidget {
  const DriverMultiPicker({
    super.key,
    required this.cityId,
    required this.serviceTypeId,
    required this.selected,
    required this.onChanged,
  });

  final String? cityId;
  final String? serviceTypeId;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  ConsumerState<DriverMultiPicker> createState() => _DriverMultiPickerState();
}

class _DriverMultiPickerState extends ConsumerState<DriverMultiPicker> {
  bool _onlyAvailable = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final query = (cityId: widget.cityId, serviceTypeId: widget.serviceTypeId, onlyAvailable: _onlyAvailable);
    final drivers = ref.watch(_pickerDriversProvider(query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.driversInCityHint, style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant))),
            const SizedBox(width: 8),
            FilterChip(label: Text(l.onlyAvailable), selected: _onlyAvailable, onSelected: (v) => setState(() => _onlyAvailable = v)),
          ],
        ),
        const SizedBox(height: 8),
        drivers.when(
          loading: () => const Padding(padding: EdgeInsets.all(20), child: LoadingView()),
          error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(_pickerDriversProvider(query))),
          data: (list) {
            if (list.isEmpty) return Padding(padding: const EdgeInsets.all(16), child: Text(l.noDriversFound));
            final allSelected = list.every((d) => widget.selected.contains(d.driverId));
            return Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => widget.onChanged(allSelected ? {} : list.map((d) => d.driverId).toSet()),
                    child: Text(allSelected ? l.reset : l.selectAll),
                  ),
                ),
                for (final d in list)
                  CheckboxListTile(
                    value: widget.selected.contains(d.driverId),
                    onChanged: (v) {
                      final next = {...widget.selected};
                      v == true ? next.add(d.driverId) : next.remove(d.driverId);
                      widget.onChanged(next);
                    },
                    secondary: UserAvatar(url: d.avatarUrl, name: d.fullName ?? '', radius: 22),
                    title: Text(d.fullName ?? '—', style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text([
                      if (d.vehicleTitle.isNotEmpty) d.vehicleTitle,
                      if (d.price != null) Fmt.mru(d.price!, context.lang),
                      d.isAvailable ? l.availableNow : l.unavailableNow,
                    ].join(' · ')),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
