import 'package:auto_spare/model/catalog.dart';

abstract class ProductsRepository {
  Stream<List<CatalogProduct>> watchApprovedProducts();
  Stream<List<CatalogProduct>> watchSellerProducts(String sellerId);
  Stream<List<CatalogProduct>> watchAllSellerProducts(String sellerId);
  Stream<List<CatalogProduct>> watchAllProducts();

  Future<void> increaseStock({required String productId, required int delta});

  Future<void> upsertProduct(CatalogProduct product);
}
