import 'dart:async';
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
        for (final it in o.items.where((e) => e.sellerId == widget.sellerId)) {
          final prev = agg[it.productId] ?? (qty: 0, revenue: 0.0);
          agg[it.productId] = (
            qty: prev.qty + it.qty,
            revenue: prev.revenue + (it.price * it.qty),
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
          'زيادة مخزون — ${p.title}',
          textDirection: TextDirection.rtl,
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'الكمية المطلوب إضافتها',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final n = int.tryParse((v ?? '').trim());
              if (n == null || n <= 0) return 'أدخل رقمًا صحيحًا أكبر من صفر';
              if (n > 1000000) return 'قيمة كبيرة جدًا';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة'),
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
              'تمت إضافة $delta إلى مخزون "${p.title}"',
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر تعديل المخزون: $e',
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
                'حدث خطأ أثناء تحميل المنتجات',
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        }

        final products = snap.data ?? const <CatalogProduct>[];

        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'لا توجد منتجات مقبولة لهذا البائع حتى الآن',
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
                label: Text('إجمالي المخزون: $totalStock'),
                avatar: const Icon(Icons.inventory_2_outlined),
              ),
              Chip(
                label: Text('إجمالي المبيعات: $totalSold'),
                avatar: const Icon(Icons.shopping_bag_outlined),
              ),
              Chip(
                label: Text(
                  'الإيراد الكلي: ${totalRevenue.toStringAsFixed(2)}',
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
                                      tooltip: 'تعديل المخزون',
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
                                      label: Text('المخزون: ${p.stock}'),
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
                                      label: Text('المباع: $sold'),
                                    ),
                                    Chip(
                                      avatar: const Icon(
                                        Icons.payments_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'الإيراد: ${revenue.toStringAsFixed(2)}',
                                      ),
                                    ),
                                    Chip(
                                      avatar: const Icon(
                                        Icons.tag_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'السعر: ${p.price.toStringAsFixed(2)}',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'سنوات الملاءمة: ${p.years.join(', ')}',
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
