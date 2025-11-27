import 'dart:async';
import 'package:auto_spare/model/review.dart';
import 'package:auto_spare/services/reviews_repository.dart';

class ReviewsRepoMemory implements ReviewsRepository {
  static final ReviewsRepoMemory _i = ReviewsRepoMemory._();
  ReviewsRepoMemory._();
  factory ReviewsRepoMemory() => _i;

  final _product = <ProductReview>[];
  final _seller = <SellerReview>[];

  final _prodCtrl = StreamController<List<ProductReview>>.broadcast();
  final _sellCtrl = StreamController<List<SellerReview>>.broadcast();

  void _notifyProduct(String productId) {
    _prodCtrl.add(_product.where((e) => e.productId == productId).toList());
  }

  void _notifySeller(String sellerId) {
    _sellCtrl.add(_seller.where((e) => e.sellerId == sellerId).toList());
  }

  @override
  Future<void> addProductReview(ProductReview r) async {
    final exists = _product.any(
      (e) =>
          e.orderId == r.orderId &&
          e.productId == r.productId &&
          e.buyerId == r.buyerId,
    );
    if (!exists) {
      _product.add(r);
      _notifyProduct(r.productId);
    }
  }

  @override
  Future<void> addSellerReview(SellerReview r) async {
    final exists = _seller.any(
      (e) =>
          e.orderId == r.orderId &&
          e.sellerId == r.sellerId &&
          e.buyerId == r.buyerId,
    );
    if (!exists) {
      _seller.add(r);
      _notifySeller(r.sellerId);
    }
  }

  @override
  Future<bool> hasProductReview({
    required String orderId,
    required String productId,
    required String buyerId,
  }) async {
    return _product.any(
      (e) =>
          e.orderId == orderId &&
          e.productId == productId &&
          e.buyerId == buyerId,
    );
  }

  @override
  Future<bool> hasSellerReview({
    required String orderId,
    required String sellerId,
    required String buyerId,
  }) async {
    return _seller.any(
      (e) =>
          e.orderId == orderId &&
          e.sellerId == sellerId &&
          e.buyerId == buyerId,
    );
  }

  @override
  Stream<List<ProductReview>> watchProductReviews(String productId) {
    final controller = StreamController<List<ProductReview>>.broadcast();

    void emit() {
      controller.add(_product.where((e) => e.productId == productId).toList());
    }

    controller.onListen = () {
      emit();

      _prodCtrl.stream.listen((_) => emit());
    };

    return controller.stream;
  }

  @override
  Stream<List<SellerReview>> watchSellerReviews(String sellerId) {
    final controller = StreamController<List<SellerReview>>.broadcast();

    void emit() {
      controller.add(_seller.where((e) => e.sellerId == sellerId).toList());
    }

    controller.onListen = () {
      emit();
      _sellCtrl.stream.listen((_) => emit());
    };

    return controller.stream;
  }

  @override
  Stream<({double avg, int count})> watchProductSummary(String productId) {
    void emit() => _prodSumCtrls[productId]?.add(_calcProduct(productId));
    _prodSumCtrls.putIfAbsent(
      productId,
      () => StreamController<({double avg, int count})>.broadcast(),
    );
    final c = _prodSumCtrls[productId]!;
    c.onListen = emit;
    _prodCtrl.stream.listen((_) {
      emit();
    });
    return c.stream;
  }

  @override
  Stream<({double avg, int count})> watchSellerSummary(String sellerId) {
    void emit() => _sellSumCtrls[sellerId]?.add(_calcSeller(sellerId));
    _sellSumCtrls.putIfAbsent(
      sellerId,
      () => StreamController<({double avg, int count})>.broadcast(),
    );
    final c = _sellSumCtrls[sellerId]!;
    c.onListen = emit;
    _sellCtrl.stream.listen((_) {
      emit();
    });
    return c.stream;
  }

  ({double avg, int count}) _calcProduct(String productId) {
    final list = _product.where((e) => e.productId == productId).toList();
    if (list.isEmpty) return (avg: 0, count: 0);
    final s = list.fold<int>(0, (a, e) => a + e.stars);
    return (avg: s / list.length, count: list.length);
  }

  ({double avg, int count}) _calcSeller(String sellerId) {
    final list = _seller.where((e) => e.sellerId == sellerId).toList();
    if (list.isEmpty) return (avg: 0, count: 0);
    final s = list.fold<int>(0, (a, e) => a + e.stars);
    return (avg: s / list.length, count: list.length);
  }

  final Map<String, StreamController<({double avg, int count})>> _prodSumCtrls =
      {};
  final Map<String, StreamController<({double avg, int count})>> _sellSumCtrls =
      {};
}
