import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/services/reviews.dart';
import 'package:auto_spare/model/review.dart';

import 'package:auto_spare/view/screens/seller_order_details_screen.dart';

enum OrdersSectionMode { buyer, seller, admin }

class OrdersSection extends StatefulWidget {
  final OrdersSectionMode mode;
  final String userId;

  const OrdersSection({super.key, required this.mode, required this.userId});

  @override
  State<OrdersSection> createState() => _OrdersSectionState();
}

class _OrdersSectionState extends State<OrdersSection> {
  OrderStatus? _buyerStatusFilter;

  Color _statusColor(BuildContext ctx, OrderStatus s) {
    final cs = Theme.of(ctx).colorScheme;
    switch (s) {
      case OrderStatus.processing:
        return cs.primary;
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

  Widget _buildBuyerFilterBar(ColorScheme cs) {
    if (widget.mode != OrdersSectionMode.buyer) {
      return const SizedBox.shrink();
    }

    Widget chip({required String label, OrderStatus? value}) {
      final selected = _buyerStatusFilter == value;
      return FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _buyerStatusFilter = selected ? null : value;
          });
        },
        selectedColor: cs.primaryContainer,
        showCheckmark: false,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            chip(label: 'الكل', value: null),
            chip(
              label: orderStatusAr(OrderStatus.processing),
              value: OrderStatus.processing,
            ),
            chip(
              label: orderStatusAr(OrderStatus.prepared),
              value: OrderStatus.prepared,
            ),
            chip(
              label: orderStatusAr(OrderStatus.handedToCourier),
              value: OrderStatus.handedToCourier,
            ),
            chip(
              label: orderStatusAr(OrderStatus.delivered),
              value: OrderStatus.delivered,
            ),
            chip(
              label: orderStatusAr(OrderStatus.cancelled),
              value: OrderStatus.cancelled,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy/MM/dd – HH:mm');
    final cs = Theme.of(context).colorScheme;

    final mode = widget.mode;
    final userId = widget.userId;

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
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: Text(
            forProduct ? 'تقييم المنتج' : 'تقييم البائع',
            textAlign: TextAlign.right,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
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
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
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
            const SnackBar(
              content: Text('تم إرسال التقييم', textAlign: TextAlign.right),
            ),
          );
        }
      }
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
            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final base = snap.data ?? const <OrderDoc>[];
            final rawList = List<OrderDoc>.from(base);

            if (mode == OrdersSectionMode.buyer) {
              List<OrderDoc> list = rawList;

              if (_buyerStatusFilter != null) {
                list = rawList
                    .where((o) => o.status == _buyerStatusFilter)
                    .toList();
              }

              list.sort(
                (a, b) => b.stamps.createdAt.compareTo(a.stamps.createdAt),
              );

              final buyerId = userId;

              if (list.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBuyerFilterBar(cs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'عدد الطلبات: 0',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'لا توجد طلبات',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBuyerFilterBar(cs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'عدد الطلبات: ${list.length}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final o = list[i];
                      final itemsCount = o.items.fold<int>(
                        0,
                        (a, it) => a + it.qty,
                      );

                      Widget timeline(OrderDoc od) {
                        Widget dot(bool on, String label) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              on
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 16,
                              color: on ? Colors.green : cs.outline,
                            ),
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
                            dot(
                              od.stamps.handedToCourierAt != null,
                              'مع الشحن',
                            ),
                            dot(od.stamps.deliveredAt != null, 'تم الاستلام'),
                            if (od.stamps.cancelledAt != null)
                              dot(true, 'أُلغي'),
                          ],
                        );
                      }

                      final isLatest = (i == 0) && (_buyerStatusFilter == null);

                      return Material(
                        color: isLatest
                            ? cs.primary.withOpacity(0.04)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLowest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: _statusColor(
                              context,
                              o.status,
                            ).withOpacity(isLatest ? 0.7 : 0.35),
                          ),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          leading: const Icon(Icons.receipt_long_outlined),
                          title: Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                o.code,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Chip(
                                label: Text(orderStatusAr(o.status)),
                                avatar: const Icon(
                                  Icons.flag_outlined,
                                  size: 18,
                                ),
                              ),
                              if (isLatest)
                                const Chip(
                                  label: Text(
                                    'الأحدث',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  avatar: Icon(
                                    Icons.fiber_new,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            'العناصر: $itemsCount • الإجمالي: ${o.grandTotal.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                          ),
                          trailing: Text(
                            df.format(o.stamps.createdAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  timeline(o),
                                  const SizedBox(height: 8),
                                  ListView.separated(
                                    itemCount: o.items.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 6),
                                    itemBuilder: (_, j) {
                                      final it = o.items[j];

                                      final prodSummary = reviewsRepo
                                          .watchProductSummary(it.productId);
                                      final sellSummary = reviewsRepo
                                          .watchSellerSummary(it.sellerId);

                                      return Column(
                                        children: [
                                          ListTile(
                                            dense: true,
                                            leading: const CircleAvatar(
                                              child: Icon(
                                                Icons.inventory_2_outlined,
                                              ),
                                            ),
                                            title: Text(
                                              '${it.titleSnap} × ${it.qty}',
                                              textAlign: TextAlign.right,
                                            ),
                                            subtitle: Text(
                                              'البائع: ${it.sellerId} • السعر: ${it.price.toStringAsFixed(2)}',
                                              textAlign: TextAlign.right,
                                            ),
                                            trailing: Text(
                                              (it.price * it.qty)
                                                  .toStringAsFixed(2),
                                            ),
                                          ),
                                          StreamBuilder<
                                            ({double avg, int count})
                                          >(
                                            stream: prodSummary,
                                            builder: (_, ps) {
                                              final pAvg = ps.data?.avg ?? 0;
                                              final pCnt = ps.data?.count ?? 0;
                                              return SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: [
                                                    _reviewBadge(pAvg, pCnt),
                                                    const SizedBox(width: 8),
                                                    StreamBuilder<
                                                      ({double avg, int count})
                                                    >(
                                                      stream: sellSummary,
                                                      builder: (_, ss) {
                                                        final sAvg =
                                                            ss.data?.avg ?? 0;
                                                        final sCnt =
                                                            ss.data?.count ?? 0;
                                                        return _reviewBadge(
                                                          sAvg,
                                                          sCnt,
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 16),
                                                    if (o.status ==
                                                        OrderStatus
                                                            .delivered) ...[
                                                      FutureBuilder<bool>(
                                                        future: reviewsRepo
                                                            .hasProductReview(
                                                              orderId: o.id,
                                                              productId:
                                                                  it.productId,
                                                              buyerId: buyerId,
                                                            ),
                                                        builder: (_, has) {
                                                          final done =
                                                              has.data == true;
                                                          return FilledButton.tonalIcon(
                                                            onPressed: done
                                                                ? null
                                                                : () => _openReviewDialog(
                                                                    ctx:
                                                                        context,
                                                                    forProduct:
                                                                        true,
                                                                    orderId:
                                                                        o.id,
                                                                    buyerId:
                                                                        buyerId,
                                                                    productId: it
                                                                        .productId,
                                                                    sellerId: it
                                                                        .sellerId,
                                                                    title: it
                                                                        .titleSnap,
                                                                  ),
                                                            icon: const Icon(
                                                              Icons.star,
                                                            ),
                                                            label: Text(
                                                              done
                                                                  ? 'تم التقييم'
                                                                  : 'قيّم المنتج',
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(width: 8),
                                                      FutureBuilder<bool>(
                                                        future: reviewsRepo
                                                            .hasSellerReview(
                                                              orderId: o.id,
                                                              sellerId:
                                                                  it.sellerId,
                                                              buyerId: buyerId,
                                                            ),
                                                        builder: (_, has) {
                                                          final done =
                                                              has.data == true;
                                                          return OutlinedButton.icon(
                                                            onPressed: done
                                                                ? null
                                                                : () => _openReviewDialog(
                                                                    ctx:
                                                                        context,
                                                                    forProduct:
                                                                        false,
                                                                    orderId:
                                                                        o.id,
                                                                    buyerId:
                                                                        buyerId,
                                                                    sellerId: it
                                                                        .sellerId,
                                                                    title: it
                                                                        .sellerId,
                                                                  ),
                                                            icon: const Icon(
                                                              Icons.storefront,
                                                            ),
                                                            label: Text(
                                                              done
                                                                  ? 'تم تقييم البائع'
                                                                  : 'قيّم البائع',
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ],
                                                ),
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
                  ),
                ],
              );
            }

            if (rawList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text('لا توجد طلبات', textAlign: TextAlign.center),
                ),
              );
            }

            final list = [
              ...rawList,
            ]..sort((a, b) => b.stamps.createdAt.compareTo(a.stamps.createdAt));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'عدد الطلبات: ${list.length}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final o = list[i];

                    final sellerItems = widget.mode == OrdersSectionMode.seller
                        ? o.items
                              .where((it) => it.sellerId == widget.userId)
                              .toList()
                        : o.items;

                    final sellerItemsCount = sellerItems.fold<int>(
                      0,
                      (p, it) => p + it.qty,
                    );

                    final sellerSubtotal = sellerItems.fold<double>(
                      0.0,
                      (p, it) => p + it.price * it.qty,
                    );

                    final allItemsTotal = o.itemsTotal > 0
                        ? o.itemsTotal
                        : o.items.fold<double>(
                            0.0,
                            (p, it) => p + it.price * it.qty,
                          );

                    double sellerDiscountShare = 0.0;
                    double sellerNet = sellerSubtotal;

                    if (widget.mode == OrdersSectionMode.seller &&
                        o.discount > 0 &&
                        allItemsTotal > 0 &&
                        sellerSubtotal > 0) {
                      final ratio = sellerSubtotal / allItemsTotal;
                      sellerDiscountShare = o.discount * ratio;
                      sellerNet = sellerSubtotal - sellerDiscountShare;
                    }

                    final totalItems = o.items.fold<int>(
                      0,
                      (p, it) => p + it.qty,
                    );

                    return Material(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: _statusColor(
                            context,
                            o.status,
                          ).withOpacity(.4),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long_outlined),
                        onTap: widget.mode == OrdersSectionMode.seller
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SellerOrderDetailsScreen(
                                      order: o,
                                      sellerId: widget.userId,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        title: Text(
                          'الطلب: ${o.code}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('المشتري: ${o.buyerId}'),
                            const SizedBox(height: 2),
                            if (widget.mode == OrdersSectionMode.seller) ...[
                              Text(
                                'العناصر الخاصة بك: $sellerItemsCount من أصل $totalItems',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'صافي قيمة منتجاتك: ${sellerNet.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ] else ...[
                              Text(
                                'العناصر: $totalItems • الإجمالي: ${o.grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              orderStatusAr(o.status),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(context, o.status),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              df.format(o.stamps.createdAt),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
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
