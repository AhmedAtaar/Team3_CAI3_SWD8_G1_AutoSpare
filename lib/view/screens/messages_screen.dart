import 'package:flutter/material.dart';
import '../../controller/navigation/navigation.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppNavigationScaffold(
      currentIndex: 2,
      title: "الرسائل",
      body: Center(child: Text("هنا صفحة الرسائل")),
    );
  }
}
