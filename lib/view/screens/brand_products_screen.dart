import 'package:flutter/material.dart';
import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/view/screens/product_details_screen.dart';
import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:auto_spare/controller/navigation/navigation.dart';

class BrandProductsScreen extends StatefulWidget {
  final CarBrand brand;
  final String? logoUrl; // ⬅️ شعار الماركة (اختياري)

  const BrandProductsScreen({
    super.key,
    required this.brand,
    this.logoUrl,
  });

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

enum _SortBy { newest, priceLow, priceHigh, stockHigh }

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  String _query = '';
  _SortBy _sortBy = _SortBy.newest;

  List<CatalogProduct> _filtered() {
    // 1) منتجات الماركة
    var list = Catalog().all().where((p) => p.brand == widget.brand).toList();

    // 2) بحث نصي
    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      list = list.where((p) {
        final title = p.title.toLowerCase();
        final model = p.model.toLowerCase();
        final years = p.years.join(',').toLowerCase();
        return title.contains(q) || model.contains(q) || years.contains(q);
      }).toList();
    }

    // 3) ترتيب
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
    final brandName = kBrandName[widget.brand] ?? widget.brand.name;
    final products = _filtered();

    // ========= الهيدر (اسم + شعار) =========
    Widget header() => Row(
      children: [
        Expanded(
          child: Text(
            'منتجات $brandName',
            textDirection: TextDirection.rtl,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (widget.logoUrl != null && widget.logoUrl!.isNotEmpty)
          Container(
            height: 40,
            width: 40,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: cs.surface,
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Image.network(
              widget.logoUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported_outlined),
            ),
          ),
      ],
    );

    // ========= شريط البحث + الترتيب =========
    Widget searchAndSort() => Row(
      children: [
        Expanded(
          child: TextField(
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'ابحث داخل $brandName...',
              prefixIcon:
              const Icon(Icons.search, color: AppColors.primaryGreen),
              filled: true,
              fillColor: cs.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<_SortBy>(
          value: _sortBy,
          underline: const SizedBox.shrink(),
          items: const [
            DropdownMenuItem(value: _SortBy.newest, child: Text('الأحدث')),
            DropdownMenuItem(
                value: _SortBy.priceLow, child: Text('السعر: من الأقل')),
            DropdownMenuItem(
                value: _SortBy.priceHigh, child: Text('السعر: من الأعلى')),
            DropdownMenuItem(
                value: _SortBy.stockHigh, child: Text('المخزون الأعلى')),
          ],
          onChanged: (v) => setState(() => _sortBy = v ?? _sortBy),
        ),
      ],
    );

    // ========= شبكة المنتجات =========
    Widget grid() {
      if (products.isEmpty) {
        return const Center(child: Text('لا توجد منتجات لهذه الماركة حالياً'));
      }
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.74,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => _ProductCard(p: products[i]),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppNavigationScaffold(
        // ⬅️ يظهر الـ AppBar + Bottom Navigation
        title: 'منتجات $brandName',
        currentIndex: 1, // داخل التبويب "التصنيفات"
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: header(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: searchAndSort(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('عدد النتائج: ${products.length}',
                    style: const TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(child: grid()),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final CatalogProduct p;
  const _ProductCard({required this.p});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget thumb() {
      if (p.imageUrl == null || p.imageUrl!.isEmpty) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: const Center(child: Icon(Icons.image_outlined, size: 36)),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          p.imageUrl!,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 120,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: const Center(child: Icon(Icons.broken_image_outlined)),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailsScreen(p: p)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            thumb(),
            const SizedBox(height: 8),
            Text(
              p.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 4),
            Text(
              'الموديل: ${p.model}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'السنوات: ${p.years.join(', ')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${p.price.toStringAsFixed(2)} ج',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                    (p.stock > 0 ? Colors.green : Colors.red).withOpacity(.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: p.stock > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    p.stock > 0 ? 'متاح: ${p.stock}' : 'غير متاح',
                    style: TextStyle(
                      color: p.stock > 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
