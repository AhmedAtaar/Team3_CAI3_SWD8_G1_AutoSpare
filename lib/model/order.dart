import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { processing, prepared, handedToCourier, delivered, cancelled }

@immutable
class OrderItem {
  final String productId;
  final String sellerId;
  final String titleSnap;
  final double price;
  final int qty;

  const OrderItem({
    required this.productId,
    required this.sellerId,
    required this.titleSnap,
    required this.price,
    required this.qty,
  });

  double get lineTotal => price * qty;

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'sellerId': sellerId,
    'titleSnap': titleSnap,
    'price': price,
    'qty': qty,
  };

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
    productId: m['productId'] as String,
    sellerId: m['sellerId'] as String,
    titleSnap: m['titleSnap'] as String,
    price: (m['price'] as num).toDouble(),
    qty: m['qty'] as int,
  );
}

@immutable
class OrderTimestamps {
  final DateTime createdAt;
  final DateTime? preparedAt;
  final DateTime? handedToCourierAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  const OrderTimestamps({
    required this.createdAt,
    this.preparedAt,
    this.handedToCourierAt,
    this.deliveredAt,
    this.cancelledAt,
  });

  OrderTimestamps copyWith({
    DateTime? createdAt,
    DateTime? preparedAt,
    DateTime? handedToCourierAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
  }) => OrderTimestamps(
    createdAt: createdAt ?? this.createdAt,
    preparedAt: preparedAt ?? this.preparedAt,
    handedToCourierAt: handedToCourierAt ?? this.handedToCourierAt,
    deliveredAt: deliveredAt ?? this.deliveredAt,
    cancelledAt: cancelledAt ?? this.cancelledAt,
  );

  OrderTimestamps set(OrderStatus s, DateTime now) {
    switch (s) {
      case OrderStatus.processing:
        return this;
      case OrderStatus.prepared:
        return copyWith(preparedAt: now);
      case OrderStatus.handedToCourier:
        return copyWith(handedToCourierAt: now);
      case OrderStatus.delivered:
        return copyWith(deliveredAt: now);
      case OrderStatus.cancelled:
        return copyWith(cancelledAt: now);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      if (preparedAt != null) 'preparedAt': Timestamp.fromDate(preparedAt!),
      if (handedToCourierAt != null)
        'handedToCourierAt': Timestamp.fromDate(handedToCourierAt!),
      if (deliveredAt != null) 'deliveredAt': Timestamp.fromDate(deliveredAt!),
      if (cancelledAt != null) 'cancelledAt': Timestamp.fromDate(cancelledAt!),
    };
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    return null;
  }

  factory OrderTimestamps.fromMap(Map<String, dynamic> m) {
    final created = _toDate(m['createdAt']) ?? DateTime.now();
    return OrderTimestamps(
      createdAt: created,
      preparedAt: _toDate(m['preparedAt']),
      handedToCourierAt: _toDate(m['handedToCourierAt']),
      deliveredAt: _toDate(m['deliveredAt']),
      cancelledAt: _toDate(m['cancelledAt']),
    );
  }
}

@immutable
class OrderDoc {
  final String id;
  final String code;
  final String buyerId;
  final List<OrderItem> items;

  final double itemsTotal;
  final double shipping;
  final double discount;
  final double grandTotal;

  final String? couponCode;
  final String? note;

  final double? lat;
  final double? lng;

  final OrderStatus status;
  final OrderTimestamps stamps;

  const OrderDoc({
    required this.id,
    required this.code,
    required this.buyerId,
    required this.items,
    required this.itemsTotal,
    required this.shipping,
    required this.discount,
    required this.grandTotal,
    required this.status,
    required this.stamps,
    this.couponCode,
    this.note,
    this.lat,
    this.lng,
  });

  OrderDoc copyWith({OrderStatus? status, OrderTimestamps? stamps}) => OrderDoc(
    id: id,
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
    status: status ?? this.status,
    stamps: stamps ?? this.stamps,
  );

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'buyerId': buyerId,
      'items': items.map((e) => e.toMap()).toList(),
      'itemsTotal': itemsTotal,
      'shipping': shipping,
      'discount': discount,
      'grandTotal': grandTotal,
      'couponCode': couponCode,
      'note': note,
      'lat': lat,
      'lng': lng,
      'status': status.name,
      'stamps': stamps.toMap(),
    };
  }

  factory OrderDoc.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    List<OrderItem> _itemsFrom(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((m) => OrderItem.fromMap(m))
            .toList();
      }
      return const <OrderItem>[];
    }

    final stampsMap =
        (data['stamps'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final double itemsTotal = (data['itemsTotal'] as num?)?.toDouble() ?? 0.0;
    final double shipping = (data['shipping'] as num?)?.toDouble() ?? 0.0;
    final double discount = (data['discount'] as num?)?.toDouble() ?? 0.0;

    final double grandTotal =
        (data['grandTotal'] as num?)?.toDouble() ??
        (itemsTotal + shipping - discount);

    return OrderDoc(
      id: id,
      code: data['code'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      items: _itemsFrom(data['items']),
      itemsTotal: itemsTotal,
      shipping: shipping,
      discount: discount,
      grandTotal: grandTotal,
      couponCode: data['couponCode'] as String?,
      note: data['note'] as String?,
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? ''),
        orElse: () => OrderStatus.processing,
      ),
      stamps: OrderTimestamps.fromMap(stampsMap),
    );
  }
}
