import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final reviews = ref.watch(reviewsProvider);
    final driver = ref.watch(myDriverProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.reviewsReceived)),
      body: AsyncValueView<List<Review>>(
        value: reviews,
        onRetry: () => ref.invalidate(reviewsProvider),
        isEmpty: (list) => list.isEmpty,
        emptyTitle: l.noReviewsYet,
        emptyIcon: Icons.reviews_outlined,
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (driver != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(Fmt.rating(driver.ratingAvg), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StarRating(value: driver.ratingAvg, size: 22),
                          const SizedBox(height: 4),
                          Text(l.reviewsCount('${driver.ratingCount}')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            for (final r in list) ...[ReviewTile(review: r), const SizedBox(height: 8)],
          ],
        ),
      ),
    );
  }
}
