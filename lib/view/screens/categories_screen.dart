import 'package:auto_spare/controller/navigation/navigation.dart';
import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/services/products.dart';
import 'package:auto_spare/view/screens/brand_products_screen.dart';
import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:auto_spare/view/widgets/categories_screen_widgets/category_tile_widget.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const Map<CarBrand, String> _brandLogos = {
    CarBrand.bmw: 'assets/images/BMW.png',
    CarBrand.hyundai: 'assets/images/Hyundai.png',
    CarBrand.kia: 'assets/images/Kia.png',
    CarBrand.mercedes: 'assets/images/Mercedec.png',
    CarBrand.nissan: 'assets/images/Nissan.png',
    CarBrand.toyota: 'assets/images/Toyota.png',
  };

  List<_BrandCat> _buildCategoriesFromProducts(List<CatalogProduct> items) {
    final Map<CarBrand, int> counts = {for (final b in CarBrand.values) b: 0};
    for (final p in items) {
      counts[p.brand] = (counts[p.brand] ?? 0) + 1;
    }

    final list = CarBrand.values
        .map(
          (b) => _BrandCat(
            brand: b,
            title: kBrandName[b] ?? b.name,
            count: counts[b] ?? 0,
            imagePath: _brandLogos[b] ?? '',
          ),
        )
        .toList();

    list.sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppNavigationScaffold(
        title: "التصنيفات",
        currentIndex: 1,
        body: StreamBuilder<List<CatalogProduct>>(
          stream: productsRepo.watchApprovedProducts(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ أثناء تحميل التصنيفات',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                  ),
                ),
              );
            }

            final products = snap.data ?? const <CatalogProduct>[];
            final cats = _buildCategoriesFromProducts(products);

            if (cats.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('لا توجد منتجات متاحة حالياً'),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن قطع، علامات تجارية، موديلات...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primaryGreen,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'التصنيفات',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تصفح القطع حسب الماركة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: cats.length,
                    itemBuilder: (context, index) {
                      final c = cats[index];
                      return CategoryTile(
                        imagePath: c.imagePath,
                        title: c.title,
                        itemCount: c.count,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BrandProductsScreen(
                                brand: c.brand,

                                logoAssetPath: c.imagePath,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandCat {
  final CarBrand brand;
  final String title;
  final int count;
  final String imagePath;

  _BrandCat({
    required this.brand,
    required this.title,
    required this.count,
    required this.imagePath,
  });
}
