import 'enums.dart';
import 'json_utils.dart';

class Wallet {
  const Wallet({required this.id, required this.driverId, required this.balance});
  final String id;
  final String driverId;
  final int balance;

  factory Wallet.fromJson(Json j) => Wallet(
        id: j['id'] as String,
        driverId: j['driver_id'] as String,
        balance: asInt(j['balance']),
      );
}

class WalletTx {
  const WalletTx({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.createdAt,
    this.bookingId,
    this.note,
  });
  final String id;
  final WalletTxType type;

  /// Signé : négatif pour une commission, positif pour recharge / restitution.
  final int amount;
  final int balanceAfter;
  final String? bookingId;
  final String? note;
  final DateTime createdAt;

  factory WalletTx.fromJson(Json j) => WalletTx(
        id: j['id'] as String,
        type: enumFromDb(WalletTxType.values, j['type'], WalletTxType.adjustment),
        amount: asInt(j['amount']),
        balanceAfter: asInt(j['balance_after']),
        bookingId: j['booking_id'] as String?,
        note: j['note'] as String?,
        createdAt: asDateOr(j['created_at'], DateTime.now()),
      );
}

class TopupRequest {
  const TopupRequest({
    required this.id,
    required this.driverId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.reference,
    this.proofPath,
    this.reviewNote,
    this.driverName,
    this.driverPhone,
  });
  final String id;
  final String driverId;
  final int amount;
  final String method;
  final String? reference;
  final String? proofPath;
  final TopupStatus status;
  final String? reviewNote;
  final DateTime createdAt;
  final String? driverName;
  final String? driverPhone;

  factory TopupRequest.fromJson(Json j) {
    // Embed admin : drivers(profiles(full_name,phone))
    final driver = firstJson(j['drivers']);
    final profile = driver == null ? null : firstJson(driver['profiles']);
    return TopupRequest(
      id: j['id'] as String,
      driverId: j['driver_id'] as String,
      amount: asInt(j['amount']),
      method: (j['method'] ?? '') as String,
      reference: j['reference'] as String?,
      proofPath: j['proof_path'] as String?,
      status: enumFromDb(TopupStatus.values, j['status'], TopupStatus.pending),
      reviewNote: j['review_note'] as String?,
      createdAt: asDateOr(j['created_at'], DateTime.now()),
      driverName: profile?['full_name'] as String?,
      driverPhone: profile?['phone'] as String?,
    );
  }
}
