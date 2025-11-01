class Product {
  final String title;
  final String price;
  final String? imageUrl;
  final String? badge;
  Product({
    required this.title,
    required this.price,
    this.imageUrl,
    this.badge,
  });
}
