import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Résultats de recherche : filtres (prix, note, véhicule, places), tri, carte chauffeur.
class DriversScreen extends ConsumerStatefulWidget {
  const DriversScreen({super.key, this.serviceTypeId, this.cityId});
  final String? serviceTypeId;
  final String? cityId;

  @override
  ConsumerState<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends ConsumerState<DriversScreen> {
  late String? _cityId = widget.cityId ?? ref.read(effectiveCityProvider);
  late String? _serviceId = widget.serviceTypeId;
  int? _minPrice;
  int? _maxPrice;
  double? _minRating;
  int? _minSeats;
  String? _vehicleType;
  bool _onlyAvailable = true;
  String _sort = 'rating';

  DriverQuery get _query => (
        cityId: _cityId,
        serviceTypeId: _serviceId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minRating: _minRating,
        minSeats: _minSeats,
        vehicleType: _vehicleType,
        onlyAvailable: _onlyAvailable,
        sort: _sort,
      );

  Future<void> _openFilters() async {
    final res = await showModalBottomSheet<DriverQuery>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _FiltersSheet(initial: _query),
    );
    if (res == null) return;
    setState(() {
      _minPrice = res.minPrice;
      _maxPrice = res.maxPrice;
      _minRating = res.minRating;
      _minSeats = res.minSeats;
      _vehicleType = res.vehicleType;
      _onlyAvailable = res.onlyAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final query = _query;
    final results = ref.watch(driversSearchProvider(query));
    final favorites = ref.watch(favoritesProvider).value ?? const <String>{};
    final cities = ref.watch(citiesProvider).value ?? const <City>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.driversListTitle),
        actions: [
          PopupMenuButton<String>(
            tooltip: l.sortBy,
            icon: const Icon(Icons.sort_rounded),
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'rating', child: Text(l.sort_rating)),
              PopupMenuItem(value: 'price_asc', child: Text(l.sort_priceAsc)),
              PopupMenuItem(value: 'price_desc', child: Text(l.sort_priceDesc)),
              PopupMenuItem(value: 'trips', child: Text(l.sort_trips)),
            ],
          ),
          IconButton(
            tooltip: l.filters,
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: query.activeFilterCount > 0,
              label: Text('${query.activeFilterCount}'),
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(child: CityDropdown(value: _cityId, onChanged: (v) => setState(() => _cityId = v))),
                const SizedBox(width: 10),
                Expanded(child: ServiceTypeDropdown(value: _serviceId, allowAll: true, onChanged: (v) => setState(() => _serviceId = v))),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(driversSearchProvider(query)),
              child: AsyncValueView<List<PublicDriver>>(
                value: results,
                onRetry: () => ref.invalidate(driversSearchProvider(query)),
                isEmpty: (list) => list.isEmpty,
                emptyTitle: l.noDriversFound,
                emptyMessage: l.noDriversHint,
                emptyIcon: Icons.person_search_outlined,
                data: (list) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: list.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Text(l.driversFoundCount('${list.length}'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
                    }
                    final d = list[i - 1];
                    return DriverCard(
                      driver: d,
                      isFavorite: favorites.contains(d.driverId),
                      cityName: cities.where((c) => c.id == d.cityId).firstOrNull?.name(context.lang),
                      onTap: () => context.push('/driver/${d.driverId}?${_params(d)}'),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _params(PublicDriver d) => [
        if (_cityId != null) 'city=$_cityId',
        if ((_serviceId ?? d.serviceTypeId) != null) 'service=${_serviceId ?? d.serviceTypeId}',
      ].join('&');
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.initial});
  final DriverQuery initial;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late final TextEditingController _min = TextEditingController(text: widget.initial.minPrice?.toString() ?? '');
  late final TextEditingController _max = TextEditingController(text: widget.initial.maxPrice?.toString() ?? '');
  late double? _rating = widget.initial.minRating;
  late int? _seats = widget.initial.minSeats;
  late String? _vehicle = widget.initial.vehicleType;
  late bool _onlyAvailable = widget.initial.onlyAvailable;

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  Widget _choices<T>(List<T?> values, T? current, String Function(T?) label, ValueChanged<T?> onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in values)
          ChoiceChip(label: Text(label(v)), selected: current == v, onSelected: (_) => setState(() => onSelect(v))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final num = FilteringTextInputFormatter.digitsOnly;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.filters, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(l.priceRangeLabel, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: _min, keyboardType: TextInputType.number, inputFormatters: [num], textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: l.minPriceField))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _max, keyboardType: TextInputType.number, inputFormatters: [num], textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: l.maxPriceField))),
              ],
            ),
            const SizedBox(height: 16),
            Text(l.minRatingLabel, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _choices<double>([null, 3, 4, 4.5], _rating, (v) => v == null ? l.anyValue : '${v.toString().replaceAll('.0', '')}★', (v) => _rating = v),
            const SizedBox(height: 16),
            Text(l.minSeatsLabel, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _choices<int>([null, 4, 6, 8, 15], _seats, (v) => v == null ? l.anyValue : '$v+', (v) => _seats = v),
            const SizedBox(height: 16),
            Text(l.vehicleType, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _choices<String>([null, ...vehicleTypes], _vehicle, (v) => v == null ? l.anyValue : l.vehicleTypeLabel(v), (v) => _vehicle = v),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.showUnavailable),
              value: !_onlyAvailable,
              onChanged: (v) => setState(() => _onlyAvailable = !v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: l.reset,
                    onPressed: () => Navigator.pop<DriverQuery>(context, (
                      cityId: widget.initial.cityId,
                      serviceTypeId: widget.initial.serviceTypeId,
                      minPrice: null,
                      maxPrice: null,
                      minRating: null,
                      minSeats: null,
                      vehicleType: null,
                      onlyAvailable: true,
                      sort: widget.initial.sort,
                    )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: l.apply,
                    onPressed: () => Navigator.pop<DriverQuery>(context, (
                      cityId: widget.initial.cityId,
                      serviceTypeId: widget.initial.serviceTypeId,
                      minPrice: int.tryParse(_min.text.trim()),
                      maxPrice: int.tryParse(_max.text.trim()),
                      minRating: _rating,
                      minSeats: _seats,
                      vehicleType: _vehicle,
                      onlyAvailable: _onlyAvailable,
                      sort: widget.initial.sort,
                    )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
