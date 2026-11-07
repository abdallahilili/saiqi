import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/enums.dart';
import '../theme/app_theme.dart';

/// Pastille de statut colorée.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color, this.icon, this.dense = false});

  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: dense ? 8 : 12, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: dense ? 12 : 14, color: color), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: dense ? 11 : 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

Color bookingStatusColor(BookingStatus s) => switch (s) {
      BookingStatus.pending => AppColors.warning,
      BookingStatus.accepted => AppColors.info,
      BookingStatus.enRoute => AppColors.info,
      BookingStatus.inProgress => AppColors.primary,
      BookingStatus.completed => AppColors.success,
      BookingStatus.cancelled => AppColors.neutral,
      BookingStatus.rejected => AppColors.danger,
      BookingStatus.expired => AppColors.neutral,
    };

class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge(this.status, {super.key, this.dense = false});
  final BookingStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) =>
      StatusBadge(label: context.l10n.bookingStatusLabel(status), color: bookingStatusColor(status), dense: dense);
}

Color driverStatusColor(DriverStatus s) => switch (s) {
      DriverStatus.draft => AppColors.neutral,
      DriverStatus.pending => AppColors.warning,
      DriverStatus.approved => AppColors.success,
      DriverStatus.rejected => AppColors.danger,
      DriverStatus.suspended => AppColors.danger,
    };

class DriverStatusBadge extends StatelessWidget {
  const DriverStatusBadge(this.status, {super.key, this.dense = false});
  final DriverStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) =>
      StatusBadge(label: context.l10n.driverStatusLabel(status), color: driverStatusColor(status), dense: dense);
}

class DocumentStatusBadge extends StatelessWidget {
  const DocumentStatusBadge(this.status, {super.key, this.dense = true});
  final DocumentStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      DocumentStatus.pending => AppColors.warning,
      DocumentStatus.approved => AppColors.success,
      DocumentStatus.rejected => AppColors.danger,
    };
    return StatusBadge(label: context.l10n.documentStatusLabel(status), color: color, dense: dense);
  }
}

class TopupStatusBadge extends StatelessWidget {
  const TopupStatusBadge(this.status, {super.key, this.dense = true});
  final TopupStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TopupStatus.pending => AppColors.warning,
      TopupStatus.approved => AppColors.success,
      TopupStatus.rejected => AppColors.danger,
    };
    return StatusBadge(label: context.l10n.topupStatusLabel(status), color: color, dense: dense);
  }
}

class ComplaintStatusBadge extends StatelessWidget {
  const ComplaintStatusBadge(this.status, {super.key, this.dense = true});
  final ComplaintStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ComplaintStatus.open => AppColors.danger,
      ComplaintStatus.inReview => AppColors.warning,
      ComplaintStatus.resolved => AppColors.success,
      ComplaintStatus.dismissed => AppColors.neutral,
    };
    return StatusBadge(label: context.l10n.complaintStatusLabel(status), color: color, dense: dense);
  }
}

class AccountStatusBadge extends StatelessWidget {
  const AccountStatusBadge(this.status, {super.key, this.dense = true});
  final AccountStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AccountStatus.active => AppColors.success,
      AccountStatus.suspended => AppColors.warning,
      AccountStatus.blocked => AppColors.danger,
    };
    return StatusBadge(label: context.l10n.accountStatusLabel(status), color: color, dense: dense);
  }
}

/// Badge « Vérifié » pour les chauffeurs validés.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) =>
      StatusBadge(label: label, color: AppColors.success, icon: Icons.verified_rounded, dense: true);
}
