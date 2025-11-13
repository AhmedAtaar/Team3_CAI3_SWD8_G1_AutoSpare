import 'package:auto_spare/view/screens/tow_screen.dart';
import 'package:flutter/material.dart';
import '../../view/screens/home_screen.dart';
import '../../view/screens/categories_screen.dart';
import '../../view/screens/cart_screen.dart';
import '../../view/screens/profile_screen.dart';

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

  void _navigate(BuildContext context, int i) {
    if (i == currentIndex) return;

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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(title), centerTitle: true),
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => _navigate(context, i),
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
        ),
      ),
    );
  }
}
