import 'package:flutter/foundation.dart';

@immutable
class ProductReview {
  final String id;        // UUID
  final String orderId;
  final String productId;
  final String sellerId;
  final String buyerId;

  final int stars;        // 1..5
  final String text;      // يمكن فارغ
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
}

@immutable
class SellerReview {
  final String id;        // UUID
  final String orderId;
  final String sellerId;
  final String buyerId;

  final int stars;        // 1..5
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
}
