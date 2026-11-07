import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Véhicule : caractéristiques + jusqu'à 5 photos (bucket public vehicle-photos).
class VehicleScreen extends ConsumerStatefulWidget {
  const VehicleScreen({super.key});

  @override
  ConsumerState<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends ConsumerState<VehicleScreen> {
  final _form = GlobalKey<FormState>();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _color = TextEditingController();
  final _seats = TextEditingController(text: '4');
  final _plate = TextEditingController();
  String _type = 'sedan';
  List<String> _photos = [];
  bool _loaded = false;
  bool _saving = false;
  bool _uploading = false;

  @override
  void dispose() {
    for (final c in [_brand, _model, _year, _color, _seats, _plate]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(Vehicle? v) {
    if (_loaded) return;
    _loaded = true;
    if (v == null) return;
    _brand.text = v.brand;
    _model.text = v.model;
    _year.text = v.year?.toString() ?? '';
    _color.text = v.color ?? '';
    _seats.text = v.seats.toString();
    _plate.text = v.plate;
    _type = v.vehicleType;
    _photos = [...v.photoPaths];
  }

  Vehicle _build(String driverId) => Vehicle(
        driverId: driverId,
        vehicleType: _type,
        brand: _brand.text.trim(),
        model: _model.text.trim(),
        year: int.tryParse(_year.text.trim()),
        color: _color.text.trim().isEmpty ? null : _color.text.trim(),
        seats: int.parse(_seats.text.trim()),
        plate: _plate.text.trim(),
        photoPaths: _photos,
      );

  Future<void> _save({bool pop = true}) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final driverId = ref.read(driverIdProvider);
    if (driverId == null) return;
    setState(() => _saving = true);
    final ok = await runAction(context, () async {
      await ref.read(driverRepositoryProvider).saveVehicle(_build(driverId));
      ref.invalidate(vehicleProvider);
    }, successMessage: context.l10n.saved);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok && pop) context.pop();
  }

  Future<void> _addPhoto() async {
    final l = context.l10n;
    if (_photos.length >= 5) {
      showAppSnack(context, l.maxPhotosReached, error: true);
      return;
    }
    if (!(_form.currentState?.validate() ?? false)) return; // le véhicule doit exister avant d'ajouter des photos
    final file = await pickImageSheet(context, ref);
    if (file == null || !mounted) return;
    setState(() => _uploading = true);
    try {
      final path = await ref.read(storageRepositoryProvider).uploadImage(bucket: Buckets.vehiclePhotos, folder: 'vehicle', file: file);
      _photos = [..._photos, path];
      await _save(pop: false);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _removePhoto(String path) async {
    setState(() => _photos = _photos.where((p) => p != path).toList());
    await _save(pop: false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final vehicle = ref.watch(vehicleProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.vehicleTitle)),
      body: vehicle.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(vehicleProvider)),
        data: (v) {
          _fill(v);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _form,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: InputDecoration(labelText: l.vehicleType, prefixIcon: const Icon(Icons.directions_car_outlined)),
                      items: [for (final t in vehicleTypes) DropdownMenuItem(value: t, child: Text(l.vehicleTypeLabel(t)))],
                      onChanged: (t) => setState(() => _type = t ?? 'sedan'),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _brand,
                            label: l.vehicleBrand,
                            validator: (v) => (v == null || v.trim().isEmpty) ? l.vFieldRequired : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            controller: _model,
                            label: l.vehicleModel,
                            validator: (v) => (v == null || v.trim().isEmpty) ? l.vFieldRequired : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: IntField(controller: _year, label: l.vehicleYear, min: 1980, max: 2100, required: false)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(controller: _color, label: l.vehicleColor)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: IntField(controller: _seats, label: l.vehicleSeats, min: 1, max: 80)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            controller: _plate,
                            label: l.vehiclePlate,
                            textDirection: TextDirection.ltr,
                            validator: (v) => (v == null || v.trim().isEmpty) ? l.vFieldRequired : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(label: l.save, loading: _saving, onPressed: _save),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Text(l.vehiclePhotos, style: Theme.of(context).textTheme.titleMedium)),
                  if (_uploading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final p in _photos)
                    Stack(
                      children: [
                        AppNetworkImage(url: StorageUrls.vehiclePhoto(p), width: 104, height: 104),
                        PositionedDirectional(
                          top: 2,
                          end: 2,
                          child: InkWell(
                            onTap: () => _removePhoto(p),
                            child: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 15, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  InkWell(
                    onTap: _uploading ? null : _addPhoto,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined),
                          const SizedBox(height: 6),
                          Text(l.addVehiclePhoto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
