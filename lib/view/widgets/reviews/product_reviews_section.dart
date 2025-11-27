import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_spare/services/reviews.dart';
import 'package:auto_spare/model/review.dart';

class ProductReviewsSection extends StatelessWidget {
  final String productId;
  final String sellerId;

  const ProductReviewsSection({
    super.key,
    required this.productId,
    required this.sellerId,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('yyyy/MM/dd – HH:mm');

    final prodSummary$ = reviewsRepo.watchProductSummary(productId);
    final sellerSummary$ = reviewsRepo.watchSellerSummary(sellerId);

    final prodList$ = reviewsRepo.watchProductReviews(productId);
    final sellerList$ = reviewsRepo.watchSellerReviews(sellerId);

    Widget badge(double avg, int count, {IconData icon = Icons.star}) {
      if (count == 0) return const SizedBox.shrink();
      return Chip(
        avatar: Icon(icon, size: 18),
        label: Text('${avg.toStringAsFixed(1)} • $count'),
      );
    }

    Widget stars(int n, {double size = 16}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (i) => Icon(i < n ? Icons.star : Icons.star_border, size: size),
        ),
      );
    }

    Widget reviewTile({
      required String titleRight,
      required int starsCount,
      required String? text,
      required DateTime createdAt,
    }) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Expanded(child: Text(titleRight, textAlign: TextAlign.right)),
            const SizedBox(width: 8),
            stars(starsCount),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (text != null && text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(text, textAlign: TextAlign.right),
              ),
            const SizedBox(height: 4),
            Text(df.format(createdAt), style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.rate_review_outlined),
                const SizedBox(width: 8),
                const Text('التقييمات'),
                const Spacer(),
                StreamBuilder<({double avg, int count})>(
                  stream: prodSummary$,
                  builder: (_, s) =>
                      badge(s.data?.avg ?? 0, s.data?.count ?? 0),
                ),
                const SizedBox(width: 6),
                StreamBuilder<({double avg, int count})>(
                  stream: sellerSummary$,
                  builder: (_, s) => badge(
                    s.data?.avg ?? 0,
                    s.data?.count ?? 0,
                    icon: Icons.storefront,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.inventory_2_outlined),
                      SizedBox(width: 6),
                      Text('مراجعات المنتج'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<ProductReview>>(
                    stream: prodList$,
                    builder: (_, snap) {
                      final list = snap.data ?? const <ProductReview>[];
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'لا توجد مراجعات للمنتج بعد',
                            textAlign: TextAlign.right,
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 12),
                        itemBuilder: (_, i) {
                          final r = list[i];
                          return reviewTile(
                            titleRight: 'المشتري: ${r.buyerId}',
                            starsCount: r.stars,
                            text: r.text,
                            createdAt: r.createdAt,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.storefront),
                      SizedBox(width: 6),
                      Text('مراجعات البائع'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<SellerReview>>(
                    stream: sellerList$,
                    builder: (_, snap) {
                      final list = snap.data ?? const <SellerReview>[];
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'لا توجد مراجعات للبائع بعد',
                            textAlign: TextAlign.right,
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 12),
                        itemBuilder: (_, i) {
                          final r = list[i];
                          return reviewTile(
                            titleRight: 'المشتري: ${r.buyerId}',
                            starsCount: r.stars,
                            text: r.text,
                            createdAt: r.createdAt,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
