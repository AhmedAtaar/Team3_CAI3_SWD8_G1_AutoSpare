import 'package:flutter/material.dart';

import 'package:auto_spare/model/product.dart';
import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/services/products_repository.dart';
import 'package:auto_spare/view/widgets/home_screen_widgets/product_card.dart';

import 'categories_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'tow_screen.dart';
import 'product_details_screen.dart';
import 'package:auto_spare/services/products.dart';
import 'package:auto_spare/services/tow_badge_stream.dart';
import 'package:auto_spare/view/widgets/navigation/global_bottom_nav.dart';
import 'package:auto_spare/core/app_fees.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _SortBy { newest, oldest, priceLow, priceHigh, stockHigh }

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _bottomIndex = 0;

  _SortBy _sortBy = _SortBy.newest;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CatalogProduct> _filterProducts(List<CatalogProduct> source) {
    final q = _searchCtrl.text.trim().toLowerCase();

    List<CatalogProduct> list;
    if (q.isEmpty) {
      list = List<CatalogProduct>.from(source);
    } else {
      list = source.where((c) {
        final text =
            '${c.title} ${kBrandName[c.brand]} ${c.model} ${c.years.join(' ')} ${c.seller}'
                .toLowerCase();
        return text.contains(q);
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
        case _SortBy.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case _SortBy.newest:
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: _buildAppBar(theme),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: StreamBuilder<List<CatalogProduct>>(
            stream: productsRepo.watchApprovedProducts(),
            builder: (context, snapshot) {
              final allProducts = snapshot.data ?? const <CatalogProduct>[];

              if (snapshot.connectionState == ConnectionState.waiting &&
                  allProducts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (allProducts.isEmpty) {
                return const Center(child: Text('لا توجد منتجات متاحة حالياً'));
              }

              final items = _filterProducts(allProducts);

              if (items.isEmpty) {
                return const Center(child: Text('لا توجد نتائج مطابقة لبحثك'));
              }

              final double bottomPadding = bottomInset > 0
                  ? bottomInset + 16
                  : 100;

              return GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: .8,
                ),
                padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPadding),
                itemBuilder: (context, index) {
                  final c = items[index];

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
                          builder: (_) => ProductDetailsScreen(p: c),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        bottomNavigationBar: const GlobalBottomNav(currentIndex: 0),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    final borderColor = theme.colorScheme.outlineVariant;
    final chipBg = theme.colorScheme.primary.withOpacity(.10);

    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 12,
          end: 12,
          top: 4,
          bottom: 8,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(.25),
                ),
              ),
              child: Text(
                'AutoSpare',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن قطعة...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            PopupMenuButton<_SortBy>(
              tooltip: 'ترتيب النتائج',
              icon: Icon(Icons.sort, color: theme.colorScheme.primary),
              onSelected: (value) {
                setState(() => _sortBy = value);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _SortBy.newest,
                  child: Text('الأحدث أولاً'),
                ),
                PopupMenuItem(
                  value: _SortBy.oldest,
                  child: Text('الأقدم أولاً'),
                ),
                PopupMenuItem(
                  value: _SortBy.priceLow,
                  child: Text('السعر: من الأقل'),
                ),
                PopupMenuItem(
                  value: _SortBy.priceHigh,
                  child: Text('السعر: من الأعلى'),
                ),
                PopupMenuItem(
                  value: _SortBy.stockHigh,
                  child: Text('المخزون الأعلى'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return NavigationBar(
      selectedIndex: _bottomIndex,
      onDestinationSelected: (i) {
        if (_bottomIndex == i) return;
        setState(() => _bottomIndex = i);

        late final Widget page;
        switch (i) {
          case 0:
            page = const HomeScreen();
            break;
          case 1:
            page = const CategoriesScreen();
            break;
          case 2:
            page = const TowScreen();
            break;
          case 3:
            page = const CartScreen();
            break;
          case 4:
          default:
            page = const ProfileScreen();
            break;
        }

        if (i != 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: 'التصنيفات',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_shipping_outlined),
          selectedIcon: Icon(Icons.local_shipping),
          label: 'الونش',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart),
          label: 'السلة',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'حسابي',
        ),
      ],
    );
  }
}
