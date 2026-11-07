import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Étoiles en lecture seule (supporte les demi-étoiles).
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, this.size = 18, this.showValue = false, this.count});

  final double value;
  final double size;
  final bool showValue;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final stars = <Widget>[];
    for (var i = 1; i <= 5; i++) {
      final icon = value >= i - 0.25
          ? Icons.star_rounded
          : (value >= i - 0.75 ? Icons.star_half_rounded : Icons.star_outline_rounded);
      stars.add(Icon(icon, size: size, color: AppColors.gold));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...stars,
        if (showValue) ...[
          const SizedBox(width: 6),
          Text(Fmt.rating(value), style: TextStyle(fontWeight: FontWeight.w700, fontSize: size * 0.8)),
        ],
        if (count != null) ...[
          const SizedBox(width: 4),
          Text('($count)', style: TextStyle(fontSize: size * 0.7, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ],
    );
  }
}

/// Saisie d'une note de 1 à 5.
class RatingInput extends StatelessWidget {
  const RatingInput({super.key, required this.value, required this.onChanged, this.size = 40});

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            iconSize: size,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: size + 8, height: size + 8),
            onPressed: () => onChanged(i),
            icon: Icon(i <= value ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.gold),
          ),
      ],
    );
  }
}
