import 'package:auto_spare/model/order.dart';

abstract class OrdersRepository {
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
  });

  Future<void> updateStatus({
    required String orderId,
    required OrderStatus next,
  });

  Stream<List<OrderDoc>> watchBuyerOrders(String buyerId);
  Stream<List<OrderDoc>> watchSellerOrders(String sellerId);
  Stream<List<OrderDoc>> watchAllOrdersAdmin();
}
