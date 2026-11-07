import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Compte à rebours jusqu'à [expiresAt] (délai de réponse d'une demande).
class CountdownChip extends StatefulWidget {
  const CountdownChip({super.key, required this.expiresAt, this.onExpired});

  final DateTime? expiresAt;
  final VoidCallback? onExpired;

  @override
  State<CountdownChip> createState() => _CountdownChipState();
}

class _CountdownChipState extends State<CountdownChip> {
  Timer? _timer;
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      final left = _left;
      if (left != null && left <= Duration.zero && !_notified) {
        _notified = true;
        widget.onExpired?.call();
      }
    });
  }

  Duration? get _left => widget.expiresAt?.difference(DateTime.now());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = _left;
    if (left == null) return const SizedBox.shrink();
    final expired = left <= Duration.zero;
    final urgent = left < const Duration(minutes: 2);
    final color = expired ? AppColors.neutral : (urgent ? AppColors.danger : AppColors.warning);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            expired ? context.l10n.expired : context.l10n.expiresIn(Fmt.countdown(left)),
            textDirection: TextDirection.ltr,
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
