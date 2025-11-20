// lib/model/app_user.dart

enum AppUserRole {
  buyer,
  seller,
  admin,
  winch,
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;

  final String password;       // مخزّن مؤقتاً (قبل Firebase Auth)
  final AppUserRole role;

  final bool approved;         // هل الحساب معتمد من الإدارة؟
  final bool canSell;          // صلاحية البيع
  final bool canTow;           // صلاحية ونش

  final int maxWinches;        // عدد عربيات الونش المسموح بها (إن احتجنا)

  final List<String>? docUrls; // روابط مستندات
  final String? towLicenseUrl; // رابط رخصة الونش
  final String? towDriverIdUrl; // رابط هوية السائق

  final String? towCompanyId;  // ID الشركة المرتبطة (لو دور winch)
  final String? storeName;     // اسم متجر البائع
  final String? commercialRegUrl; // رابط السجل التجاري
  final String? taxCardUrl;    // رابط البطاقة الضريبية

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
