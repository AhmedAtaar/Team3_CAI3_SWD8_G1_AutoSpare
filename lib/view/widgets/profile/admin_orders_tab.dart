import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:auto_spare/core/order_status_localized.dart';
import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/services/orders_repository.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class AdminOrdersTab extends StatefulWidget {
  final OrdersRepository repo;
  const AdminOrdersTab({super.key, required this.repo});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

enum _SortKey { createdDesc, createdAsc, totalDesc, totalAsc }

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  final _searchCtrl = TextEditingController();
  final Set<OrderStatus> _statuses = <OrderStatus>{};
  DateTimeRange? _range;

  _SortKey _sort = _SortKey.createdDesc;

  int _page = 0;
  static const _pageSize = 10;

  final _df = DateFormat('yyyy/MM/dd – HH:mm');

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchCtrl.clear();
      _statuses.clear();
      _range = null;
      _page = 0;
    });
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final loc = AppLocalizations.of(context);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange:
          _range ??
          DateTimeRange(
            start: DateTime(
              now.year,
              now.month,
              now.day,
            ).subtract(const Duration(days: 30)),
            end: DateTime(now.year, now.month, now.day),
          ),
      helpText: loc.adminOrdersRangePickerHelp,
      saveText: loc.adminOrdersRangePickerSave,
      builder: (ctx, child) =>
          Directionality(textDirection: ui.TextDirection.rtl, child: child!),
    );
    if (picked != null) {
      setState(() {
        _range = picked;
        _page = 0;
      });
    }
  }

  List<OrderDoc> _applyFiltersSort(List<OrderDoc> input) {
    Iterable<OrderDoc> l = input;

    final q = _searchCtrl.text.trim();
    if (q.isNotEmpty) {
      final qq = q.toLowerCase();
      l = l.where((o) {
        final inHeader =
            (o.code.toLowerCase().contains(qq) ||
            o.buyerId.toLowerCase().contains(qq) ||
            o.items.any(
              (it) =>
                  it.productId.toLowerCase().contains(qq) ||
                  it.sellerId.toLowerCase().contains(qq) ||
                  it.titleSnap.toLowerCase().contains(qq),
            ));
        return inHeader;
      });
    }

    if (_statuses.isNotEmpty) {
      l = l.where((o) => _statuses.contains(o.status));
    }

    if (_range != null) {
      final start = DateTime(
        _range!.start.year,
        _range!.start.month,
        _range!.start.day,
      );
      final endExclusive = _range!.end.add(const Duration(days: 1));
      l = l.where(
        (o) =>
            o.stamps.createdAt.isAfter(
              start.subtract(const Duration(microseconds: 1)),
            ) &&
            o.stamps.createdAt.isBefore(endExclusive),
      );
    }

    final list = l.toList();
    list.sort((a, b) {
      switch (_sort) {
        case _SortKey.createdDesc:
          return b.stamps.createdAt.compareTo(a.stamps.createdAt);
        case _SortKey.createdAsc:
          return a.stamps.createdAt.compareTo(b.stamps.createdAt);
        case _SortKey.totalDesc:
          return b.grandTotal.compareTo(a.grandTotal);
        case _SortKey.totalAsc:
          return a.grandTotal.compareTo(b.grandTotal);
      }
    });
    return list;
  }

  Widget _statusChip(OrderStatus s, ColorScheme cs) {
    final selected = _statuses.contains(s);
    IconData icon;
    Color? bg;
    switch (s) {
      case OrderStatus.processing:
        icon = Icons.timelapse_outlined;
        bg = cs.surfaceContainerHighest;
        break;
      case OrderStatus.prepared:
        icon = Icons.inventory_2_outlined;
        bg = cs.surfaceContainer;
        break;
      case OrderStatus.handedToCourier:
        icon = Icons.local_shipping_outlined;
        bg = cs.surfaceContainer;
        break;
      case OrderStatus.delivered:
        icon = Icons.verified_outlined;
        bg = cs.surfaceContainerHigh;
        break;
      case OrderStatus.cancelled:
        icon = Icons.block;
        bg = cs.errorContainer;
        break;
    }
    return FilterChip(
      selected: selected,
      label: Text(orderStatusText(context, s)),
      avatar: Icon(icon, size: 18),
      onSelected: (_) {
        setState(() {
          if (selected) {
            _statuses.remove(s);
          } else {
            _statuses.add(s);
          }
          _page = 0;
        });
      },
      backgroundColor: bg,
      selectedColor: cs.primaryContainer,
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final matLoc = MaterialLocalizations.of(context);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: StreamBuilder<List<OrderDoc>>(
        stream: widget.repo.watchAllOrdersAdmin(),
        builder: (_, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${loc.adminOrdersErrorLoadingPrefix}\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final raw = snap.data ?? const <OrderDoc>[];
          final filtered = _applyFiltersSort(raw);

          final total = filtered.length;
          final pages = total == 0 ? 0 : (total / _pageSize).ceil();
          if (pages == 0) _page = 0;
          if (pages > 0 && _page >= pages) _page = pages - 1;

          final start = pages == 0 ? 0 : _page * _pageSize;
          final end = pages == 0 ? 0 : (start + _pageSize).clamp(0, total);

          final pageList = (filtered.isEmpty || start >= end)
              ? <OrderDoc>[]
              : filtered.sublist(start, end);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 220,
                            maxWidth: 380,
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() => _page = 0),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: loc.adminOrdersSearchHint,
                              border: const OutlineInputBorder(),
                              isDense: true,
                              suffixIcon: _searchCtrl.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip:
                                          loc.adminOrdersClearSearchTooltip,
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _page = 0);
                                      },
                                      icon: const Icon(Icons.clear),
                                    ),
                            ),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _pickRange,
                          icon: const Icon(Icons.calendar_month),
                          label: Text(
                            _range == null
                                ? loc.adminOrdersRangeAllLabel
                                : '${DateFormat('yyyy/MM/dd').format(_range!.start)} → '
                                      '${DateFormat('yyyy/MM/dd').format(_range!.end)}',
                          ),
                        ),
                        if (_range != null)
                          IconButton(
                            tooltip:
                                loc.adminOrdersPaginationRemoveRangeTooltip,
                            onPressed: () => setState(() => _range = null),
                            icon: const Icon(Icons.close),
                          ),
                        DropdownButton<_SortKey>(
                          value: _sort,
                          onChanged: (v) => setState(() => _sort = v ?? _sort),
                          items: [
                            DropdownMenuItem(
                              value: _SortKey.createdDesc,
                              child: Text(loc.adminOrdersSortCreatedDesc),
                            ),
                            DropdownMenuItem(
                              value: _SortKey.createdAsc,
                              child: Text(loc.adminOrdersSortCreatedAsc),
                            ),
                            DropdownMenuItem(
                              value: _SortKey.totalDesc,
                              child: Text(loc.adminOrdersSortTotalDesc),
                            ),
                            DropdownMenuItem(
                              value: _SortKey.totalAsc,
                              child: Text(loc.adminOrdersSortTotalAsc),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.refresh),
                          label: Text(loc.adminOrdersResetFiltersButton),
                        ),
                        const SizedBox(width: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _statusChip(OrderStatus.processing, cs),
                            _statusChip(OrderStatus.prepared, cs),
                            _statusChip(OrderStatus.handedToCourier, cs),
                            _statusChip(OrderStatus.delivered, cs),
                            _statusChip(OrderStatus.cancelled, cs),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${loc.adminOrdersMatchingCountPrefix} $total',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: pageList.isEmpty
                    ? Center(child: Text(loc.adminOrdersNoMatchingMessage))
                    : ListView.separated(
                        itemCount: pageList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final o = pageList[i];
                          final itemsCount = o.items.fold<int>(
                            0,
                            (a, it) => a + it.qty,
                          );
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
                                    '(${o.code})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      orderStatusText(context, o.status),
                                    ),
                                    avatar: const Icon(
                                      Icons.flag_outlined,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${loc.adminOrdersBuyerPrefix} ${o.buyerId} • '
                                '${loc.adminOrdersItemsCountPrefix} $itemsCount • '
                                '${loc.adminOrdersGrandTotalPrefix} '
                                '${o.grandTotal.toStringAsFixed(2)}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _df.format(o.stamps.createdAt),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    0,
                                    12,
                                    12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                          if (o.stamps.handedToCourierAt !=
                                              null)
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
                                      const SizedBox(height: 8),
                                      Text(
                                        '${loc.adminOrdersGeoAddressPrefix} '
                                        '${o.lat == null ? '—' : o.lat!.toStringAsFixed(5)}, '
                                        '${o.lng == null ? '' : o.lng!.toStringAsFixed(5)}',
                                      ),
                                      const Divider(height: 18),
                                      ListView.separated(
                                        itemCount: o.items.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 8),
                                        itemBuilder: (_, j) {
                                          final it = o.items[j];
                                          return Material(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerLowest,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: ListTile(
                                              dense: true,
                                              leading: const Icon(
                                                Icons.shopping_bag_outlined,
                                              ),
                                              title: Text(
                                                '${it.titleSnap} × ${it.qty}',
                                              ),
                                              subtitle: Text(
                                                'البائع: ${it.sellerId} • السعر: '
                                                '${it.price.toStringAsFixed(2)}',
                                              ),
                                              trailing: Text(
                                                (it.price * it.qty)
                                                    .toStringAsFixed(2),
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
              Row(
                children: [
                  Text('${loc.adminOrdersTotalFooterPrefix} $total'),
                  const Spacer(),
                  IconButton(
                    tooltip: matLoc.firstPageTooltip,
                    onPressed: (_page > 0)
                        ? () => setState(() => _page = 0)
                        : null,
                    icon: const Icon(Icons.first_page),
                  ),
                  IconButton(
                    tooltip: matLoc.previousPageTooltip,
                    onPressed: (_page > 0)
                        ? () => setState(() => _page -= 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                  Text(
                    '${loc.adminOrdersPageLabel} '
                    '${pages == 0 ? 0 : (_page + 1)} / $pages',
                  ),
                  IconButton(
                    tooltip: matLoc.nextPageTooltip,
                    onPressed: (pages > 0 && (_page + 1) < pages)
                        ? () => setState(() => _page += 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    tooltip: matLoc.lastPageTooltip,
                    onPressed: (pages > 0 && (_page + 1) < pages)
                        ? () => setState(() => _page = pages - 1)
                        : null,
                    icon: const Icon(Icons.last_page),
                  ),
                ],
              ),
            ],
          );
        },
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
