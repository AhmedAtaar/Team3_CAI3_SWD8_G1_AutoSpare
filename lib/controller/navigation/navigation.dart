import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:auto_spare/view/screens/home_screen.dart';
import 'package:auto_spare/view/screens/categories_screen.dart';
import 'package:auto_spare/view/screens/tow_screen.dart';
import 'package:auto_spare/view/screens/cart_screen.dart';
import 'package:auto_spare/view/screens/profile_screen.dart';

import 'package:auto_spare/services/cart_service.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class AppNavigationScaffold extends StatelessWidget {
  final int currentIndex;
  final String title;
  final Widget body;

  const AppNavigationScaffold({
    super.key,
    required this.currentIndex,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(title), centerTitle: true),
        body: body,
        bottomNavigationBar: GlobalBottomNav(currentIndex: currentIndex),
      ),
    );
  }
}

class GlobalBottomNav extends StatelessWidget {
  final int currentIndex;
  const GlobalBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final cart = CartService();
    final loc = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final int cartCount = cart.totalItems;

        NavigationDestination _cartDestination({required bool selected}) {
          final icon = Icon(
            selected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
          );

          if (cartCount <= 0) {
            return NavigationDestination(icon: icon, label: loc.bottomNavCart);
          }

          return NavigationDestination(
            icon: Badge(label: Text('$cartCount'), child: icon),
            label: loc.bottomNavCart,
          );
        }

        return NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) {
            if (i == currentIndex) return;
            goToIndex(context, i);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: loc.bottomNavHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view),
              label: loc.bottomNavCategories,
            ),
            NavigationDestination(
              icon: const Icon(Icons.local_shipping_outlined),
              selectedIcon: const Icon(Icons.local_shipping),
              label: loc.bottomNavTow,
            ),
            _cartDestination(selected: currentIndex == 3),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: loc.bottomNavAccount,
            ),
          ],
        );
      },
    );
  }
}

void goToIndex(BuildContext context, int i) {
  if (i < 0 || i > 4) return;

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

  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
}
