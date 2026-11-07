import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';
import '../models/catalog_models.dart';
import '../models/json_utils.dart';
import '../utils/json_cache.dart';

/// Villes, types de services, réglages : mis en cache pour tenir en cas de réseau faible.
class CatalogRepository {
  CatalogRepository(this._db, this._cache);
  final SupabaseClient _db;
  final JsonCache _cache;

  Future<List<City>> cities({bool includeInactive = false}) => guard(() {
        return _cache.fetch<List<City>>(
          key: 'cities.$includeInactive',
          loader: () async {
            var q = _db.from('cities').select();
            if (!includeInactive) q = q.eq('is_active', true);
            return await q.order('sort_order').order('name_fr');
          },
          parse: (j) => asJsonList(j).map(City.fromJson).toList(),
        );
      });

  Future<List<ServiceType>> serviceTypes({bool includeInactive = false}) => guard(() {
        return _cache.fetch<List<ServiceType>>(
          key: 'service_types.$includeInactive',
          loader: () async {
            var q = _db.from('service_types').select();
            if (!includeInactive) q = q.eq('is_active', true);
            return await q.order('sort_order').order('name_fr');
          },
          parse: (j) => asJsonList(j).map(ServiceType.fromJson).toList(),
        );
      });

  Future<AppSettings> settings() => guard(() {
        return _cache.fetch<AppSettings>(
          key: 'settings',
          loader: () async => await _db.from('app_settings').select('key,value'),
          parse: (j) => AppSettings({
            for (final row in asJsonList(j)) row['key'] as String: row['value'],
          }),
        );
      });

  Future<List<CommissionRate>> commissionRates() => guard(() async {
        final rows = await _db.from('commission_rates').select().order('created_at');
        return rows.map(CommissionRate.fromJson).toList();
      }, retries: 1);
}
