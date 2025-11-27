import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class ProductReview {
  final String id;
  final String orderId;
  final String productId;
  final String sellerId;
  final String buyerId;

  final int stars;
  final String text;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.sellerId,
    required this.buyerId,
    required this.stars,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'productId': productId,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'stars': stars,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ProductReview.fromDoc(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    DateTime created;
    if (ts is Timestamp) {
      created = ts.toDate();
    } else if (ts is DateTime) {
      created = ts;
    } else {
      created = DateTime.now();
    }

    return ProductReview(
      id: id,
      orderId: data['orderId'] as String? ?? '',
      productId: data['productId'] as String? ?? '',
      sellerId: data['sellerId'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      stars: (data['stars'] as num?)?.toInt() ?? 0,
      text: data['text'] as String? ?? '',
      createdAt: created,
    );
  }
}

@immutable
class SellerReview {
  final String id;
  final String orderId;
  final String sellerId;
  final String buyerId;

  final int stars;
  final String text;
  final DateTime createdAt;

  const SellerReview({
    required this.id,
    required this.orderId,
    required this.sellerId,
    required this.buyerId,
    required this.stars,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'stars': stars,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SellerReview.fromDoc(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    DateTime created;
    if (ts is Timestamp) {
      created = ts.toDate();
    } else if (ts is DateTime) {
      created = ts;
    } else {
      created = DateTime.now();
    }

    return SellerReview(
      id: id,
      orderId: data['orderId'] as String? ?? '',
      sellerId: data['sellerId'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      stars: (data['stars'] as num?)?.toInt() ?? 0,
      text: data['text'] as String? ?? '',
      createdAt: created,
    );
  }
}
