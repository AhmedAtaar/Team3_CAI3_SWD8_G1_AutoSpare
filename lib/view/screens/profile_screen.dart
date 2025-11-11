import 'package:auto_spare/view/screens/tow_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});
  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final String sellerName = "OMAR";
  final double totalSales = 418;
  final double totalProfit = 80;
  final List<String> items = ["اسم العنصر 1", "اسم العنصر 2", "اسم العنصر 3"];
  final Map<int, bool> selected = {};
  int _bottomIndex = 4; // هنا الصفحة الحالية (حسابي)

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
            page = const TowScreen();
            break;
          case 3:
            page = const CartScreen();
            break;
          case 4:
          default:
            page = const SellerProfilePage();
            break;
        }

        if (i != 4) {
          // لو مش في البروفايل
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("الملف الشخصي"), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sellerName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("\$${totalSales.toStringAsFixed(0)} مبيعات"),
                        Text(
                          "\$${totalProfit.toStringAsFixed(0)} أرباح",
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete_outline),
                        tooltip: "حذف",
                        style: IconButton.styleFrom(
                          shape: const CircleBorder(),
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: "تحرير",
                        style: IconButton.styleFrom(
                          shape: const CircleBorder(),
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) => CheckboxListTile(
                    title: Text(items[index]),
                    value: selected[index] ?? false,
                    onChanged: (val) =>
                        setState(() => selected[index] = val ?? false),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("أضف عنصراً"),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
