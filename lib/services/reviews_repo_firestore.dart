import 'package:auto_spare/model/review.dart';
import 'package:auto_spare/services/reviews_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewsRepoFirestore implements ReviewsRepository {
  ReviewsRepoFirestore._();
  static final ReviewsRepoFirestore _i = ReviewsRepoFirestore._();
  factory ReviewsRepoFirestore() => _i;

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _prodCol =>
      _db.collection('productReviews');
  CollectionReference<Map<String, dynamic>> get _sellCol =>
      _db.collection('sellerReviews');

  String _genId() => _db.collection('_').doc().id;

  @override
  Future<void> addProductReview(ProductReview r) async {
    final exists = await hasProductReview(
      orderId: r.orderId,
      productId: r.productId,
      buyerId: r.buyerId,
    );
    if (exists) return;

    final id = r.id.isEmpty ? _genId() : r.id;
    await _prodCol.doc(id).set(r.toMap());
  }

  @override
  Future<bool> hasProductReview({
    required String orderId,
    required String productId,
    required String buyerId,
  }) async {
    final snap = await _prodCol
        .where('orderId', isEqualTo: orderId)
        .where('productId', isEqualTo: productId)
        .where('buyerId', isEqualTo: buyerId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Stream<List<ProductReview>> watchProductReviews(String productId) {
    return _prodCol
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ProductReview.fromDoc(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<({double avg, int count})> watchProductSummary(String productId) {
    return watchProductReviews(productId).map((list) {
      if (list.isEmpty) return (avg: 0.0, count: 0);
      final sum = list.fold<int>(0, (acc, e) => acc + e.stars);
      final avg = sum / list.length;
      return (avg: avg, count: list.length);
    });
  }

  @override
  Future<void> addSellerReview(SellerReview r) async {
    final exists = await hasSellerReview(
      orderId: r.orderId,
      sellerId: r.sellerId,
      buyerId: r.buyerId,
    );
    if (exists) return;

    final id = r.id.isEmpty ? _genId() : r.id;
    await _sellCol.doc(id).set(r.toMap());
  }

  @override
  Future<bool> hasSellerReview({
    required String orderId,
    required String sellerId,
    required String buyerId,
  }) async {
    final snap = await _sellCol
        .where('orderId', isEqualTo: orderId)
        .where('sellerId', isEqualTo: sellerId)
        .where('buyerId', isEqualTo: buyerId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Stream<List<SellerReview>> watchSellerReviews(String sellerId) {
    return _sellCol
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => SellerReview.fromDoc(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<({double avg, int count})> watchSellerSummary(String sellerId) {
    return watchSellerReviews(sellerId).map((list) {
      if (list.isEmpty) return (avg: 0.0, count: 0);
      final sum = list.fold<int>(0, (acc, e) => acc + e.stars);
      final avg = sum / list.length;
      return (avg: avg, count: list.length);
    });
  }
}
