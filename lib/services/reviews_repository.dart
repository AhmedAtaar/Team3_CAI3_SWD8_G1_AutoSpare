import 'dart:async';
import 'package:auto_spare/model/review.dart';

abstract class ReviewsRepository {

  Future<void> addProductReview(ProductReview r);
  Future<void> addSellerReview(SellerReview r);


  Future<bool> hasProductReview({required String orderId, required String productId, required String buyerId});
  Future<bool> hasSellerReview({required String orderId, required String sellerId, required String buyerId});


  Stream<List<ProductReview>> watchProductReviews(String productId);
  Stream<List<SellerReview>>  watchSellerReviews(String sellerId);


  Stream<({double avg, int count})> watchProductSummary(String productId);
  Stream<({double avg, int count})> watchSellerSummary(String sellerId);
}
