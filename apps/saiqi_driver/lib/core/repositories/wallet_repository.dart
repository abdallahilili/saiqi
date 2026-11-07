import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';
import '../models/json_utils.dart';
import '../models/wallet_models.dart';

/// Portefeuille du chauffeur : lecture seule + demande de recharge. Aucune écriture financière côté client.
class WalletRepository {
  WalletRepository(this._db);
  final SupabaseClient _db;

  Future<Wallet?> wallet() => guard(() async {
        final row = await _db.from('wallets').select().maybeSingle();
        return row == null ? null : Wallet.fromJson(row);
      }, retries: 2);

  /// Solde en temps réel (Realtime) pour un chauffeur donné.
  Stream<Wallet?> watchWallet(String driverId) {
    return _db
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .map((rows) => rows.isEmpty ? null : Wallet.fromJson(rows.first));
  }

  Future<List<WalletTx>> transactions({int limit = 100}) => guard(() async {
        final rows = await _db.from('wallet_transactions').select().order('created_at', ascending: false).limit(limit);
        return rows.map(WalletTx.fromJson).toList();
      }, retries: 2);

  Future<TopupRequest> requestTopup({
    required int amount,
    required String method,
    String? reference,
    String? proofPath,
  }) =>
      guard(() async {
        final res = await _db.rpc('request_topup', params: {
          'p_amount': amount,
          'p_method': method,
          'p_reference': reference,
          'p_proof_path': proofPath,
        });
        return TopupRequest.fromJson(asJson(res));
      });

  Future<List<TopupRequest>> myTopups() => guard(() async {
        final rows = await _db.from('topup_requests').select().order('created_at', ascending: false).limit(50);
        return rows.map(TopupRequest.fromJson).toList();
      }, retries: 2);

  Stream<List<TopupRequest>> watchTopups(String driverId) {
    return _db
        .from('topup_requests')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(TopupRequest.fromJson).toList());
  }
}
