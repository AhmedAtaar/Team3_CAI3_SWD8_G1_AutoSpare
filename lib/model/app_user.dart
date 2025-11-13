// lib/model/app_user.dart
enum AppUserRole { buyer, seller, admin }

enum SellerStatus { approved, pending, rejected }

class AppUser {
  final String id;
  final String email;
  final String password;
  final String name;
  final String address;
  final String phone;

  final AppUserRole role;

  // حقول البائع (اختيارية)
  final String? storeName;
  final String? commercialRegUrl;
  final String? taxCardUrl;
  final SellerStatus? sellerStatus;

  const AppUser({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.address,
    required this.phone,
    required this.role,
    this.storeName,
    this.commercialRegUrl,
    this.taxCardUrl,
    this.sellerStatus,
  });

  AppUser copyWith({
    String? name,
    String? address,
    String? phone,
    String? storeName,
    String? commercialRegUrl,
    String? taxCardUrl,
    SellerStatus? sellerStatus,
  }) {
    return AppUser(
      id: id,
      email: email,
      password: password,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      role: role,
      storeName: storeName ?? this.storeName,
      commercialRegUrl: commercialRegUrl ?? this.commercialRegUrl,
      taxCardUrl: taxCardUrl ?? this.taxCardUrl,
      sellerStatus: sellerStatus ?? this.sellerStatus,
    );
  }
}
