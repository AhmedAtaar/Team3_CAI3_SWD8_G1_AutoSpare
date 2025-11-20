import 'dart:async';
import 'package:auto_spare/model/review.dart';

abstract class ReviewsRepository {
  // إضافة
  Future<void> addProductReview(ProductReview r);
  Future<void> addSellerReview(SellerReview r);

  // تحقّق لمنع التكرار (مرّة واحدة لكل منتج داخل طلب، ومرّة واحدة للبائع لكل طلب)
  Future<bool> hasProductReview({required String orderId, required String productId, required String buyerId});
  Future<bool> hasSellerReview({required String orderId, required String sellerId, required String buyerId});

  // مشاهدة
  Stream<List<ProductReview>> watchProductReviews(String productId);
  Stream<List<SellerReview>>  watchSellerReviews(String sellerId);

  // ملخّصات جاهزة للعرض
  Stream<({double avg, int count})> watchProductSummary(String productId);
  Stream<({double avg, int count})> watchSellerSummary(String sellerId);
}
