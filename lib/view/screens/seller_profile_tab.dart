import 'package:flutter/material.dart';

import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/services/user_session.dart';
import 'package:auto_spare/services/products.dart';
import 'package:auto_spare/view/widgets/profile/seller_inventory_tab.dart';
import 'package:auto_spare/view/screens/seller_orders_screen.dart';
import 'package:auto_spare/core/app_fees.dart';
import 'package:auto_spare/view/screens/seller_coupons_screen.dart';
import 'package:auto_spare/view/screens/seller_dashboard_screen.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class SellerProfileTab extends StatefulWidget {
  const SellerProfileTab({super.key});

  @override
  State<SellerProfileTab> createState() => _SellerProfileTabState();
}

class _SellerProfileTabState extends State<SellerProfileTab> {
  Future<void> _openNewProductSheet() async {
    final loc = AppLocalizations.of(context);

    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageCtrl = TextEditingController();

    CarBrand brand = CarBrand.nissan;
    String model = kModelsByBrand[CarBrand.nissan]!.first;
    final Set<int> selectedYears = {};
    final stockCtrl = TextEditingController(text: '1');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        final insets = MediaQuery.of(context).viewInsets;
        return Padding(
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: StatefulBuilder(
                builder: (context, setSheet) {
                  final models = kModelsByBrand[brand]!;
                  if (!models.contains(model)) model = models.first;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          loc.sellerProfileNewProductSheetTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: titleCtrl,
                          decoration: InputDecoration(
                            labelText: loc.sellerProfileNewProductTitleLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? loc.sellerProfileFieldRequiredError
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: loc.sellerProfileNewProductPriceLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return loc.sellerProfileFieldRequiredError;
                            }
                            final d = double.tryParse(v);
                            if (d == null || d <= 0) {
                              return loc
                                  .sellerProfileNewProductPriceInvalidError;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: descCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: loc.sellerProfileNewProductDescLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? loc.sellerProfileFieldRequiredError
                              : null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<CarBrand>(
                          value: brand,
                          decoration: InputDecoration(
                            labelText: loc.sellerProfileNewProductBrandLabel,
                            border: const OutlineInputBorder(),
                          ),
                          items: CarBrand.values
                              .map(
                                (b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(kBrandName[b]!),
                                ),
                              )
                              .toList(),
                          onChanged: (b) {
                            if (b == null) return;
                            setSheet(() {
                              brand = b;
                              model = kModelsByBrand[brand]!.first;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: model,
                          decoration: InputDecoration(
                            labelText: loc.sellerProfileNewProductModelLabel,
                            border: const OutlineInputBorder(),
                          ),
                          items: kModelsByBrand[brand]!
                              .map(
                                (m) => DropdownMenuItem<String>(
                                  value: m,
                                  child: Text(m),
                                ),
                              )
                              .toList(),
                          onChanged: (m) => setSheet(() => model = m ?? model),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          loc.sellerProfileNewProductYearsLabel,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: kYears
                              .map(
                                (y) => FilterChip(
                                  label: Text('$y'),
                                  selected: selectedYears.contains(y),
                                  onSelected: (sel) => setSheet(() {
                                    if (sel) {
                                      selectedYears.add(y);
                                    } else {
                                      selectedYears.remove(y);
                                    }
                                  }),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: loc.sellerProfileNewProductStockLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 0) {
                              return loc
                                  .sellerProfileNewProductStockInvalidError;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: imageCtrl,
                          decoration: InputDecoration(
                            labelText: loc.sellerProfileNewProductImageLabel,
                            hintText: loc.sellerProfileNewProductImageHint,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }
                            if (selectedYears.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    loc.sellerProfileNewProductSelectYearSnack,
                                  ),
                                ),
                              );
                              return;
                            }

                            final sellerName = UserSession.username ?? 'Seller';
                            final id =
                                'P-${DateTime.now().millisecondsSinceEpoch}';

                            final product = CatalogProduct(
                              id: id,
                              title: titleCtrl.text.trim(),
                              seller: sellerName,
                              price: double.parse(priceCtrl.text.trim()),
                              imageUrl: imageCtrl.text.trim().isEmpty
                                  ? null
                                  : imageCtrl.text.trim(),
                              brand: brand,
                              model: model,
                              years: selectedYears.toList()..sort(),
                              stock: int.parse(stockCtrl.text.trim()),
                              createdAt: DateTime.now(),
                              status: ProductStatus.pending,
                              rejectionReason: null,
                              description: descCtrl.text.trim(),
                            );

                            try {
                              await productsRepo.upsertProduct(product);
                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    loc.sellerProfileNewProductSubmittedSnack,
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${loc.sellerProfileNewProductSaveErrorPrefix} $e',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                          label: Text(loc.sellerProfileNewProductSubmitButton),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          loc.sellerProfileNewProductInfoTitle,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.sellerProfileNewProductInfoBody(
                            (kAppFeePercent * 100).toStringAsFixed(0),
                          ),
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sellerList(List<CatalogProduct> list) {
    final loc = AppLocalizations.of(context);

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            loc.sellerProfileNoProductsInTabMessage,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final p = list[i];
        final cs = Theme.of(context).colorScheme;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(p.title.isNotEmpty ? p.title[0].toUpperCase() : '?'),
            ),
            title: Text(p.title, textAlign: TextAlign.right),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${loc.sellerProfileProductBrandPrefix} '
                  '${kBrandName[p.brand]} • '
                  '${loc.sellerProfileProductModelPrefix} ${p.model}',
                  textAlign: TextAlign.right,
                ),
                Text(
                  '${loc.sellerProfileProductPricePrefix} '
                  '${p.price.toStringAsFixed(2)} ${loc.currencyEgp} • '
                  '${loc.sellerProfileProductStockPrefix} ${p.stock}',
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            trailing: Chip(
              backgroundColor: cs.surfaceVariant,
              label: Text(
                p.status == ProductStatus.approved
                    ? loc.sellerProfileProductStatusApprovedLabel
                    : (p.status == ProductStatus.pending
                          ? loc.sellerProfileProductStatusPendingLabel
                          : loc.sellerProfileProductStatusRejectedLabel),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final sellerId = UserSession.username ?? 'Seller';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 50, color: cs.primary),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
            FilledButton.icon(
              onPressed: _openNewProductSheet,
              icon: const Icon(Icons.add),
              label: Text(loc.sellerProfileAddProductButton),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    labelStyle: const TextStyle(fontSize: 12),
                    tabs: [
                      Tab(text: loc.sellerProfileTabPending),
                      Tab(text: loc.sellerProfileTabApproved),
                      Tab(text: loc.sellerProfileTabRejected),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<List<CatalogProduct>>(
                      stream: productsRepo.watchAllSellerProducts(sellerId),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting &&
                            !snap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snap.hasError) {
                          return Center(
                            child: Text(
                              loc.sellerProfileErrorLoadingProducts,
                              textAlign: TextAlign.right,
                            ),
                          );
                        }

                        final all = snap.data ?? const <CatalogProduct>[];

                        final pending = all
                            .where((p) => p.status == ProductStatus.pending)
                            .toList();
                        final approved = all
                            .where((p) => p.status == ProductStatus.approved)
                            .toList();
                        final rejected = all
                            .where((p) => p.status == ProductStatus.rejected)
                            .toList();

                        return TabBarView(
                          children: [
                            _sellerList(pending),
                            _sellerList(approved),
                            _RejectedList(list: rejected),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SellerDashboardScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.insights_outlined),
                label: Text(loc.sellerProfileDashboardButtonLabel),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SellerOrdersScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: Text(loc.sellerProfileOrdersButtonLabel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SellerInventoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.inventory_2_outlined),
                label: Text(loc.sellerProfileInventoryButtonLabel),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SellerCouponsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.discount_outlined),
                label: Text(loc.sellerProfileCouponsButtonLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SellerInventoryScreen extends StatelessWidget {
  const SellerInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerId = UserSession.username ?? 'Seller';
    final loc = AppLocalizations.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.sellerProfileInventoryScreenTitle),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SellerInventoryTab(sellerId: sellerId),
        ),
      ),
    );
  }
}

class _RejectedList extends StatelessWidget {
  final List<CatalogProduct> list;

  const _RejectedList({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            loc.sellerProfileRejectedEmptyMessage,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final p = list[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: Text(p.title, textAlign: TextAlign.right),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${loc.sellerProfileProductBrandPrefix} '
                  '${kBrandName[p.brand]} • '
                  '${loc.sellerProfileProductModelPrefix} ${p.model}',
                  textAlign: TextAlign.right,
                ),
                Text(
                  '${loc.sellerProfileRejectedPricePrefix} '
                  '${p.price.toStringAsFixed(2)} ${loc.currencyEgp}',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  p.rejectionReason == null || p.rejectionReason!.trim().isEmpty
                      ? loc.sellerProfileRejectedReasonUnknown
                      : '${loc.sellerProfileRejectedReasonPrefix} '
                            '${p.rejectionReason}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
