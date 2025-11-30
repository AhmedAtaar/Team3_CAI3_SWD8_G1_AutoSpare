import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          dot(true, 'أُنشئ'),
          dot(order.stamps.preparedAt != null, 'تم التجهيز'),
          dot(order.stamps.handedToCourierAt != null, 'مع الشحن'),
          dot(order.stamps.deliveredAt != null, 'تم الاستلام'),
          if (order.stamps.cancelledAt != null) dot(true, 'أُلغي'),
        ],
      );
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تفاصيل الطلب (${order.code})'),
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
                              'كود الطلب: ${order.code}',
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
                        'المشتري: ${order.buyerId}',
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تاريخ الإنشاء: ${df.format(order.stamps.createdAt)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      _timeline(),
                      if (order.couponCode != null &&
                          order.couponCode!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'كود الخصم المستخدم: ${order.couponCode}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                      if (order.note != null &&
                          order.note!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 4),
                        const Text(
                          'ملاحظة المشتري:',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.w600),
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
                        children: const [
                          Icon(Icons.payments_outlined),
                          SizedBox(width: 8),
                          Text(
                            'ملخص مالي للطلب',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _row(
                        'إجمالي المنتجات (كل البائعين)',
                        order.itemsTotal.toStringAsFixed(2),
                      ),
                      _row('الشحن', order.shipping.toStringAsFixed(2)),
                      if (order.discount > 0)
                        _row(
                          'إجمالي الخصم',
                          '- ${order.discount.toStringAsFixed(2)}',
                        ),
                      const Divider(height: 18),
                      _row(
                        'الإجمالي النهائي للطلب',
                        order.grandTotal.toStringAsFixed(2),
                        bold: true,
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 4),
                      const Text(
                        'بيانات خاصة بك كبائع',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _row(
                        'عدد العناصر التابعة لك',
                        sellerItemsCount.toString(),
                      ),
                      _row(
                        'سعر منتجاتك قبل الخصم',
                        sellerSubtotal.toStringAsFixed(2),
                      ),
                      _row(
                        'نصيبك من الخصم',
                        sellerDiscountShare > 0
                            ? '- ${sellerDiscountShare.toStringAsFixed(2)}'
                            : '0.00',
                      ),
                      const SizedBox(height: 4),
                      _row(
                        'صافي قيمة منتجاتك في هذا الطلب',
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
                            'الإحداثيات: (${order.lat!.toStringAsFixed(5)}, ${order.lng!.toStringAsFixed(5)})',
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
                        children: const [
                          Icon(Icons.inventory_2_outlined),
                          SizedBox(width: 8),
                          Text(
                            'بنود الطلب الخاصة بك',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (sellerItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'لا توجد عناصر مرتبطة بك في هذا الطلب.',
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
                                'سعر الوحدة: ${it.price.toStringAsFixed(2)}',
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
