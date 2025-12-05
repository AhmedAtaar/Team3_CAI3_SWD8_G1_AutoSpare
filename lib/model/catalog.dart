import 'package:flutter/foundation.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

enum CarBrand { nissan, toyota, hyundai, kia, bmw, mercedes }

const Map<CarBrand, String> kBrandName = {
  CarBrand.nissan: 'Nissan',
  CarBrand.toyota: 'Toyota',
  CarBrand.hyundai: 'Hyundai',
  CarBrand.kia: 'Kia',
  CarBrand.bmw: 'BMW',
  CarBrand.mercedes: 'Mercedes',
};

const Map<CarBrand, List<String>> kModelsByBrand = {
  CarBrand.nissan: ['Sunny', 'Qashqai', 'Juke'],
  CarBrand.toyota: ['Corolla', 'Yaris', 'Camry'],
  CarBrand.hyundai: ['Elantra', 'Accent', 'Tucson'],
  CarBrand.kia: ['Cerato', 'Sportage', 'Rio'],
  CarBrand.bmw: ['320i', '520i', 'X5'],
  CarBrand.mercedes: ['C180', 'E200', 'GLC'],
};

final List<int> kYears = List<int>.generate(13, (i) => 2013 + i);

enum ProductStatus { pending, approved, rejected }

@immutable
class CatalogProduct {
  final String id;
  final String title;
  final String seller;
  final double price;
  final String? imageUrl;
  final CarBrand brand;
  final String model;
  final List<int> years;
  final DateTime createdAt;
  final int stock;

  final ProductStatus status;
  final String? rejectionReason;

  final String description;

  const CatalogProduct({
    required this.id,
    required this.title,
    required this.seller,
    required this.price,
    required this.brand,
    required this.model,
    required this.years,
    required this.stock,
    required this.createdAt,
    this.imageUrl,
    this.status = ProductStatus.approved,
    this.rejectionReason,
    this.description = '',
  });

  CatalogProduct copyWith({
    String? title,
    String? seller,
    double? price,
    String? imageUrl,
    CarBrand? brand,
    String? model,
    List<int>? years,
    int? stock,
    DateTime? createdAt,
    ProductStatus? status,
    String? rejectionReason,
    String? description,
  }) {
    return CatalogProduct(
      id: id,
      title: title ?? this.title,
      seller: seller ?? this.seller,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      years: years ?? this.years,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      description: description ?? this.description,
    );
  }
}

class Catalog {
  static final Catalog _i = Catalog._();
  Catalog._();
  factory Catalog() => _i;

  final List<CatalogProduct> _items = [];

  List<CatalogProduct> all() => List.unmodifiable(_items);

  void add(CatalogProduct p) {
    final i = _items.indexWhere((e) => e.id == p.id);
    if (i == -1) {
      _items.add(p);
    } else {
      _items[i] = p;
    }
  }

  CatalogProduct? findById(String id) {
    for (final p in _items) {
      if (p.id == id) return p;
    }
    return null;
  }

  String? canFulfillItems(
    AppLocalizations loc,
    List<({String id, String name, int qty})> items,
  ) {
    for (final it in items) {
      final p = findById(it.id);
      if (p == null) {
        return loc.catalogCanFulfillItemNotFound(it.name);
      }
      if (p.stock < it.qty) {
        return loc.catalogCanFulfillInsufficientStock(it.name, p.stock);
      }
    }
    return null;
  }

  bool deductStockFor(List<({String id, int qty})> items) {
    for (final it in items) {
      final p = findById(it.id);
      if (p == null || p.stock < it.qty) return false;
    }
    for (final it in items) {
      final i = _items.indexWhere((e) => e.id == it.id);
      if (i != -1) {
        final updated = _items[i].copyWith(stock: _items[i].stock - it.qty);
        _items[i] = updated;
      }
    }
    return true;
  }

  bool restock(String productId, int delta) {
    final idx = _items.indexWhere((e) => e.id == productId);
    if (idx == -1) return false;
    final cur = _items[idx].stock;
    final next = (cur + delta).clamp(0, 1 << 31);
    if (next == cur) return true;
    _items[idx] = _items[idx].copyWith(stock: next);
    return true;
  }

  bool setStock(String productId, int newStock) {
    final idx = _items.indexWhere((e) => e.id == productId);
    if (idx == -1) return false;
    final next = newStock.clamp(0, 1 << 31);
    _items[idx] = _items[idx].copyWith(stock: next);
    return true;
  }
}
