import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/services/products.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class SellerInventoryTab extends StatefulWidget {
  final String sellerId;
  const SellerInventoryTab({super.key, required this.sellerId});

  @override
  State<SellerInventoryTab> createState() => _SellerInventoryTabState();
}

class _SellerInventoryTabState extends State<SellerInventoryTab> {
  final Map<String, ({int qty, double revenue})> _soldAgg = {};
  StreamSubscription<List<OrderDoc>>? _ordersSub;

  @override
  void initState() {
    super.initState();

    _ordersSub = ordersRepo.watchSellerOrders(widget.sellerId).listen((orders) {
      final agg = <String, ({int qty, double revenue})>{};

      for (final o in orders) {
        if (o.status != OrderStatus.delivered) continue;

        final sellerItems = o.items
            .where((it) => it.sellerId == widget.sellerId)
            .toList();
        if (sellerItems.isEmpty) continue;

        final sellerTotal = sellerItems.fold<double>(
          0.0,
          (p, it) => p + it.price * it.qty,
        );
        if (sellerTotal <= 0) continue;

        double sellerDiscountShare = 0.0;
        if (o.discount > 0) {
          final allItemsTotal = o.itemsTotal <= 0
              ? o.items.fold<double>(0.0, (p, it) => p + it.price * it.qty)
              : o.itemsTotal;

          if (allItemsTotal > 0) {
            final ratio = sellerTotal / allItemsTotal;
            sellerDiscountShare = o.discount * ratio;
          }
        }

        for (final it in sellerItems) {
          final base = it.price * it.qty;
          double net = base;

          if (sellerDiscountShare > 0 && sellerTotal > 0) {
            final itemRatio = base / sellerTotal;
            final itemDisc = sellerDiscountShare * itemRatio;
            net = base - itemDisc;
          }

          final prev = agg[it.productId] ?? (qty: 0, revenue: 0.0);
          agg[it.productId] = (
            qty: prev.qty + it.qty,
            revenue: prev.revenue + net,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _soldAgg
          ..clear()
          ..addAll(agg);
      });
    });
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }

  Future<void> _openRestockDialog(CatalogProduct p) async {
    final loc = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final qtyCtrl = TextEditingController(text: '10');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          '${loc.sellerInventoryRestockDialogTitlePrefix} — ${p.title}',
          textDirection: TextDirection.rtl,
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: loc.sellerInventoryRestockQuantityLabel,
              border: const OutlineInputBorder(),
            ),
            validator: (v) {
              final n = int.tryParse((v ?? '').trim());
              if (n == null || n <= 0) {
                return loc.sellerInventoryRestockQuantityInvalidError;
              }
              if (n > 1000000) {
                return loc.sellerInventoryRestockQuantityTooBigError;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.commonCancel),
          ),
          FilledButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            icon: const Icon(Icons.add),
            label: Text(loc.sellerInventoryRestockAddButton),
          ),
        ],
      ),
    );

    if (ok == true) {
      final delta = int.parse(qtyCtrl.text.trim());

      try {
        await productsRepo.increaseStock(productId: p.id, delta: delta);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${loc.sellerInventoryRestockSuccessPrefix} $delta '
              '${loc.sellerInventoryRestockSuccessInfix} "${p.title}"',
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${loc.sellerInventoryRestockErrorPrefix} $e',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return StreamBuilder<List<CatalogProduct>>(
      stream: productsRepo.watchAllSellerProducts(widget.sellerId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                loc.sellerInventoryErrorLoading,
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        }

        final products = snap.data ?? const <CatalogProduct>[];

        if (products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                loc.sellerInventoryEmptyForSeller,
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        }

        int totalStock = 0, totalSold = 0;
        double totalRevenue = 0;
        for (final p in products) {
          final sold = _soldAgg[p.id]?.qty ?? 0;
          final rev = _soldAgg[p.id]?.revenue ?? 0.0;
          totalStock += p.stock;
          totalSold += sold;
          totalRevenue += rev;
        }

        Widget _header() => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(
                  '${loc.sellerInventoryTotalStockPrefix} $totalStock',
                ),
                avatar: const Icon(Icons.inventory_2_outlined),
              ),
              Chip(
                label: Text('${loc.sellerInventoryTotalSoldPrefix} $totalSold'),
                avatar: const Icon(Icons.shopping_bag_outlined),
              ),
              Chip(
                label: Text(
                  '${loc.sellerInventoryTotalRevenuePrefix} '
                  '${totalRevenue.toStringAsFixed(2)}',
                ),
                avatar: const Icon(Icons.payments_outlined),
              ),
            ],
          ),
        );

        return Column(
          children: [
            _header(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = products[i];
                  final sold = _soldAgg[p.id]?.qty ?? 0;
                  final revenue = _soldAgg[p.id]?.revenue ?? 0.0;
                  final low = p.stock <= 2;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: cs.surfaceContainerHighest,
                            child: const Icon(Icons.done_all_outlined),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${p.title} • ${kBrandName[p.brand]} ${p.model}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip:
                                          loc.sellerInventoryEditStockTooltip,
                                      onPressed: () => _openRestockDialog(p),
                                      icon: const Icon(Icons.edit_note),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Chip(
                                      avatar: const Icon(
                                        Icons.inventory_2_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        '${loc.sellerInventoryStockPrefix} ${p.stock}',
                                      ),
                                      backgroundColor: low
                                          ? cs.errorContainer
                                          : cs.surfaceContainer,
                                      labelStyle: TextStyle(
                                        color: low
                                            ? cs.onErrorContainer
                                            : cs.onSurface,
                                      ),
                                    ),
                                    Chip(
                                      avatar: const Icon(
                                        Icons.shopping_cart_checkout_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        '${loc.sellerInventorySoldPrefix} $sold',
                                      ),
                                    ),
                                    Chip(
                                      avatar: const Icon(
                                        Icons.payments_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        '${loc.sellerInventoryRevenuePrefix} '
                                        '${revenue.toStringAsFixed(2)}',
                                      ),
                                    ),
                                    Chip(
                                      avatar: const Icon(
                                        Icons.tag_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        '${loc.sellerInventoryPricePrefix} '
                                        '${p.price.toStringAsFixed(2)}',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${loc.sellerInventoryYearsPrefix} '
                                  '${p.years.join(', ')}',
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
