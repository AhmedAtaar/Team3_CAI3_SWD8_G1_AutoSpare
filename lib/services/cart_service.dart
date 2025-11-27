import 'package:flutter/foundation.dart';
import 'package:auto_spare/model/catalog.dart';

class CartItem {
  final String id;
  final String sellerId;
  final String name;
  final String details;
  final double price;
  int quantity;
  final String? imageUrl;

  final int maxQty;

  CartItem({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.details,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
    required this.maxQty,
  });

  double get total => price * quantity;
}

class CartService extends ChangeNotifier {
  static final CartService _i = CartService._();
  CartService._();
  factory CartService() => _i;

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  double get subtotal => _items.fold(0.0, (s, e) => s + e.total);

  int get totalItems => _items.fold<int>(0, (s, e) => s + e.quantity);

  void _notify() => notifyListeners();

  void clear() {
    _items.clear();
    _notify();
  }

  void addCatalogProduct(CatalogProduct p, {int qty = 1}) {
    final int stock = p.stock;

    if (stock <= 0) {
      if (kDebugMode) {
        print('Product ${p.id} has no stock, not added to cart.');
      }
      return;
    }

    final idx = _items.indexWhere((e) => e.id == p.id);
    if (idx == -1) {
      final initialQty = qty > stock ? stock : qty;

      _items.add(
        CartItem(
          id: p.id,
          sellerId: p.seller,
          name: p.title,
          details: '${p.seller} • ${p.model} • ${p.years.join(', ')}',
          price: p.price,
          quantity: initialQty,
          imageUrl: p.imageUrl,
          maxQty: stock,
        ),
      );
    } else {
      final item = _items[idx];
      final desired = item.quantity + qty;
      final clamped = desired > item.maxQty ? item.maxQty : desired;
      _items[idx].quantity = clamped;
    }
    _notify();
  }

  void buyNow(CatalogProduct p, {int qty = 1}) {
    clear();
    addCatalogProduct(p, qty: qty);
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    _notify();
  }

  void setQuantity(String id, int qty) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i == -1) return;

    final item = _items[i];

    if (qty <= 0) {
      remove(id);
    } else {
      if (qty > item.maxQty) {
        qty = item.maxQty;
      }
      _items[i].quantity = qty;
      _notify();
    }
  }
}
