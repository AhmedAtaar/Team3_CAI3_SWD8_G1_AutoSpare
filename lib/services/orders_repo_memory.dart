import 'dart:async';
import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/services/orders_repository.dart';

class OrdersRepoMemory implements OrdersRepository {
  static final OrdersRepoMemory _i = OrdersRepoMemory._();
  OrdersRepoMemory._();
  factory OrdersRepoMemory() => _i;

  final _orders = <OrderDoc>[];
  final _controller = StreamController<List<OrderDoc>>.broadcast();

  void _emit() => _controller.add(List.unmodifiable(_orders));

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();

  String _genCode() {
    final d = DateTime.now();
    final ymd = '${d.year}${d.month.toString().padLeft(2,'0')}${d.day.toString().padLeft(2,'0')}';
    final seq = (_orders.where((o) =>
    o.stamps.createdAt.year==d.year &&
        o.stamps.createdAt.month==d.month &&
        o.stamps.createdAt.day==d.day).length + 1).toString().padLeft(4,'0');
    return 'ORD-$ymd-$seq';
  }

  @override
  Future<(String orderId, String code)> createOrder({
    required String buyerId,
    required List<OrderItem> items,
    required double itemsTotal,
    required double shipping,
    double? lat, double? lng,
  }) async {
    final id = _genId();
    final code = _genCode();
    final now  = DateTime.now();
    final doc = OrderDoc(
      id: id,
      code: code,
      buyerId: buyerId,
      items: items,
      itemsTotal: itemsTotal,
      shipping: shipping,
      grandTotal: itemsTotal + shipping,
      lat: lat, lng: lng,
      status: OrderStatus.processing,
      stamps: OrderTimestamps(createdAt: now),
    );
    _orders.insert(0, doc);
    _emit();
    return (id, code);
  }

  @override
  Future<void> updateStatus({required String orderId, required OrderStatus next}) async {
    final i = _orders.indexWhere((o) => o.id == orderId);
    if (i == -1) return;
    final now = DateTime.now();
    _orders[i] = _orders[i].copyWith(status: next, stamps: _orders[i].stamps.set(next, now));
    _emit();
  }

  @override
  Stream<List<OrderDoc>> watchBuyerOrders(String buyerId) =>
      _controller.stream.map((l)=> l.where((o)=> o.buyerId==buyerId).toList()).startWith(
        _orders.where((o)=> o.buyerId==buyerId).toList(),
      );

  @override
  Stream<List<OrderDoc>> watchSellerOrders(String sellerId) =>
      _controller.stream.map((l)=> l.where((o)=> o.items.any((it)=> it.sellerId==sellerId)).toList()).startWith(
        _orders.where((o)=> o.items.any((it)=> it.sellerId==sellerId)).toList(),
      );

  @override
  Stream<List<OrderDoc>> watchAllOrdersAdmin() =>
      _controller.stream.startWith(List.unmodifiable(_orders));
}

extension _Seed<T> on Stream<T> {
  Stream<T> startWith(T seed) async* { yield seed; yield* this; }
}
