import 'package:flutter/material.dart';
import 'categories_screen.dart';
import 'messages_screen.dart';
import 'cart_screen.dart';
import 'seller_profile_page.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _bottomIndex = 0;
  String _role = 'buyer'; // buyer | seller

  final List<_Product> _allProducts = List.generate(
    12,
        (i) => _Product(
      title: 'قطعة رقم ${i + 1}',
      price: (25 + i * 3.5).toStringAsFixed(2),
      imageUrl: null, // ضع URL/Asset لاحقاً
      badge: i.isEven ? 'عرض' : null,
    ),
  );

  List<_Product> _filtered() {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _allProducts.where((p) {
      final okText = q.isEmpty || p.title.toLowerCase().contains(q);
      // يمكنك لاحقاً فصل بيانات الـ buyer/seller
      return okText;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final products = _filtered();

    return Directionality(
      textDirection: TextDirection.rtl, // لملصقات الـ BottomNav بالعربي
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
                      (context, index) => _ProductCard(item: products[index]),
                  childCount: products.length,
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
        padding: const EdgeInsetsDirectional.only(
          start: 12, end: 12, top: 4, bottom: 8,
        ),
        child: Row(
          children: [
            Container(
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    final isBuyer = _role == 'buyer';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'مشتري (Buyer)',
              selected: isBuyer,
              onTap: () => setState(() => _role = 'buyer'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SegmentButton(
              label: 'بائع (Seller)',
              selected: !isBuyer,
              onTap: () => setState(() => _role = 'seller'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final items = const [
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
        itemBuilder: (_, i) => Container(
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
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }

  Widget _buildBottomBar() {
    return NavigationBar(
      selectedIndex: _bottomIndex,
      onDestinationSelected: (i) {
        setState(() => _bottomIndex = i);

        Widget page;
        switch (i) {
          case 0:
            page = const HomeScreen();
            break;
          case 1:
            page = const CategoriesScreen();
            break;
          case 2:
            page = const MessagesScreen();
            break;
          case 3:
            page = const CartScreen();
            break;
          case 4:
          default:
            page = const SellerProfilePage();
            break;
        }

        if (i != 0) { // لو مش الرئيسية
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
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'الرسائل',
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

// ======= Models & small widgets =======

class _Product {
  final String title;
  final String price;
  final String? imageUrl;
  final String? badge;
  _Product({
    required this.title,
    required this.price,
    this.imageUrl,
    this.badge,
  });
}

class _ProductCard extends StatelessWidget {
  final _Product item;
  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;

    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(.35),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        child: const Center(child: Icon(Icons.image, size: 40)),
                      ),
                    ),
                    if (item.badge != null)
                      PositionedDirectional(
                        top: 8,
                        start: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  children: [
                    Text(
                      '\$${item.price}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      onPressed: () {},
                      tooltip: 'أضف إلى السلة',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    final theme = Theme.of(context);
    final bg = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceVariant.withOpacity(.35);
    final border = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    final fg = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: bg,
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});
}
