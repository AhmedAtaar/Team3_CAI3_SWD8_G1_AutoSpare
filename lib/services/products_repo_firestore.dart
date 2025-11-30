import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/services/products_repository.dart';

class ProductsRepoFirestore implements ProductsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('products');

  CatalogProduct _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final brandStr = data['brand'] as String? ?? 'nissan';
    final brand = CarBrand.values.firstWhere(
      (b) => b.name == brandStr,
      orElse: () => CarBrand.nissan,
    );

    final yearsRaw = (data['years'] as List?) ?? const [];
    final years = yearsRaw.map((e) => (e as num).toInt()).toList();

    final createdTs = data['createdAt'] as Timestamp?;
    final createdAt = createdTs?.toDate() ?? DateTime.now();

    final statusStr = data['status'] as String?;
    final bool approvedFlag = data['approved'] as bool? ?? false;

    final ProductStatus status = ProductStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () {
        return approvedFlag ? ProductStatus.approved : ProductStatus.pending;
      },
    );

    final rejectionReason = data['rejectionReason'] as String?;
    final description = data['description'] as String? ?? '';

    return CatalogProduct(
      id: doc.id,
      title: data['title'] as String? ?? '',
      seller: data['sellerId'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] as String?,
      brand: brand,
      model: data['model'] as String? ?? '',
      years: years,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
      status: status,
      rejectionReason: rejectionReason,
      description: description,
    );
  }

  Map<String, dynamic> _toMap(CatalogProduct p) {
    return {
      'title': p.title,
      'sellerId': p.seller,
      'price': p.price,
      'imageUrl': p.imageUrl,
      'brand': p.brand.name,
      'model': p.model,
      'years': p.years,
      'stock': p.stock,
      'createdAt': Timestamp.fromDate(p.createdAt),

      'status': p.status.name,
      'approved': p.status == ProductStatus.approved,
      'rejectionReason': p.rejectionReason,
      'description': p.description,
    };
  }

  @override
  Stream<List<CatalogProduct>> watchApprovedProducts() {
    return _col
        .where('approved', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Stream<List<CatalogProduct>> watchSellerProducts(String sellerId) {
    return _col
        .where('sellerId', isEqualTo: sellerId)
        .where('approved', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Stream<List<CatalogProduct>> watchAllSellerProducts(String sellerId) {
    return _col
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Stream<List<CatalogProduct>> watchAllProducts() {
    return _col.snapshots().map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> increaseStock({
    required String productId,
    required int delta,
  }) async {
    if (delta == 0) return;
    await _col.doc(productId).update({'stock': FieldValue.increment(delta)});
  }

  @override
  Future<void> upsertProduct(CatalogProduct product) async {
    await _col.doc(product.id).set(_toMap(product), SetOptions(merge: true));
  }
}
