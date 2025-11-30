import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/services/user_session.dart';
import 'package:auto_spare/core/earnings_utils.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final _df = DateFormat('yyyy/MM/dd – HH:mm');

  OrderStatus? _statusFilter;

  List<OrderStatus> _allowedNextStatusesForSeller(OrderStatus current) {
    switch (current) {
      case OrderStatus.processing:
        return [OrderStatus.prepared, OrderStatus.cancelled];
      case OrderStatus.prepared:
        return [OrderStatus.handedToCourier, OrderStatus.cancelled];
      case OrderStatus.handedToCourier:
        return [OrderStatus.delivered, OrderStatus.cancelled];
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return const [];
    }
  }

  Future<void> _updateStatus(String orderId, OrderStatus next) async {
    try {
      await ordersRepo.updateStatus(orderId: orderId, next: next);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث حالة الطلب إلى "${orderStatusAr(next)}"'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذّر تحديث الحالة: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final sellerKey = UserSession.username ?? '';

    if (sellerKey.isEmpty) {
      return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('طلبات العملاء')),
          body: const Center(
            child: Text('لا يمكن تحديد هوية البائع لهذا الحساب'),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلبات العملاء')),
        body: StreamBuilder<List<OrderDoc>>(
          stream: ordersRepo.watchSellerOrders(sellerKey),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final all = snap.data ?? const <OrderDoc>[];

            final list = _statusFilter == null
                ? all
                : all.where((o) => o.status == _statusFilter).toList();

            if (list.isEmpty) {
              return Column(
                children: [
                  _buildFilterBar(cs),
                  const Expanded(
                    child: Center(child: Text('لا توجد طلبات حالياً')),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildFilterBar(cs),
                Expanded(
                  child: ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final o = list[i];

                      final itemsForSeller = o.items
                          .where((it) => it.sellerId == sellerKey)
                          .toList();

                      final itemCount = itemsForSeller.fold<int>(
                        0,
                        (a, it) => a + it.qty,
                      );

                      final sellerNet = computeSellerNetForOrder(o, sellerKey);

                      final allowed = _allowedNextStatusesForSeller(o.status);

                      return Card(
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
                            ],
                          ),

                          subtitle: Text(
                            'عناصر: $itemCount • صافي أرباحك من الطلب: ${sellerNet.toStringAsFixed(2)} جنيه',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _df.format(o.stamps.createdAt),
                                style: const TextStyle(fontSize: 11),
                              ),
                              const SizedBox(height: 4),
                              PopupMenuButton<OrderStatus>(
                                tooltip: allowed.isEmpty
                                    ? 'لا يمكن تغيير الحالة'
                                    : 'تحديث حالة الطلب',
                                onSelected: (s) => _updateStatus(o.id, s),
                                itemBuilder: (_) => [
                                  if (allowed.isEmpty)
                                    const PopupMenuItem(
                                      enabled: false,
                                      child: Text('لا توجد حالات متاحة'),
                                    )
                                  else
                                    for (final s in allowed)
                                      PopupMenuItem(
                                        value: s,
                                        child: Text(orderStatusAr(s)),
                                      ),
                                ],
                                child: const Icon(Icons.more_vert),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _stamp('أُنشئ', o.stamps.createdAt),
                                      if (o.stamps.preparedAt != null)
                                        _stamp(
                                          'تم التجهيز',
                                          o.stamps.preparedAt!,
                                        ),
                                      if (o.stamps.handedToCourierAt != null)
                                        _stamp(
                                          'مع الشحن',
                                          o.stamps.handedToCourierAt!,
                                        ),
                                      if (o.stamps.deliveredAt != null)
                                        _stamp(
                                          'تم الاستلام',
                                          o.stamps.deliveredAt!,
                                        ),
                                      if (o.stamps.cancelledAt != null)
                                        _stamp('أُلغِي', o.stamps.cancelledAt!),
                                    ],
                                  ),
                                  const Divider(height: 18),

                                  ListView.separated(
                                    itemCount: itemsForSeller.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 6),
                                    itemBuilder: (_, j) {
                                      final it = itemsForSeller[j];
                                      return Material(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(8),
                                        child: ListTile(
                                          dense: true,
                                          leading: const Icon(
                                            Icons.shopping_bag_outlined,
                                          ),
                                          title: Text(
                                            '${it.titleSnap} × ${it.qty}',
                                          ),
                                          subtitle: Text(
                                            'السعر النهائي: ${it.price.toStringAsFixed(2)}',
                                          ),
                                          trailing: Text(
                                            (it.price * it.qty).toStringAsFixed(
                                              2,
                                            ),
                                          ),
                                        ),
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('تصفية بالحالة:'),
          ChoiceChip(
            label: const Text('الكل'),
            selected: _statusFilter == null,
            onSelected: (_) {
              setState(() => _statusFilter = null);
            },
          ),
          for (final s in OrderStatus.values)
            ChoiceChip(
              label: Text(orderStatusAr(s)),
              selected: _statusFilter == s,
              onSelected: (_) {
                setState(() => _statusFilter = s);
              },
            ),
        ],
      ),
    );
  }

  Widget _stamp(String label, DateTime d) {
    return Chip(
      avatar: const Icon(Icons.schedule, size: 18),
      label: Text('$label: ${DateFormat('MM/dd HH:mm').format(d)}'),
    );
  }
}
