import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountCoupon {
  final String id;
  final String code;
  final String sellerId;
  final double discountPercent;
  final bool active;
  final DateTime createdAt;
  final DateTime? expiresAt;

  DiscountCoupon({
    required this.id,
    required this.code,
    required this.sellerId,
    required this.discountPercent,
    required this.active,
    required this.createdAt,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get isUsable => active && !isExpired;

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'sellerId': sellerId,
      'discountPercent': discountPercent,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  factory DiscountCoupon.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdTs = data['createdAt'] as Timestamp?;
    final expiresTs = data['expiresAt'] as Timestamp?;
    return DiscountCoupon(
      id: doc.id,
      code: (data['code'] as String).toUpperCase(),
      sellerId: data['sellerId'] as String,
      discountPercent: (data['discountPercent'] as num).toDouble(),
      active: data['active'] as bool? ?? true,
      createdAt: createdTs?.toDate() ?? DateTime.now(),
      expiresAt: expiresTs?.toDate(),
    );
  }
}
