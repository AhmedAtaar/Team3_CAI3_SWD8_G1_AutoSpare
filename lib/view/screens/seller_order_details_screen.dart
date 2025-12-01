import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:auto_spare/model/order.dart';

class SellerOrderDetailsScreen extends StatelessWidget {
  final OrderDoc order;
  final String sellerId;

  const SellerOrderDetailsScreen({
    super.key,
    required this.order,
    required this.sellerId,
  });

  Color _statusColor(ColorScheme cs, OrderStatus s) {
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('yyyy/MM/dd – HH:mm');

    final sellerItems = order.items
        .where((it) => it.sellerId == sellerId)
        .toList();

    final sellerItemsCount = sellerItems.fold<int>(0, (p, it) => p + it.qty);

    final sellerSubtotal = sellerItems.fold<double>(
      0.0,
      (p, it) => p + it.price * it.qty,
    );

    final allItemsTotal = order.itemsTotal > 0
        ? order.itemsTotal
        : order.items.fold<double>(0.0, (p, it) => p + it.price * it.qty);

    double sellerDiscountShare = 0.0;
    double sellerNet = sellerSubtotal;

    if (order.discount > 0 && allItemsTotal > 0 && sellerSubtotal > 0) {
      final ratio = sellerSubtotal / allItemsTotal;
      sellerDiscountShare = order.discount * ratio;
      sellerNet = sellerSubtotal - sellerDiscountShare;
    }

    Widget _timeline() {
      Widget dot(bool on, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            on ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
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
          dot(true, 'orders.created'.tr()),
          dot(order.stamps.preparedAt != null, 'orders.prepared'.tr()),
          dot(order.stamps.handedToCourierAt != null, 'orders.shipping'.tr()),
          dot(order.stamps.deliveredAt != null, 'orders.delivered'.tr()),
          if (order.stamps.cancelledAt != null)
            dot(true, 'orders.cancelled'.tr()),
        ],
      );
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('orders.order_details'.tr(args: [order.code])),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _statusColor(cs, order.status).withOpacity(.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long_outlined),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'orders.order_code_label'.tr(args: [order.code]),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            avatar: const Icon(Icons.flag_outlined, size: 18),
                            label: Text(orderStatusAr(order.status)),
                            backgroundColor: _statusColor(
                              cs,
                              order.status,
                            ).withOpacity(.1),
                            labelStyle: TextStyle(
                              color: _statusColor(cs, order.status),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'orders.buyer_label_simple'.tr(args: [order.buyerId]),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'orders.created_at'.tr(
                          args: [df.format(order.stamps.createdAt)],
                        ),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      _timeline(),
                      if (order.couponCode != null &&
                          order.couponCode!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'orders.coupon_used'.tr(args: [order.couponCode!]),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                      if (order.note != null &&
                          order.note!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 4),
                        Text(
                          'orders.buyer_note'.tr(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(order.note!, textAlign: TextAlign.right),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
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
                          const Icon(Icons.payments_outlined),
                          const SizedBox(width: 8),
                          Text(
                            'orders.financial_summary'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _row(
                        'orders.total_products_all_sellers'.tr(),
                        order.itemsTotal.toStringAsFixed(2),
                      ),
                      _row(
                        'orders.shipping_cost'.tr(),
                        order.shipping.toStringAsFixed(2),
                      ),
                      if (order.discount > 0)
                        _row(
                          'orders.total_discount'.tr(),
                          '- ${order.discount.toStringAsFixed(2)}',
                        ),
                      const Divider(height: 18),
                      _row(
                        'orders.final_total'.tr(),
                        order.grandTotal.toStringAsFixed(2),
                        bold: true,
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 4),
                      Text(
                        'orders.seller_data_title'.tr(),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _row(
                        'orders.your_items_count_label'.tr(),
                        sellerItemsCount.toString(),
                      ),
                      _row(
                        'orders.your_price_before_discount'.tr(),
                        sellerSubtotal.toStringAsFixed(2),
                      ),
                      _row(
                        'orders.your_discount_share'.tr(),
                        sellerDiscountShare > 0
                            ? '- ${sellerDiscountShare.toStringAsFixed(2)}'
                            : '0.00',
                      ),
                      const SizedBox(height: 4),
                      _row(
                        'orders.your_net_value_label'.tr(),
                        sellerNet.toStringAsFixed(2),
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (order.lat != null && order.lng != null)
                Card(
                  elevation: 0,
                  color: cs.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.place_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'orders.coordinates'.tr(
                              args: [
                                order.lat!.toStringAsFixed(5),
                                order.lng!.toStringAsFixed(5),
                              ],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              Card(
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
                          const Icon(Icons.inventory_2_outlined),
                          const SizedBox(width: 8),
                          Text(
                            'orders.your_order_items'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (sellerItems.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'orders.no_items_linked'.tr(),
                            textAlign: TextAlign.right,
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sellerItems.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 14),
                          itemBuilder: (_, i) {
                            final it = sellerItems[i];
                            final lineTotal = it.price * it.qty;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                child: Icon(Icons.shopping_bag_outlined),
                              ),
                              title: Text(
                                '${it.titleSnap} × ${it.qty}',
                                textAlign: TextAlign.right,
                              ),
                              subtitle: Text(
                                'orders.unit_price'.tr(
                                  args: [it.price.toStringAsFixed(2)],
                                ),
                                textAlign: TextAlign.right,
                              ),
                              trailing: Text(lineTotal.toStringAsFixed(2)),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, textAlign: TextAlign.right, style: style),
          ),
          const SizedBox(width: 8),
          Text(value, style: style),
        ],
      ),
    );
  }
}
