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
  String _uiRole = 'buyer';

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
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildRoleTabs(theme)),
            SliverToBoxAdapter(child: _buildQuickActions(theme)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: .8,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
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
                  childCount: items.length,
                ),
              ),
            ),
          ],
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

  Widget _buildRoleTabs(ThemeData theme) {
    final isBuyer = _uiRole == 'buyer';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'مشتري (Buyer)',
              selected: isBuyer,
              onTap: () => setState(() => _uiRole = 'buyer'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SegmentButton(
              label: 'بائع (Seller)',
              selected: !isBuyer,
              onTap: () => setState(() => _uiRole = 'seller'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    const items = [
      _QuickAction(icon: Icons.category, label: 'التصنيفات'),
      _QuickAction(icon: Icons.assignment, label: 'طلب عرض سعر'),
      _QuickAction(icon: Icons.local_shipping, label: 'الخدمات اللوجستية'),
      _QuickAction(icon: Icons.stars_rounded, label: 'أفضل الصفقات'),
    ];
    final borderColor = theme.colorScheme.outlineVariant;

    return SizedBox(
      height: 84,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (i == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              );
            }
          },
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(items[i].icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    items[i].label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
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

class _QuickAction {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
          selected ? cs.primary.withOpacity(.12) : cs.surfaceVariant.withOpacity(.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? cs.primary : cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
