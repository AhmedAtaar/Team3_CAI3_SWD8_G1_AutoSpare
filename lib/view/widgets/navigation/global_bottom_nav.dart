import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:auto_spare/view/screens/home_screen.dart';
import 'package:auto_spare/view/screens/categories_screen.dart';
import 'package:auto_spare/view/screens/tow_screen.dart';
import 'package:auto_spare/view/screens/cart_screen.dart';
import 'package:auto_spare/view/screens/profile_screen.dart';

import 'package:auto_spare/services/tow_badge_stream.dart';

class _AnimatedBadge extends StatelessWidget {
  final int count;

  const _AnimatedBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final display = count > 9 ? '9+' : '$count';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Container(
        key: ValueKey(display),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(999),
        ),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        child: Text(
          display,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

Widget profileIconWithBadge({required int count, required bool selected}) {
  final baseIcon = Icon(selected ? Icons.person : Icons.person_outline);

  if (count <= 0) return baseIcon;

  return Stack(
    clipBehavior: Clip.none,
    children: [
      baseIcon,
      Positioned(right: -4, top: -4, child: _AnimatedBadge(count: count)),
    ],
  );
}

class GlobalBottomNav extends StatelessWidget {
  final int currentIndex;

  const GlobalBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: towNotificationCountStreamForCurrentUser(),
      builder: (_, snap) {
        final count = snap.data ?? 0;

        return NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) {
            if (i == currentIndex) return;

            Widget page;
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

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: 'nav.home'.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view),
              label: 'nav.categories'.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.local_shipping_outlined),
              selectedIcon: const Icon(Icons.local_shipping),
              label: 'nav.tow'.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.shopping_cart_outlined),
              selectedIcon: const Icon(Icons.shopping_cart),
              label: 'nav.cart'.tr(),
            ),
            NavigationDestination(
              icon: profileIconWithBadge(count: count, selected: false),
              selectedIcon: profileIconWithBadge(count: count, selected: true),
              label: 'nav.profile'.tr(),
            ),
          ],
        );
      },
    );
  }
}
