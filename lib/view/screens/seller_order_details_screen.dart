import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_spare/core/order_status_localized.dart';

import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class SellerOrderDetailsScreen extends StatelessWidget {
  final OrderDoc order;
  final String sellerId;

  SellerOrderDetailsScreen({
    super.key,
    required this.order,
    required this.sellerId,
  });

  final _moneyFormat = NumberFormat('#,##0.00', 'en');

  String _fmtMoney(double v) => _moneyFormat.format(v);

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
    final loc = AppLocalizations.of(context);
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
          dot(true, loc.sellerOrderTimelineCreated),
          dot(order.stamps.preparedAt != null, loc.sellerOrderTimelinePrepared),
          dot(
            order.stamps.handedToCourierAt != null,
            loc.sellerOrderTimelineWithCourier,
          ),
          dot(
            order.stamps.deliveredAt != null,
            loc.sellerOrderTimelineDelivered,
          ),
          if (order.stamps.cancelledAt != null)
            dot(true, loc.sellerOrderTimelineCancelled),
        ],
      );
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${loc.sellerOrderDetailsTitle} (${order.code})'),
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
                              '${loc.sellerOrderDetailsOrderCodePrefix} ${order.code}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            avatar: const Icon(Icons.flag_outlined, size: 18),
                            label: Text(orderStatusText(context, order.status)),
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
                        '${loc.sellerOrderDetailsBuyerPrefix} ${order.buyerId}',
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.sellerOrderDetailsCreatedAtPrefix} '
                        '${df.format(order.stamps.createdAt)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      _timeline(),
                      if (order.couponCode != null &&
                          order.couponCode!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${loc.sellerOrderDetailsCouponUsedPrefix} '
                          '${order.couponCode}',
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
                          loc.sellerOrderDetailsBuyerNoteTitle,
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
                            loc.sellerOrderDetailsFinancialSummaryTitle,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _row(
                        loc.sellerOrderDetailsTotalItemsAllSellersLabel,
                        '${_fmtMoney(order.itemsTotal)} ${loc.currencyEgp}',
                      ),
                      _row(
                        loc.sellerOrderDetailsShippingLabel,
                        '${_fmtMoney(order.shipping)} ${loc.currencyEgp}',
                      ),
                      if (order.discount > 0)
                        _row(
                          loc.sellerOrderDetailsTotalDiscountLabel,
                          '- ${_fmtMoney(order.discount)} ${loc.currencyEgp}',
                        ),
                      const Divider(height: 18),
                      _row(
                        loc.sellerOrderDetailsGrandTotalLabel,
                        '${_fmtMoney(order.grandTotal)} ${loc.currencyEgp}',
                        bold: true,
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 4),
                      Text(
                        loc.sellerOrderDetailsSellerSectionTitle,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _row(
                        loc.sellerOrderDetailsSellerItemsCountLabel,
                        sellerItemsCount.toString(),
                      ),
                      _row(
                        loc.sellerOrderDetailsSellerSubtotalLabel,
                        '${_fmtMoney(sellerSubtotal)} ${loc.currencyEgp}',
                      ),
                      _row(
                        loc.sellerOrderDetailsSellerDiscountShareLabel,
                        sellerDiscountShare > 0
                            ? '- ${_fmtMoney(sellerDiscountShare)} ${loc.currencyEgp}'
                            : '0.00 ${loc.currencyEgp}',
                      ),
                      const SizedBox(height: 4),
                      _row(
                        loc.sellerOrderDetailsSellerNetLabel,
                        '${_fmtMoney(sellerNet)} ${loc.currencyEgp}',
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
                            '${loc.sellerOrderDetailsCoordsPrefix} '
                            '(${order.lat!.toStringAsFixed(5)}, '
                            '${order.lng!.toStringAsFixed(5)})',
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
                            loc.sellerOrderDetailsItemsSectionTitle,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (sellerItems.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            loc.sellerOrderDetailsNoItemsForSellerMessage,
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
                                '${loc.sellerOrderDetailsUnitPricePrefix} '
                                '${_fmtMoney(it.price)} ${loc.currencyEgp}',
                                textAlign: TextAlign.right,
                              ),
                              trailing: Text(
                                '${_fmtMoney(lineTotal)} ${loc.currencyEgp}',
                              ),
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
