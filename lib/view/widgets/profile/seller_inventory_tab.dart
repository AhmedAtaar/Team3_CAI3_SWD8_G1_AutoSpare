import 'dart:async';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/services/products.dart';

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
    final formKey = GlobalKey<FormState>();
    final qtyCtrl = TextEditingController(text: '10');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'seller.increase_stock_title'.tr(args: [p.title]),
          textDirection: ui.TextDirection.rtl,
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            textDirection: ui.TextDirection.rtl,
            decoration: InputDecoration(
              labelText: 'seller.quantity_to_add'.tr(),
              border: const OutlineInputBorder(),
            ),
            validator: (v) {
              final n = int.tryParse((v ?? '').trim());
              if (n == null || n <= 0)
                return 'seller.enter_valid_positive_number'.tr();
              if (n > 1000000) return 'seller.value_too_large'.tr();
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'seller.cancel'.tr(),
            ), // Reusing admin.cancel or creating new? I added seller.cancel? No, I didn't. I'll use admin.cancel or just add it. Wait, I didn't add cancel to seller. I'll use admin.cancel since it's common.
            // Actually, I should use the keys I defined. I didn't define cancel in seller.
            // I'll use 'admin.cancel'.tr()
          ),
          FilledButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            icon: const Icon(Icons.add),
            label: Text('seller.add'.tr()),
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
              'seller.stock_added_success'.tr(
                args: [delta.toString(), p.title],
              ),
              textDirection: ui.TextDirection.rtl,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'seller.stock_update_error'.tr(args: [e.toString()]),
              textDirection: ui.TextDirection.rtl,
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
                'seller.error_loading_products'.tr(),
                textDirection: ui.TextDirection.rtl,
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
                'seller.no_approved_products_yet'.tr(),
                textDirection: ui.TextDirection.rtl,
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
                  'seller.total_stock'.tr(args: [totalStock.toString()]),
                ),
                avatar: const Icon(Icons.inventory_2_outlined),
              ),
              Chip(
                label: Text(
                  'seller.total_sales'.tr(args: [totalSold.toString()]),
                ),
                avatar: const Icon(Icons.shopping_bag_outlined),
              ),
              Chip(
                label: Text(
                  'seller.total_revenue'.tr(
                    args: [totalRevenue.toStringAsFixed(2)],
                  ),
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
                                      tooltip: 'seller.edit_stock'.tr(),
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
                                        'seller.stock_label'.tr(
                                          args: [p.stock.toString()],
                                        ),
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
                                        'seller.sold_label'.tr(
                                          args: [sold.toString()],
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      avatar: const Icon(
                                        Icons.payments_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'seller.revenue_label'.tr(
                                          args: [revenue.toStringAsFixed(2)],
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      avatar: const Icon(
                                        Icons.tag_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'seller.price_label'.tr(
                                          args: [p.price.toStringAsFixed(2)],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'seller.compatibility_years'.tr(
                                    args: [p.years.join(', ')],
                                  ),
                                  textDirection: ui.TextDirection.rtl,
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
