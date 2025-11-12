import 'package:auto_spare/view/widgets/cart_screen_widgets/cart_app_bar_title.dart';
import 'package:auto_spare/view/widgets/cart_screen_widgets/cart_item_card.dart';
import 'package:auto_spare/view/widgets/cart_screen_widgets/order_summary.dart';
import 'package:flutter/material.dart';
import '../../controller/navigation/navigation.dart';
import '../themes/app_colors.dart';

class CartItem {
  final String id;
  final String name;
  final String details;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.details,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  //MARK: List
  //TODO: Replace with real list
  List<CartItem> cartItems = [
    CartItem(
      id: '1',
      name: 'فلتر زيت محرك',
      details: 'تويوتا كامري 2018',
      price: 25.00,
      quantity: 1,
    ),
    CartItem(
      id: '2',
      name: 'فرامل خلفية',
      details: 'هوندا أكورد',
      price: 120.50,
      quantity: 2,
    ),
    CartItem(
      id: '3',
      name: 'شمعات احتراق',
      details: 'طقم 4 قطع',
      price: 45.99,
      quantity: 3,
    ),
    CartItem(
      id: '4',
      name: 'إطار احتياطي',
      details: 'مقاس 17 بوصة',
      price: 99.99,
      quantity: 1,
    ),
    CartItem(
      id: '5',
      name: 'مضخة ماء',
      details: 'نيسان صني',
      price: 75.00,
      quantity: 1,
    ),
    CartItem(
      id: '6',
      name: 'بطارية سيارة',
      details: '12 فولت، 60 أمبير',
      price: 150.00,
      quantity: 1,
    ),
  ];

  double get _subtotal {
    double total = cartItems.fold(0.0, (sum, item) => sum + item.total);
    return total * 1.05;
  }

  //MARK: Functions
  void _updateQuantity(String itemId, bool increase) {
    setState(() {
      final index = cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        if (increase) {
          cartItems[index].quantity++;
        } else if (cartItems[index].quantity > 1) {
          cartItems[index].quantity--;
        }
      }
    });
  }

  void _removeItem(String itemId) {
    setState(() {
      cartItems.removeWhere((item) => item.id == itemId);
    });
  }

  void _handleProceedToOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تنفيذ طلبك', textDirection: TextDirection.rtl),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _handleCancelOrder() {
    setState(() {
      cartItems = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم إلغاء جميع العناصر في السلة',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppNavigationScaffold(
      currentIndex: 3,
      title: 'عربة التسوق',
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CartAppTitle(itemCount: cartItems.length),
              const SizedBox(height: 10.0),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: cartItems.isEmpty
                    ? Center(
                        //MARK: Empty cart
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: Text(
                            'عربة التسوق فارغة',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.grey),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      )
                    : Column(
                        //MARK: Cart items
                        children: cartItems.map((item) {
                          return CartItemCard(
                            item: item,
                            onQuantityChanged: (increase) =>
                                _updateQuantity(item.id, increase),
                            onRemove: () => _removeItem(item.id),
                          );
                        }).toList(),
                      ),
              ),

              OrderSummary(
                subtotal: _subtotal,
                itemCount: cartItems.length,
                onProceedToOrder: _handleProceedToOrder,
                onCancel: _handleCancelOrder,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
