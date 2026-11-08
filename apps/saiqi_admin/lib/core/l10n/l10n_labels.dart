// GÉNÉRÉ par scripts/l10n/generate.mjs — ne pas modifier à la main.
import '../models/enums.dart';
import 'gen/app_localizations.dart';

extension EnumLabels on AppLocalizations {
  String bookingStatusLabel(BookingStatus v) => switch (v) {
        BookingStatus.pending => bookingStatus_pending,
        BookingStatus.accepted => bookingStatus_accepted,
        BookingStatus.enRoute => bookingStatus_enRoute,
        BookingStatus.inProgress => bookingStatus_inProgress,
        BookingStatus.completed => bookingStatus_completed,
        BookingStatus.cancelled => bookingStatus_cancelled,
        BookingStatus.rejected => bookingStatus_rejected,
        BookingStatus.expired => bookingStatus_expired,
      };
  String driverStatusLabel(DriverStatus v) => switch (v) {
        DriverStatus.draft => driverStatus_draft,
        DriverStatus.pending => driverStatus_pending,
        DriverStatus.approved => driverStatus_approved,
        DriverStatus.rejected => driverStatus_rejected,
        DriverStatus.suspended => driverStatus_suspended,
      };
  String accountStatusLabel(AccountStatus v) => switch (v) {
        AccountStatus.active => accountStatus_active,
        AccountStatus.suspended => accountStatus_suspended,
        AccountStatus.blocked => accountStatus_blocked,
      };
  String documentTypeLabel(DocumentType v) => switch (v) {
        DocumentType.idCard => documentType_idCard,
        DocumentType.drivingLicense => documentType_drivingLicense,
        DocumentType.vehicleRegistration => documentType_vehicleRegistration,
        DocumentType.insurance => documentType_insurance,
        DocumentType.photo => documentType_photo,
      };
  String documentStatusLabel(DocumentStatus v) => switch (v) {
        DocumentStatus.pending => documentStatus_pending,
        DocumentStatus.approved => documentStatus_approved,
        DocumentStatus.rejected => documentStatus_rejected,
      };
  String channelLabel(BookingChannel v) => switch (v) {
        BookingChannel.app => channel_app,
        BookingChannel.phone => channel_phone,
        BookingChannel.whatsapp => channel_whatsapp,
        BookingChannel.other => channel_other,
      };
  String txTypeLabel(WalletTxType v) => switch (v) {
        WalletTxType.topup => txType_topup,
        WalletTxType.commission => txType_commission,
        WalletTxType.refund => txType_refund,
        WalletTxType.adjustment => txType_adjustment,
      };
  String topupStatusLabel(TopupStatus v) => switch (v) {
        TopupStatus.pending => topupStatus_pending,
        TopupStatus.approved => topupStatus_approved,
        TopupStatus.rejected => topupStatus_rejected,
      };
  String complaintStatusLabel(ComplaintStatus v) => switch (v) {
        ComplaintStatus.open => complaintStatus_open,
        ComplaintStatus.inReview => complaintStatus_inReview,
        ComplaintStatus.resolved => complaintStatus_resolved,
        ComplaintStatus.dismissed => complaintStatus_dismissed,
      };
  String priceUnitLabel(PriceUnit v) => switch (v) {
        PriceUnit.perTrip => priceUnit_perTrip,
        PriceUnit.perHour => priceUnit_perHour,
        PriceUnit.perDay => priceUnit_perDay,
      };
  String adminRoleLabel(AdminRole v) => switch (v) {
        AdminRole.superAdmin => adminRole_superAdmin,
        AdminRole.validator => adminRole_validator,
        AdminRole.support => adminRole_support,
      };
  String vehicleTypeLabel(String v) => switch (v) {
        'sedan' => vehicleType_sedan,
        'suv' => vehicleType_suv,
        '4x4' => vehicleType_4x4,
        'van' => vehicleType_van,
        'minibus' => vehicleType_minibus,
        'bus' => vehicleType_bus,
        'pickup' => vehicleType_pickup,
        _ => v,
      };
  String audienceLabel(String v) => switch (v) {
        'drivers' => audience_drivers,
        'clients' => audience_clients,
        'all' => audience_all,
        _ => v,
      };
  String weekdayLabel(int weekday) => switch (weekday) {
        1 => weekday_1,
        2 => weekday_2,
        3 => weekday_3,
        4 => weekday_4,
        5 => weekday_5,
        6 => weekday_6,
        7 => weekday_7,
        _ => '',
      };

  /// Message localisé pour un code d'erreur métier ; null si le code est inconnu.
  String? errorForCode(String code) => switch (code) {
        'unknown' => err_unknown,
        'network_error' => err_network_error,
        'session_expired' => err_session_expired,
        'permission_denied' => err_permission_denied,
        'invalid_credentials' => err_invalid_credentials,
        'phone_already_registered' => err_phone_already_registered,
        'invalid_phone' => err_invalid_phone,
        'password_too_short' => err_password_too_short,
        'signup_failed' => err_signup_failed,
        'account_suspended' => err_account_suspended,
        'account_blocked' => err_account_blocked,
        'wrong_app_role' => err_wrong_app_role,
        'not_authenticated' => err_not_authenticated,
        'not_client' => err_not_client,
        'not_driver' => err_not_driver,
        'driver_not_available' => err_driver_not_available,
        'service_not_offered' => err_service_not_offered,
        'pickup_required' => err_pickup_required,
        'invalid_schedule' => err_invalid_schedule,
        'invalid_passengers' => err_invalid_passengers,
        'too_many_passengers' => err_too_many_passengers,
        'too_many_pending' => err_too_many_pending,
        'invalid_service_or_city' => err_invalid_service_or_city,
        'booking_not_found' => err_booking_not_found,
        'booking_not_available' => err_booking_not_available,
        'booking_expired' => err_booking_expired,
        'offer_not_available' => err_offer_not_available,
        'insufficient_balance' => err_insufficient_balance,
        'driver_not_approved' => err_driver_not_approved,
        'wallet_not_found' => err_wallet_not_found,
        'invalid_transition' => err_invalid_transition,
        'not_allowed' => err_not_allowed,
        'booking_not_cancellable' => err_booking_not_cancellable,
        'cancel_not_allowed_after_en_route' => err_cancel_not_allowed_after_en_route,
        'contact_not_available' => err_contact_not_available,
        'amount_too_low' => err_amount_too_low,
        'method_required' => err_method_required,
        'invalid_path' => err_invalid_path,
        'booking_not_completed' => err_booking_not_completed,
        'already_reviewed' => err_already_reviewed,
        'invalid_rating' => err_invalid_rating,
        'text_too_short' => err_text_too_short,
        'text_required' => err_text_required,
        'invalid_driver_status' => err_invalid_driver_status,
        'application_incomplete' => err_application_incomplete,
        'reason_required' => err_reason_required,
        'admin_forbidden' => err_admin_forbidden,
        'driver_not_found' => err_driver_not_found,
        'document_not_found' => err_document_not_found,
        'topup_not_found' => err_topup_not_found,
        'topup_already_reviewed' => err_topup_already_reviewed,
        'invalid_amount' => err_invalid_amount,
        'client_name_required' => err_client_name_required,
        'invalid_channel' => err_invalid_channel,
        'invalid_price' => err_invalid_price,
        'drivers_required' => err_drivers_required,
        'booking_not_reassignable' => err_booking_not_reassignable,
        'complaint_not_found' => err_complaint_not_found,
        'review_not_found' => err_review_not_found,
        'invalid_audience' => err_invalid_audience,
        'cannot_modify_self' => err_cannot_modify_self,
        'profile_not_found' => err_profile_not_found,
        'upload_failed' => err_upload_failed,
        'name_required' => err_name_required,
        'invalid_admin_role' => err_invalid_admin_role,
        'server_not_configured' => err_server_not_configured,
        'create_user_failed' => err_create_user_failed,
        'invalid_token' => err_invalid_token,
        'missing_token' => err_missing_token,
        'internal_error' => err_internal_error,
        'duplicate' => err_duplicate,
        'rate_limited' => err_rate_limited,
        'driver_row_missing' => err_driver_row_missing,
        _ => null,
      };
}
