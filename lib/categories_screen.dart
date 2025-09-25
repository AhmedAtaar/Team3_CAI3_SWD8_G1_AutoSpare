import 'package:flutter/material.dart';
import 'app_scaffold.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppNavigationScaffold(
      currentIndex: 1,
      title: "التصنيفات",
      body: Center(child: Text("هنا صفحة التصنيفات")),
    );
  }
}
