import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

class DriverDetailScreen extends ConsumerWidget {
  const DriverDetailScreen({super.key, required this.driverId});
  final String driverId;

  void _refresh(WidgetRef ref) {
    ref.invalidate(adminDriverProvider(driverId));
    ref.invalidate(adminDriverDocsProvider(driverId));
    ref.invalidate(adminDriversProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final driver = ref.watch(adminDriverProvider(driverId));
    return Scaffold(
      appBar: AppBar(title: Text(l.driverDetail)),
      body: AsyncValueView<AdminDriver>(
        value: driver,
        onRetry: () => _refresh(ref),
        data: (d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Header(d: d),
            const SizedBox(height: 14),
            _ApplicationActions(d: d, onChanged: () => _refresh(ref)),
            _VehicleCard(driverId: driverId),
            const SizedBox(height: 12),
            _ServicesCard(driverId: driverId),
            const SizedBox(height: 12),
            _DocumentsCard(driverId: driverId, canReview: ref.watch(permsProvider).canValidateDrivers, onChanged: () => _refresh(ref)),
            const SizedBox(height: 12),
            _AccountActions(d: d, onChanged: () => _refresh(ref)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.d});
  final AdminDriver d;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(url: d.avatarUrl, name: d.displayName, radius: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.displayName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          DriverStatusBadge(d.driver.status, dense: true),
                          if (d.accountStatus != AccountStatus.active) AccountStatusBadge(d.accountStatus),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ContactActions(phone: d.phone),
            const Divider(height: 28),
            InfoRow(label: l.city, value: d.cityName(lang), icon: Icons.location_city_outlined),
            InfoRow(label: l.yearsExperienceLabel, value: d.driver.yearsExperience?.toString(), icon: Icons.workspace_premium_outlined),
            if (d.driver.ratingCount > 0)
              InfoRow(label: l.ratingLabel, valueWidget: StarRating(value: d.driver.ratingAvg, showValue: true, count: d.driver.ratingCount), icon: Icons.star_outline_rounded),
            InfoRow(label: l.completedTrips, value: '${d.driver.completedCount}', icon: Icons.check_circle_outline),
            if (d.balance != null) InfoRow(label: l.walletBalance, valueWidget: MoneyText(d.balance!, style: const TextStyle(fontWeight: FontWeight.w900)), icon: Icons.account_balance_wallet_outlined),
            if (d.driver.createdAt != null) InfoRow(label: l.status, value: l.joinedOn(Fmt.date(d.driver.createdAt!, lang)), icon: Icons.calendar_today_outlined),
            if (d.driver.bio != null && d.driver.bio!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(d.driver.bio!),
            ],
            if (d.driver.rejectionReason != null && d.driver.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 10),
              InfoBanner(icon: Icons.info_outline, color: AppColors.danger, message: '${l.reason} : ${d.driver.rejectionReason}'),
            ],
          ],
        ),
      ),
    );
  }
}

/// Valider / refuser un dossier en attente ; suspendre / réactiver un chauffeur validé.
class _ApplicationActions extends ConsumerWidget {
  const _ApplicationActions({required this.d, required this.onChanged});
  final AdminDriver d;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final perms = ref.watch(permsProvider);
    if (!perms.canValidateDrivers) return const SizedBox.shrink();
    final repo = ref.read(adminRepositoryProvider);
    final status = d.driver.status;

    if (status == DriverStatus.pending) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: DangerButton(
                label: l.rejectDriver,
                icon: Icons.close_rounded,
                onPressed: () async {
                  final reason = await promptTextDialog(context, title: l.rejectReasonTitle, hint: l.reasonHint);
                  if (reason == null || !context.mounted) return;
                  final ok = await runAction(context, () => repo.reviewDriver(d.driver.id, approve: false, reason: reason), successMessage: l.driverRejectedMsg);
                  if (ok) onChanged();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                label: l.approveDriver,
                icon: Icons.verified_rounded,
                onPressed: () async {
                  final ok = await confirmDialog(context, title: l.approveDriver, message: d.displayName);
                  if (!ok || !context.mounted) return;
                  final done = await runAction(context, () => repo.reviewDriver(d.driver.id, approve: true), successMessage: l.driverApprovedMsg);
                  if (done) onChanged();
                },
              ),
            ),
          ],
        ),
      );
    }
    if (status == DriverStatus.approved) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DangerButton(
          label: l.suspendDriver,
          icon: Icons.pause_circle_outline,
          onPressed: () async {
            final reason = await promptTextDialog(context, title: l.suspendReasonTitle, hint: l.reasonHint);
            if (reason == null || !context.mounted) return;
            final ok = await runAction(context, () => repo.setDriverStatus(d.driver.id, DriverStatus.suspended, reason: reason), successMessage: l.accountStatusChanged);
            if (ok) onChanged();
          },
        ),
      );
    }
    if (status == DriverStatus.suspended) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: PrimaryButton(
          label: l.reinstateDriver,
          icon: Icons.play_circle_outline,
          onPressed: () async {
            final ok = await runAction(context, () => repo.setDriverStatus(d.driver.id, DriverStatus.approved), successMessage: l.accountStatusChanged);
            if (ok) onChanged();
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _VehicleCard extends ConsumerWidget {
  const _VehicleCard({required this.driverId});
  final String driverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final vehicle = ref.watch(adminDriverVehicleProvider(driverId));
    return SectionCard(
      title: l.stepVehicle,
      child: vehicle.when(
        loading: () => const Padding(padding: EdgeInsets.all(12), child: LoadingView()),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(adminDriverVehicleProvider(driverId))),
        data: (v) {
          if (v == null) return Text(l.noVehicle);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRow(label: l.vehicleType, value: l.vehicleTypeLabel(v.vehicleType)),
              InfoRow(label: l.vehicleBrand, value: v.title),
              InfoRow(label: l.vehicleYear, value: v.year?.toString()),
              InfoRow(label: l.vehicleColor, value: v.color),
              InfoRow(label: l.vehicleSeats, value: '${v.seats}'),
              InfoRow(label: l.vehiclePlate, valueWidget: Directionality(textDirection: TextDirection.ltr, child: Text(v.plate, style: const TextStyle(fontWeight: FontWeight.w800)))),
              if (v.photoPaths.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: v.photoPaths.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => ImageViewerPage(title: l.vehiclePhotos, bucket: Buckets.vehiclePhotos, path: v.photoPaths[i]),
                      )),
                      child: AppNetworkImage(url: StorageUrls.vehiclePhoto(v.photoPaths[i]), width: 120, height: 96),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ServicesCard extends ConsumerWidget {
  const _ServicesCard({required this.driverId});
  final String driverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final services = ref.watch(adminDriverServicesProvider(driverId));
    final types = ref.watch(serviceTypesProvider).value ?? const <ServiceType>[];
    final cities = ref.watch(citiesProvider).value ?? const <City>[];
    return SectionCard(
      title: l.stepServices,
      child: services.when(
        loading: () => const Padding(padding: EdgeInsets.all(12), child: LoadingView()),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(adminDriverServicesProvider(driverId))),
        data: (list) {
          if (list.isEmpty) return Text(l.noServicesAdmin);
          return Column(
            children: [
              for (final s in list)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(serviceIconFor(types.where((t) => t.id == s.serviceTypeId).firstOrNull?.icon ?? '')),
                  title: Text(types.where((t) => t.id == s.serviceTypeId).firstOrNull?.name(context.lang) ?? '—'),
                  subtitle: Text(cities.where((c) => s.cityIds.contains(c.id)).map((c) => c.name(context.lang)).join('، ')),
                  trailing: Text('${Fmt.mru(s.price, context.lang)}\n${l.priceUnitLabel(s.priceUnit)}',
                      textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DocumentsCard extends ConsumerWidget {
  const _DocumentsCard({required this.driverId, required this.canReview, required this.onChanged});
  final String driverId;
  final bool canReview;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final docs = ref.watch(adminDriverDocsProvider(driverId));
    return SectionCard(
      title: l.stepDocuments,
      child: docs.when(
        loading: () => const Padding(padding: EdgeInsets.all(12), child: LoadingView()),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(adminDriverDocsProvider(driverId))),
        data: (list) {
          if (list.isEmpty) return Text(l.noDocuments);
          return Column(
            children: [
              for (final d in list) ...[
                _DocRow(doc: d, canReview: canReview, onChanged: onChanged),
                if (d != list.last) const Divider(),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DocRow extends ConsumerWidget {
  const _DocRow({required this.doc, required this.canReview, required this.onChanged});
  final DriverDocument doc;
  final bool canReview;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final repo = ref.read(adminRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description_outlined),
            const SizedBox(width: 10),
            Expanded(child: Text(l.documentTypeLabel(doc.type), style: const TextStyle(fontWeight: FontWeight.w700))),
            DocumentStatusBadge(doc.status),
          ],
        ),
        if (doc.rejectionReason != null && doc.status == DocumentStatus.rejected)
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.docRejectedReason(doc.rejectionReason!), style: const TextStyle(color: AppColors.danger, fontSize: 12.5))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42)),
              icon: const Icon(Icons.zoom_in_rounded),
              label: Text(l.viewDocument),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => ImageViewerPage(title: l.documentTypeLabel(doc.type), bucket: Buckets.driverDocuments, path: doc.filePath),
              )),
            ),
            if (canReview && doc.status != DocumentStatus.approved)
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 42), backgroundColor: AppColors.success),
                icon: const Icon(Icons.check_rounded),
                label: Text(l.approveDocument),
                onPressed: () async {
                  final ok = await runAction(context, () => repo.reviewDocument(doc.id, approve: true), successMessage: l.documentApprovedMsg);
                  if (ok) onChanged();
                },
              ),
            if (canReview && doc.status != DocumentStatus.rejected)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42), foregroundColor: AppColors.danger),
                icon: const Icon(Icons.close_rounded),
                label: Text(l.rejectDocument),
                onPressed: () async {
                  final reason = await promptTextDialog(context, title: l.rejectDocReasonTitle, hint: l.reasonHint);
                  if (reason == null || !context.mounted) return;
                  final ok = await runAction(context, () => repo.reviewDocument(doc.id, approve: false, reason: reason), successMessage: l.documentRejectedMsg);
                  if (ok) onChanged();
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// Suspension / blocage du compte (profil) et lien vers le portefeuille.
class _AccountActions extends ConsumerWidget {
  const _AccountActions({required this.d, required this.onChanged});
  final AdminDriver d;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final perms = ref.watch(permsProvider);
    final repo = ref.read(adminRepositoryProvider);
    final profileId = d.driver.profileId;

    Future<void> setStatus(AccountStatus s) async {
      String? reason;
      if (s != AccountStatus.active) {
        reason = await promptTextDialog(context, title: l.reason, hint: l.reasonHint);
        if (reason == null || !context.mounted) return;
      }
      final ok = await runAction(context, () => repo.setAccountStatus(profileId, s, reason: reason), successMessage: l.accountStatusChanged);
      if (ok) onChanged();
    }

    return SectionCard(
      title: l.accountActions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (perms.canReviewTopups || perms.canAdjustWallet)
            SecondaryButton(label: l.walletHistory, icon: Icons.account_balance_wallet_outlined, onPressed: () => context.push('/wallet/driver/${d.driver.id}')),
          const SizedBox(height: 10),
          if (d.accountStatus == AccountStatus.active) ...[
            SecondaryButton(label: l.suspendAccount, icon: Icons.pause_circle_outline, onPressed: () => setStatus(AccountStatus.suspended)),
            const SizedBox(height: 10),
            DangerButton(label: l.blockAccount, icon: Icons.block_rounded, onPressed: () => setStatus(AccountStatus.blocked)),
          ] else
            PrimaryButton(label: l.reactivateAccount, icon: Icons.lock_open_rounded, onPressed: () => setStatus(AccountStatus.active)),
          const SizedBox(height: 10),
          SecondaryButton(label: l.resetPassword, icon: Icons.lock_reset_outlined, onPressed: () => resetPasswordFlow(context, ref, profileId)),
        ],
      ),
    );
  }
}

/// Saisie d'un nouveau mot de passe puis appel de l'Edge Function admin-reset-password.
Future<void> resetPasswordFlow(BuildContext context, WidgetRef ref, String userId) async {
  final l = context.l10n;
  final pwd = await promptTextDialog(context, title: l.newPasswordPrompt, hint: l.passwordHint, maxLines: 1);
  if (pwd == null || !context.mounted) return;
  if (pwd.length < 8) {
    showAppSnack(context, l.vPasswordMin, error: true);
    return;
  }
  await runAction(context, () => ref.read(adminRepositoryProvider).resetPassword(userId: userId, newPassword: pwd), successMessage: l.passwordResetDone);
}
