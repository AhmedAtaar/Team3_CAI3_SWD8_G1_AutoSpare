enum AppUserRole { buyer, seller, admin, winch }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;

  final String password;
  final AppUserRole role;

  final bool canSell;
  final bool approved;
  final bool canTow;

  final int maxWinches;

  final List<String>? docUrls;
  final String? towLicenseUrl;
  final String? towDriverIdUrl;

  final String? towCompanyId;
  final String? storeName;
  final String? commercialRegUrl;
  final String? taxCardUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
    required this.role,
    this.approved = false,
    this.canSell = false,
    this.canTow = false,
    this.maxWinches = 0,
    this.docUrls,
    this.towLicenseUrl,
    this.towDriverIdUrl,
    this.towCompanyId,
    this.storeName,
    this.commercialRegUrl,
    this.taxCardUrl,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? password,
    AppUserRole? role,
    bool? approved,
    bool? canSell,
    bool? canTow,
    int? maxWinches,
    List<String>? docUrls,
    String? towLicenseUrl,
    String? towDriverIdUrl,
    String? towCompanyId,
    String? storeName,
    String? commercialRegUrl,
    String? taxCardUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      role: role ?? this.role,
      approved: approved ?? this.approved,
      canSell: canSell ?? this.canSell,
      canTow: canTow ?? this.canTow,
      maxWinches: maxWinches ?? this.maxWinches,
      docUrls: docUrls ?? this.docUrls,
      towLicenseUrl: towLicenseUrl ?? this.towLicenseUrl,
      towDriverIdUrl: towDriverIdUrl ?? this.towDriverIdUrl,
      towCompanyId: towCompanyId ?? this.towCompanyId,
      storeName: storeName ?? this.storeName,
      commercialRegUrl: commercialRegUrl ?? this.commercialRegUrl,
      taxCardUrl: taxCardUrl ?? this.taxCardUrl,
    );
  }
}
