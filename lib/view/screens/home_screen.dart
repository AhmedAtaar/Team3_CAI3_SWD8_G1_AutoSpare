import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_spare/model/product.dart';
import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/view/widgets/home_screen_widgets/product_card.dart';
import 'product_details_screen.dart';
import 'package:auto_spare/services/products.dart';
import 'package:auto_spare/view/widgets/navigation/global_bottom_nav.dart';
import 'package:auto_spare/core/app_fees.dart';
import 'package:auto_spare/l10n/app_localizations.dart';
import 'package:auto_spare/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _SortBy { newest, oldest, priceLow, priceHigh, stockHigh }

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  _SortBy _sortBy = _SortBy.newest;

  int _currentPromo = 0;
  Timer? _promoTimer;

  @override
  void initState() {
    super.initState();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _currentPromo = (_currentPromo + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
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
    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: _buildAppBar(context, theme, loc, isArabic),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Column(
            children: [
              _buildSearchAndSortRow(theme, loc),
              const SizedBox(height: 8),
              _buildPromosCarousel(theme, loc, isArabic),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<CatalogProduct>>(
                  stream: productsRepo.watchApprovedProducts(),
                  builder: (context, snapshot) {
                    final allProducts =
                        snapshot.data ?? const <CatalogProduct>[];

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        allProducts.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (allProducts.isEmpty) {
                      return Center(
                        child: Text(loc.home_no_products_available),
                      );
                    }

                    final items = _filterProducts(allProducts);

                    if (items.isEmpty) {
                      return Center(child: Text(loc.home_no_search_results));
                    }

                    final double bottomPadding = bottomInset > 0
                        ? bottomInset + 16
                        : 24;

                    return GridView.builder(
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
            ],
          ),
        ),
        bottomNavigationBar: const GlobalBottomNav(currentIndex: 0),
      ),
    );
  }

  Widget _buildSearchAndSortRow(ThemeData theme, AppLocalizations loc) {
    final borderColor = theme.colorScheme.outlineVariant;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: .35,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: loc.home_search_hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<_SortBy>(
          tooltip: loc.home_sort_tooltip,
          icon: Icon(Icons.sort, color: theme.colorScheme.primary),
          onSelected: (value) {
            setState(() => _sortBy = value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _SortBy.newest,
              child: Text(loc.home_sort_newest),
            ),
            PopupMenuItem(
              value: _SortBy.oldest,
              child: Text(loc.home_sort_oldest),
            ),
            PopupMenuItem(
              value: _SortBy.priceLow,
              child: Text(loc.home_sort_price_low),
            ),
            PopupMenuItem(
              value: _SortBy.priceHigh,
              child: Text(loc.home_sort_price_high),
            ),
            PopupMenuItem(
              value: _SortBy.stockHigh,
              child: Text(loc.home_sort_stock_high),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPromosCarousel(
    ThemeData theme,
    AppLocalizations loc,
    bool isArabic,
  ) {
    final promos = isArabic
        ? [
            (
              'أفضل العروض',
              'خصومات خاصة على أكثر قطع الغيار طلبًا.',
              Icons.local_offer_outlined,
            ),
            (
              'توصيل سريع',
              'خدمة شحن سريعة لجميع المحافظات.',
              Icons.local_shipping_outlined,
            ),
            (
              'قطع أصلية',
              'منتجات مضمونة من أفضل الموردين.',
              Icons.verified_outlined,
            ),
          ]
        : [
            (
              'Best Offers',
              'Special discounts on top-selling parts.',
              Icons.local_offer_outlined,
            ),
            (
              'Fast Shipping',
              'Quick delivery to your location.',
              Icons.local_shipping_outlined,
            ),
            (
              'Genuine Parts',
              'Trusted, original spare parts.',
              Icons.verified_outlined,
            ),
          ];

    final gradients = [
      [
        theme.colorScheme.primary.withValues(alpha: .98),
        theme.colorScheme.primary.withValues(alpha: .70),
      ],
      [
        const Color(0xFF0F172A),
        theme.colorScheme.secondary.withValues(alpha: .9),
      ],
      [
        const Color(0xFF111827),
        theme.colorScheme.tertiary.withValues(alpha: .9),
      ],
    ];

    final index = _currentPromo % promos.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 100,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              setState(() {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < 0) {
                  _currentPromo = (_currentPromo + 1) % promos.length;
                } else {
                  _currentPromo =
                      (_currentPromo - 1 + promos.length) % promos.length;
                }
              });
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _buildPromoCard(
                key: ValueKey(index),
                theme: theme,
                title: promos[index].$1,
                subtitle: promos[index].$2,
                icon: promos[index].$3,
                gradientColors: gradients[index],
                isArabic: isArabic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(promos.length, (i) {
            final isActive = i == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 14 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: isActive
                    ? theme.colorScheme.primary.withValues(alpha: .9)
                    : theme.colorScheme.primary.withValues(alpha: .25),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPromoCard({
    required Key key,
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required bool isArabic,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          end: isArabic ? Alignment.centerLeft : Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: .35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              style: theme.textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: .88),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    AppLocalizations loc,
    bool isArabic,
  ) {
    final chipBg = theme.colorScheme.primary.withValues(alpha: .10);

    final appState = MyApp.of(context);
    final isDark = appState.isDarkMode;

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
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: .25),
                  ),
                ),
                child: Text(
                  'Auto Spare',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.language),
              tooltip: loc.common_language_toggle_tooltip,
              onPressed: () {
                final newLocale = isArabic
                    ? const Locale('en')
                    : const Locale('ar');
                MyApp.of(context).setLocale(newLocale);
              },
            ),
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: appState.toggleThemeMode,
            ),
          ],
        ),
      ),
    );
  }
}
