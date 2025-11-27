import 'package:flutter/material.dart';
import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/services/cart_service.dart';
import 'cart_screen.dart';

import 'package:auto_spare/services/reviews.dart';
import 'package:auto_spare/view/widgets/reviews/product_reviews_section.dart';

import '../../controller/navigation/navigation.dart';

class ProductDetailsScreen extends StatelessWidget {
  final CatalogProduct p;
  const ProductDetailsScreen({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget image() {
      if (p.imageUrl == null || p.imageUrl!.isEmpty) {
        return Container(
          height: 220,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: const Icon(Icons.image_outlined, size: 48),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          p.imageUrl!,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: const Icon(Icons.broken_image_outlined, size: 48),
          ),
        ),
      );
    }

    void addToCart() {
      CartService().addCatalogProduct(p);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة المنتج إلى السلة')),
      );
    }

    void buyNow() {
      CartService().buyNow(p);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
    }

    Widget ratingBadge(double avg, int count, {IconData icon = Icons.star}) {
      if (count == 0) return const SizedBox.shrink();
      return Chip(
        avatar: Icon(icon, size: 18),
        label: Text('${avg.toStringAsFixed(1)} • $count'),
      );
    }

    final String productIdForReviews = p.id;
    final String sellerIdForReviews = p.seller;

    final prodSummary$ = reviewsRepo.watchProductSummary(productIdForReviews);
    final sellerSummary$ = reviewsRepo.watchSellerSummary(sellerIdForReviews);

    final body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        image(),
        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                p.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            StreamBuilder<({double avg, int count})>(
              stream: prodSummary$,
              builder: (_, snap) {
                final data = snap.data;
                return ratingBadge(data?.avg ?? 0, data?.count ?? 0);
              },
            ),
            const SizedBox(width: 6),
            StreamBuilder<({double avg, int count})>(
              stream: sellerSummary$,
              builder: (_, snap) {
                final data = snap.data;
                return ratingBadge(
                  data?.avg ?? 0,
                  data?.count ?? 0,
                  icon: Icons.storefront,
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 6),
        Text('الماركة: ${kBrandName[p.brand]}    •    الموديل: ${p.model}'),
        Text('السنوات: ${p.years.join(', ')}'),
        Text('المخزون المتاح: ${p.stock}'),
        const SizedBox(height: 10),
        Text(
          'السعر: ${p.price.toStringAsFixed(2)} جنيه',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: p.stock > 0 ? addToCart : null,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('أضف للسلة'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: p.stock > 0 ? buyNow : null,
                icon: const Icon(Icons.flash_on_outlined),
                label: const Text('شراء الآن'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sell_outlined),

            title: Text('البائع: ${p.seller}'),
          ),
        ),

        const SizedBox(height: 16),

        ProductReviewsSection(
          productId: productIdForReviews,
          sellerId: sellerIdForReviews,
        ),
      ],
    );

    return AppNavigationScaffold(
      currentIndex: 0,
      title: 'تفاصيل المنتج',
      body: body,
    );
  }
}
