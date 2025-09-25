import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'messages_screen.dart';
import 'cart_screen.dart';
import 'seller_profile_page.dart';

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
    if (i != currentIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    }
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
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'التصنيفات'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'الرسائل'),
            NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'السلة'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}
