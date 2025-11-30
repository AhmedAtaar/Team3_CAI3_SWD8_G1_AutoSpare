import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_spare/model/discount_coupon.dart';

class CouponsRepo {
  static final CouponsRepo _instance = CouponsRepo._internal();
  factory CouponsRepo() => _instance;
  CouponsRepo._internal();

  final _col = FirebaseFirestore.instance.collection('coupons');

  Future<void> upsertCoupon(DiscountCoupon coupon) async {
    await _col.doc(coupon.id).set(coupon.toMap(), SetOptions(merge: true));
  }

  Future<void> createCoupon({
    required String code,
    required String sellerId,
    required double discountPercent,
    DateTime? expiresAt,
  }) async {
    final doc = _col.doc();
    final coupon = DiscountCoupon(
      id: doc.id,
      code: code.toUpperCase(),
      sellerId: sellerId,
      discountPercent: discountPercent,
      active: true,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
    );
    await doc.set(coupon.toMap());
  }

  Future<void> setActive(String id, bool active) async {
    await _col.doc(id).update({'active': active});
  }

  Future<void> deleteCoupon(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<DiscountCoupon>> watchSellerCoupons(String sellerId) {
    return _col
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(DiscountCoupon.fromDoc).toList());
  }

  Future<DiscountCoupon?> getByCode(String code) async {
    final q = await _col
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return DiscountCoupon.fromDoc(q.docs.first);
  }
}

final couponsRepo = CouponsRepo();
