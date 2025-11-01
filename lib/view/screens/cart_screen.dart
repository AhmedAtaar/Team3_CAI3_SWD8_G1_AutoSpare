import 'package:flutter/material.dart';
import '../../controller/routing/routing.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppNavigationScaffold(
      currentIndex: 3,
      title: "السلة",
      body: Center(child: Text("هنا صفحة السلة")),
    );
  }
}
