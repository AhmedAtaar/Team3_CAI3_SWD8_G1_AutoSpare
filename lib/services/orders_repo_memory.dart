import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/services/orders_repository.dart';

class OrdersRepoFirestore implements OrdersRepository {
  OrdersRepoFirestore();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('orders');

  @override
  Future<(String orderId, String code)> createOrder({
    required String buyerId,
    required List<OrderItem> items,
    required double itemsTotal,
    required double shipping,
    double discount = 0.0,
    String? couponCode,
    String? note,
    double? lat,
    double? lng,
  }) async {
    final now = DateTime.now();

    final rawTotal = itemsTotal + shipping - discount;
    final grandTotal = rawTotal < 0 ? 0.0 : rawTotal;

    final rnd = Random();
    final code =
        'O-${now.millisecondsSinceEpoch}-${rnd.nextInt(9999).toString().padLeft(4, '0')}';

    final docRef = _col.doc();

    final order = OrderDoc(
      id: docRef.id,
      code: code,
      buyerId: buyerId,
      items: items,
      itemsTotal: itemsTotal,
      shipping: shipping,
      discount: discount,
      grandTotal: grandTotal,
      couponCode: couponCode,
      note: note,
      lat: lat,
      lng: lng,
      status: OrderStatus.processing,
      stamps: OrderTimestamps(createdAt: now),
    );

    final sellerIds = items.map((e) => e.sellerId).toSet().toList();

    await docRef.set({...order.toMap(), 'sellerIds': sellerIds});

    return (docRef.id, code);
  }

  @override
  Future<void> updateStatus({
    required String orderId,
    required OrderStatus next,
  }) async {
    final now = DateTime.now();
    final docRef = _col.doc(orderId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final current = OrderDoc.fromMap(id: snap.id, data: data);
    final newStamps = current.stamps.set(next, now);

    await docRef.update({'status': next.name, 'stamps': newStamps.toMap()});
  }

  @override
  Stream<List<OrderDoc>> watchBuyerOrders(String buyerId) {
    return _col
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('stamps.createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => OrderDoc.fromMap(id: d.id, data: d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<OrderDoc>> watchSellerOrders(String sellerId) {
    return _col
        .where('sellerIds', arrayContains: sellerId)
        .orderBy('stamps.createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => OrderDoc.fromMap(id: d.id, data: d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<OrderDoc>> watchAllOrdersAdmin() {
    return _col
        .orderBy('stamps.createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => OrderDoc.fromMap(id: d.id, data: d.data()))
              .toList(),
        );
  }
}
