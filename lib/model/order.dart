import 'package:flutter/foundation.dart';

enum OrderStatus { processing, prepared, handedToCourier, delivered, cancelled }

String orderStatusAr(OrderStatus s) {
  switch (s) {
    case OrderStatus.processing: return 'قيد المعالجة';
    case OrderStatus.prepared: return 'تم التجهيز';
    case OrderStatus.handedToCourier: return 'مع شركة الشحن';
    case OrderStatus.delivered: return 'تم الاستلام';
    case OrderStatus.cancelled: return 'أُلغي';
  }
}

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
      case OrderStatus.processing: return this;
      case OrderStatus.prepared: return copyWith(preparedAt: now);
      case OrderStatus.handedToCourier: return copyWith(handedToCourierAt: now);
      case OrderStatus.delivered: return copyWith(deliveredAt: now);
      case OrderStatus.cancelled: return copyWith(cancelledAt: now);
    }
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
  final double grandTotal;

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
    required this.grandTotal,
    required this.status,
    required this.stamps,
    this.lat, this.lng,
  });

  OrderDoc copyWith({OrderStatus? status, OrderTimestamps? stamps}) => OrderDoc(
    id: id,
    code: code,
    buyerId: buyerId,
    items: items,
    itemsTotal: itemsTotal,
    shipping: shipping,
    grandTotal: grandTotal,
    lat: lat, lng: lng,
    status: status ?? this.status,
    stamps: stamps ?? this.stamps,
  );
}
