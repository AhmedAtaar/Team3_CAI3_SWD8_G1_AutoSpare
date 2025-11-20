import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/services/reviews.dart';
import 'package:auto_spare/model/review.dart';

enum OrdersSectionMode { buyer, seller, admin }

class OrdersSection extends StatelessWidget {
  final OrdersSectionMode mode;
  final String userId;

  const OrdersSection({
    super.key,
    required this.mode,
    required this.userId,
  });

  Color _statusColor(BuildContext ctx, OrderStatus s) {
    switch (s) {
      case OrderStatus.processing:
        return Theme.of(ctx).colorScheme.primary;
      case OrderStatus.prepared:
        return Colors.orange;
      case OrderStatus.handedToCourier:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy/MM/dd – HH:mm');
    final cs = Theme.of(context).colorScheme;

    Stream<List<OrderDoc>> stream;
    switch (mode) {
      case OrdersSectionMode.buyer:
        stream = ordersRepo.watchBuyerOrders(userId);
        break;
      case OrdersSectionMode.seller:
        stream = ordersRepo.watchSellerOrders(userId);
        break;
      case OrdersSectionMode.admin:
        stream = ordersRepo.watchAllOrdersAdmin();
        break;
    }

    Future<void> _openReviewDialog({
      required BuildContext ctx,
      required bool forProduct,
      required String orderId,
      required String buyerId,
      String? productId,
      String? sellerId,
      String? title,
    }) async {
      int stars = 5;
      final txt = TextEditingController();

      final ok = await showDialog<bool>(
        context: ctx,
        builder: (_) => AlertDialog(
          title: Text(forProduct ? 'تقييم المنتج' : 'تقييم البائع', textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(title, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
              ],
              StatefulBuilder(
                builder: (_, setS) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final on = i < stars;
                    return IconButton(
                      onPressed: () => setS(() => stars = i + 1),
                      icon: Icon(on ? Icons.star : Icons.star_border),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: txt,
                maxLines: 3,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'اكتب رأيك (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('إرسال'),
            ),
          ],
        ),
      );

      if (ok == true) {
        if (forProduct) {
          final r = ProductReview(
            id: 'PR-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}',
            orderId: orderId,
            productId: productId!,
            sellerId: sellerId!,
            buyerId: buyerId,
            stars: stars,
            text: txt.text.trim(),
            createdAt: DateTime.now(),
          );
          await reviewsRepo.addProductReview(r);
        } else {
          final r = SellerReview(
            id: 'SR-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}',
            orderId: orderId,
            sellerId: sellerId!,
            buyerId: buyerId,
            stars: stars,
            text: txt.text.trim(),
            createdAt: DateTime.now(),
          );
          await reviewsRepo.addSellerReview(r);
        }

        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('تم إرسال التقييم', textAlign: TextAlign.right)),
          );
        }
      }
    }

    Widget _reviewBadge(double avg, int count) {
      if (count == 0) return const SizedBox.shrink();
      return Chip(
        avatar: const Icon(Icons.star, size: 18),
        label: Text('${avg.toStringAsFixed(1)} • $count'),
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
        child: StreamBuilder<List<OrderDoc>>(
          stream: stream,
          builder: (context, snap) {
            final list = snap.data ?? const <OrderDoc>[];
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: Text('لا توجد طلبات')),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final o = list[i];
                final itemsCount = o.items.fold<int>(0, (a, it) => a + it.qty);

                Widget timeline(OrderDoc od) {
                  Widget dot(bool on, String label) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(on ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: on ? Colors.green : cs.outline),
                      const SizedBox(width: 4),
                      Text(label),
                    ],
                  );
                  return Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      dot(true, 'أُنشئ'),
                      dot(od.stamps.preparedAt != null, 'تم التجهيز'),
                      dot(od.stamps.handedToCourierAt != null, 'مع الشحن'),
                      dot(od.stamps.deliveredAt != null, 'تم الاستلام'),
                      if (od.stamps.cancelledAt != null) dot(true, 'أُلغي'),
                    ],
                  );
                }

                final isBuyer = mode == OrdersSectionMode.buyer;
                final buyerId = isBuyer ? o.buyerId : '';

                return Material(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('('),
                        Text(o.code, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const Text(')'),
                        Chip(
                          label: Text(orderStatusAr(o.status)),
                          avatar: const Icon(Icons.flag_outlined, size: 18),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      isBuyer
                          ? 'العناصر: $itemsCount • الإجمالي: ${o.grandTotal.toStringAsFixed(2)}'
                          : 'المشتري: ${o.buyerId} • عناصر: $itemsCount • الإجمالي: ${o.grandTotal.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                    ),
                    trailing: Text(df.format(o.stamps.createdAt), style: const TextStyle(fontSize: 12)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isBuyer) ...[
                              timeline(o),
                              const SizedBox(height: 8),
                            ],
                            ListView.separated(
                              itemCount: o.items.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (_, __) => const SizedBox(height: 6),
                              itemBuilder: (_, j) {
                                final it = o.items[j];

                                final prodSummary = reviewsRepo.watchProductSummary(it.productId);
                                final sellSummary = reviewsRepo.watchSellerSummary(it.sellerId);

                                return Column(
                                  children: [
                                    ListTile(
                                      dense: true,
                                      leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                                      title: Text('${it.titleSnap} × ${it.qty}', textAlign: TextAlign.right),
                                      subtitle: Text(
                                        isBuyer ? 'البائع: ${it.sellerId} • السعر: ${it.price.toStringAsFixed(2)}' : 'السعر: ${it.price.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                      ),
                                      trailing: Text((it.price * it.qty).toStringAsFixed(2)),
                                    ),
                                    if (isBuyer)
                                      StreamBuilder<({double avg, int count})>(
                                        stream: prodSummary,
                                        builder: (_, ps) {
                                          final pAvg = ps.data?.avg ?? 0;
                                          final pCnt = ps.data?.count ?? 0;
                                          return Row(
                                            children: [
                                              _reviewBadge(pAvg, pCnt),
                                              const SizedBox(width: 8),
                                              StreamBuilder<({double avg, int count})>(
                                                stream: sellSummary,
                                                builder: (_, ss) {
                                                  final sAvg = ss.data?.avg ?? 0;
                                                  final sCnt = ss.data?.count ?? 0;
                                                  return _reviewBadge(sAvg, sCnt);
                                                },
                                              ),
                                              const Spacer(),
                                              if (o.status == OrderStatus.delivered) ...[
                                                FutureBuilder<bool>(
                                                  future: reviewsRepo.hasProductReview(orderId: o.id, productId: it.productId, buyerId: buyerId),
                                                  builder: (_, has) {
                                                    final done = has.data == true;
                                                    return FilledButton.tonalIcon(
                                                      onPressed: done
                                                          ? null
                                                          : () => _openReviewDialog(
                                                        ctx: context,
                                                        forProduct: true,
                                                        orderId: o.id,
                                                        buyerId: buyerId,
                                                        productId: it.productId,
                                                        sellerId: it.sellerId,
                                                        title: it.titleSnap,
                                                      ),
                                                      icon: const Icon(Icons.star),
                                                      label: Text(done ? 'تم التقييم' : 'قيّم المنتج'),
                                                    );
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                                FutureBuilder<bool>(
                                                  future: reviewsRepo.hasSellerReview(orderId: o.id, sellerId: it.sellerId, buyerId: buyerId),
                                                  builder: (_, has) {
                                                    final done = has.data == true;
                                                    return OutlinedButton.icon(
                                                      onPressed: done
                                                          ? null
                                                          : () => _openReviewDialog(
                                                        ctx: context,
                                                        forProduct: false,
                                                        orderId: o.id,
                                                        buyerId: buyerId,
                                                        sellerId: it.sellerId,
                                                        title: it.sellerId,
                                                      ),
                                                      icon: const Icon(Icons.storefront),
                                                      label: Text(done ? 'تم تقييم البائع' : 'قيّم البائع'),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ],
                                          );
                                        },
                                      ),
                                    const Divider(height: 18),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _reviewBadge(double avg, int count) {
    if (count == 0) return const SizedBox.shrink();
    return Chip(
      avatar: const Icon(Icons.star, size: 18),
      label: Text('${avg.toStringAsFixed(1)} • $count'),
    );
  }
}
