import 'dart:async';
import 'package:flutter/foundation.dart';

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

  String? canFulfillItems(List<({String id, String name, int qty})> items) {
    for (final it in items) {
      final p = findById(it.id);
      if (p == null) return 'العنصر "${it.name}" غير موجود في الكتالوج.';
      if (p.stock < it.qty) return 'المخزون الحالي من "${it.name}" هو ${p.stock} فقط.';
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

  // ===================== جديد: إدارة المخزون للبائع =====================

  /// زيادة/نقصان المخزون بالقيمة [delta] (موجب للزيادة، سالب للنقصان).
  /// ترجع true لو اتحدث بنجاح.
  bool restock(String productId, int delta) {
    final idx = _items.indexWhere((e) => e.id == productId);
    if (idx == -1) return false;
    final cur = _items[idx].stock;
    final next = (cur + delta).clamp(0, 1 << 31); // لا سالب
    if (next == cur) return true;
    _items[idx] = _items[idx].copyWith(stock: next);
    return true;
  }

  /// تعيين المخزون مباشرة إلى قيمة محددة.
  bool setStock(String productId, int newStock) {
    final idx = _items.indexWhere((e) => e.id == productId);
    if (idx == -1) return false;
    final next = newStock.clamp(0, 1 << 31);
    _items[idx] = _items[idx].copyWith(stock: next);
    return true;
  }
}
