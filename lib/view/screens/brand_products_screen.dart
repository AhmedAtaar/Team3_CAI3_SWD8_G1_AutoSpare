import 'package:flutter/material.dart';

import 'package:auto_spare/model/product.dart';
import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/model/product.dart';
import 'package:auto_spare/services/products.dart';
import 'package:auto_spare/view/screens/product_details_screen.dart';
import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:auto_spare/controller/navigation/navigation.dart';
import 'package:auto_spare/view/widgets/home_screen_widgets/product_card.dart';
import 'package:auto_spare/core/app_fees.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class BrandProductsScreen extends StatefulWidget {
  final CarBrand brand;
  final String? logoAssetPath;

  const BrandProductsScreen({
    super.key,
    required this.brand,
    this.logoAssetPath,
  });

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

enum _SortBy { newest, priceLow, priceHigh, stockHigh }

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  String _query = '';
  _SortBy _sortBy = _SortBy.newest;

  List<CatalogProduct> _filtered(List<CatalogProduct> all) {
    var list = all.where((p) => p.brand == widget.brand).toList();

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      list = list.where((p) {
        final title = p.title.toLowerCase();
        final model = p.model.toLowerCase();
        final years = p.years.join(',').toLowerCase();
        return title.contains(q) || model.contains(q) || years.contains(q);
      }).toList();
    }

    list.sort((a, b) {
      switch (_sortBy) {
        case _SortBy.priceLow:
          return a.price.compareTo(b.price);
        case _SortBy.priceHigh:
          return b.price.compareTo(a.price);
        case _SortBy.stockHigh:
          return b.stock.compareTo(a.stock);
        case _SortBy.newest:
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final brandName = kBrandName[widget.brand] ?? widget.brand.name;

    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final double bottomPadding = bottomInset > 0 ? bottomInset + 16 : 100;

    final screenTitle = '${loc.brandProductsTitle} $brandName';

    Widget appLogoChip() {
      final chipBg = theme.colorScheme.primary.withOpacity(.10);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(.25)),
        ),
        child: Text(
          'AutoSpare',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    Widget header() => Row(
      children: [
        Expanded(
          child: Text(
            screenTitle,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (widget.logoAssetPath != null && widget.logoAssetPath!.isNotEmpty)
          Container(
            height: 40,
            width: 40,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: cs.surface,
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Image.asset(widget.logoAssetPath!, fit: BoxFit.contain),
          ),
      ],
    );

    Widget searchAndSort() => Row(
      children: [
        Expanded(
          child: TextField(
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            decoration: InputDecoration(
              hintText: loc.searchHint,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryGreen,
              ),
              filled: true,
              fillColor: cs.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
            ),
            onChanged: (v) {
              setState(() {
                _query = v;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 150,
          child: DropdownButton<_SortBy>(
            isExpanded: true,
            value: _sortBy,
            underline: const SizedBox.shrink(),
            items: [
              DropdownMenuItem(
                value: _SortBy.newest,
                child: Text(loc.sortNewest),
              ),
              DropdownMenuItem(
                value: _SortBy.priceLow,
                child: Text(loc.sortPriceLow),
              ),
              DropdownMenuItem(
                value: _SortBy.priceHigh,
                child: Text(loc.sortPriceHigh),
              ),
              DropdownMenuItem(
                value: _SortBy.stockHigh,
                child: Text(loc.sortStockHigh),
              ),
            ],
            onChanged: (v) {
              setState(() {
                _sortBy = v ?? _SortBy.newest;
              });
            },
          ),
        ),
      ],
    );

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: AppNavigationScaffold(
        title: screenTitle,
        currentIndex: 1,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: StreamBuilder<List<CatalogProduct>>(
            stream: productsRepo.watchApprovedProducts(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snap.hasError) {
                return Center(
                  child: Text(
                    loc.admin_products_error_loading,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final all = snap.data ?? const <CatalogProduct>[];
              final products = _filtered(all);

              if (products.isEmpty) {
                return Center(child: Text(loc.noProducts));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchAndSort(),
                  const SizedBox(height: 8),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: appLogoChip(),
                          ),
                          const SizedBox(height: 8),
                          header(),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${loc.brand_products_results_count_prefix} ${products.length}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: .8,
                                ),
                            itemBuilder: (context, index) {
                              final c = products[index];

                              final double displayPrice = applyAppFee(c.price);

                              final cardData = Product(
                                title:
                                    '${c.title} • ${kBrandName[c.brand]} ${c.model} • ${c.years.join(', ')}',
                                price: displayPrice.toStringAsFixed(2),
                                imageUrl: c.imageUrl,
                                badge: null,
                              );

                              return ProductCard(
                                item: cardData,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductDetailsScreen(p: c),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
