import 'package:auto_spare/controller/navigation/navigation.dart';
import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/services/products.dart';
import 'package:auto_spare/view/screens/brand_products_screen.dart';
import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:auto_spare/view/widgets/categories_screen_widgets/category_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  static const Map<CarBrand, String> _brandLogos = {
    CarBrand.bmw: 'assets/images/BMW.png',
    CarBrand.hyundai: 'assets/images/Hyundai.png',
    CarBrand.kia: 'assets/images/Kia.png',
    CarBrand.mercedes: 'assets/images/Mercedec.png',
    CarBrand.nissan: 'assets/images/Nissan.png',
    CarBrand.toyota: 'assets/images/Toyota.png',
  };

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: AppNavigationScaffold(
        title: loc.nav_categories,
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
                  loc.categories_error_loading,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                  ),
                ),
              );
            }

            final products = snap.data ?? const <CatalogProduct>[];
            var cats = _buildCategoriesFromProducts(products);

            final q = _searchCtrl.text.trim().toLowerCase();
            if (q.isNotEmpty) {
              cats = cats
                  .where((c) => c.title.toLowerCase().contains(q))
                  .toList();
            }

            if (cats.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(loc.home_no_products_available),
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
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                          cursorColor: AppColors.primaryGreen,
                          decoration: InputDecoration(
                            hintText: loc.categories_search_hint,
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.primaryGreen,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF0B1120)
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    loc.categories_title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.categories_subtitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
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
