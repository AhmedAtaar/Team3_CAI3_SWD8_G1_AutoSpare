import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:auto_spare/core/order_status_localized.dart';
import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/services/user_session.dart';
import 'package:auto_spare/core/earnings_utils.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final _df = DateFormat('yyyy/MM/dd – HH:mm');
  final _moneyFormat = NumberFormat('#,##0.00', 'en');

  String _fmtMoney(double v) => _moneyFormat.format(v);

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
    final loc = AppLocalizations.of(context);

    try {
      await ordersRepo.updateStatus(orderId: orderId, next: next);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${loc.sellerOrdersUpdateStatusSuccessPrefix} '
            '"${orderStatusText(context, next)}"',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.sellerOrdersUpdateStatusErrorPrefix} $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    final sellerKey = UserSession.username ?? '';

    if (sellerKey.isEmpty) {
      return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text(loc.sellerOrdersTitle)),
          body: Center(child: Text(loc.sellerDashboardUnknownSellerMessage)),
        ),
      );
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(loc.sellerOrdersTitle)),
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
                  _buildFilterBar(cs, loc),
                  Expanded(
                    child: Center(child: Text(loc.sellerOrdersNoOrdersMessage)),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildFilterBar(cs, loc),
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
                                label: Text(orderStatusText(context, o.status)),
                                avatar: const Icon(
                                  Icons.flag_outlined,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${loc.sellerOrdersSubtitleItemsPrefix} $itemCount '
                            '${loc.sellerOrdersSubtitleNetPrefix} '
                            '${_fmtMoney(sellerNet)} ${loc.currencyEgp}',
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
                                    ? loc.sellerOrdersStatusChangeNotAllowedTooltip
                                    : loc.sellerOrdersStatusChangeTooltip,
                                onSelected: (s) => _updateStatus(o.id, s),
                                itemBuilder: (_) => [
                                  if (allowed.isEmpty)
                                    PopupMenuItem(
                                      enabled: false,
                                      child: Text(
                                        loc.sellerOrdersNoAvailableStatusesMenuLabel,
                                      ),
                                    )
                                  else
                                    for (final s in allowed)
                                      PopupMenuItem(
                                        value: s,
                                        child: Text(
                                          orderStatusText(context, s),
                                        ),
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
                                      _stamp(
                                        loc.sellerOrderTimelineCreated,
                                        o.stamps.createdAt,
                                      ),
                                      if (o.stamps.preparedAt != null)
                                        _stamp(
                                          loc.sellerOrderTimelinePrepared,
                                          o.stamps.preparedAt!,
                                        ),
                                      if (o.stamps.handedToCourierAt != null)
                                        _stamp(
                                          loc.sellerOrderTimelineWithCourier,
                                          o.stamps.handedToCourierAt!,
                                        ),
                                      if (o.stamps.deliveredAt != null)
                                        _stamp(
                                          loc.sellerOrderTimelineDelivered,
                                          o.stamps.deliveredAt!,
                                        ),
                                      if (o.stamps.cancelledAt != null)
                                        _stamp(
                                          loc.sellerOrderTimelineCancelled,
                                          o.stamps.cancelledAt!,
                                        ),
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
                                      final lineTotal = it.price * it.qty;

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
                                            '${loc.sellerOrdersFinalPricePrefix} '
                                            '${_fmtMoney(it.price)} ${loc.currencyEgp}',
                                          ),
                                          trailing: Text(
                                            '${_fmtMoney(lineTotal)} ${loc.currencyEgp}',
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

  Widget _buildFilterBar(ColorScheme cs, AppLocalizations loc) {
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
          Text(loc.sellerOrdersFilterByStatusLabel),
          ChoiceChip(
            label: Text(loc.sellerOrdersFilterAllLabel),
            selected: _statusFilter == null,
            onSelected: (_) {
              setState(() => _statusFilter = null);
            },
          ),
          for (final s in OrderStatus.values)
            ChoiceChip(
              label: Text(orderStatusText(context, s)),
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
