import 'package:flutter/foundation.dart';
import 'package:auto_spare/model/catalog.dart';

class CartItem {
  final String id;
  final String name;
  final String details;
  final double price;
  int quantity;
  final String? imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.details,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
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

  void _notify() => notifyListeners();

  void clear() {
    _items.clear();
    _notify();
  }

  void addCatalogProduct(CatalogProduct p, {int qty = 1}) {
    final idx = _items.indexWhere((e) => e.id == p.id);
    if (idx == -1) {
      _items.add(CartItem(
        id: p.id,
        name: p.title,
        details: '${p.seller} • ${p.model} • ${p.years.join(', ')}',
        price: p.price,
        quantity: qty,
        imageUrl: p.imageUrl, // ✅ نحفظ صورة المنتج لو موجودة
      ));
    } else {
      _items[idx].quantity += qty;
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
    if (qty <= 0) {
      remove(id);
    } else {
      _items[i].quantity = qty;
      _notify();
    }
  }
}
