import 'package:auto_spare/model/product.dart';
import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/view/widgets/home_screen_widgets/product_card.dart';
import 'package:flutter/material.dart';

import 'categories_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'tow_screen.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _bottomIndex = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CatalogProduct> _filteredApproved() {
    final approved = Catalog().all();
    final q = _searchCtrl.text.trim().toLowerCase();

    return approved.where((c) {
      final text =
      '${c.title} ${kBrandName[c.brand]} ${c.model} ${c.years.join(' ')} ${c.seller}'
          .toLowerCase();
      return q.isEmpty || text.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _filteredApproved();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: _buildAppBar(theme),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
          child: GridView.builder(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .8,
            ),
            itemBuilder: (context, index) {
              final c = items[index];
              final cardData = Product(
                title:
                '${c.title} • ${kBrandName[c.brand]} ${c.model} • ${c.years.join(', ')}',
                price: c.price.toStringAsFixed(2),
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
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
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
        padding:
        const EdgeInsetsDirectional.only(start: 12, end: 12, top: 4, bottom: 8),
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
