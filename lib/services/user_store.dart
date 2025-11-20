// lib/services/user_store.dart

import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:auto_spare/services/user_password_store.dart';
import 'package:auto_spare/services/tow_directory.dart';

enum SellerStatus { pending, approved, rejected }

class TowCompanyRequest {
  final String id;
  final String companyName;
  final String area;
  final double lat;
  final double lng;
  final double baseCost;
  final double pricePerKm;
  final String contactName;
  final String contactEmail;
  final String contactPhone;

  // ✅ نفس فكرة البائع:
  // رابط السجل التجاري + رابط البطاقة الضريبية
  final String? commercialRegUrl; // السجل التجاري
  final String? taxCardUrl;       // البطاقة الضريبية

  SellerStatus status;
  String? rejectReason;
  String? userId;
  String? tempPassword;

  TowCompanyRequest({
    required this.id,
    required this.companyName,
    required this.area,
    required this.lat,
    required this.lng,
    required this.baseCost,
    required this.pricePerKm,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    this.commercialRegUrl,
    this.taxCardUrl,
    this.status = SellerStatus.pending,
    this.rejectReason,
    this.userId,
    this.tempPassword,
  });
}

class UserStore {
  UserStore._internal();
  static final UserStore _instance = UserStore._internal();
  factory UserStore() => _instance;

  final List<TowCompanyRequest> _tows = [];
  AppUser? currentUser;

  // ================== مشتري ==================
  void signUpBuyer({
    required String email,
    required String password,
    required String name,
    required String address,
    required String phone,
  }) {
    final id = 'B-${DateTime.now().millisecondsSinceEpoch}';

    final user = AppUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      password: password,
      role: AppUserRole.buyer,
    );

    usersRepo.addUser(user);
    UserPasswordStore.setPassword(id, password);
  }

  // ================== بائع (تحت المراجعة) ==================
  void signUpSeller({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String storeName,
    String? commercialRegUrl,
    String? taxCardUrl,
  }) {
    final id = 'S-${DateTime.now().millisecondsSinceEpoch}';

    final user = AppUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      password: password,
      role: AppUserRole.seller,
      approved: false,
      canSell: false,
      storeName: storeName,
      commercialRegUrl: commercialRegUrl,
      taxCardUrl: taxCardUrl,
    );

    usersRepo.addUser(user);
    UserPasswordStore.setPassword(id, password);
  }

  // ================== طلب شركة ونش ==================
  void signUpTow({
    required String companyName,
    required String area,
    required double lat,
    required double lng,
    required double baseCost,
    required double pricePerKm,
    required String contactName,
    required String contactEmail,
    required String contactPhone,
    required String password,
    String? commercialRegUrl,
    String? taxCardUrl,
  }) {
    final reqId = 'T-${DateTime.now().millisecondsSinceEpoch}';
    final req = TowCompanyRequest(
      id: reqId,
      companyName: companyName,
      area: area,
      lat: lat,
      lng: lng,
      baseCost: baseCost,
      pricePerKm: pricePerKm,
      contactName: contactName,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      tempPassword: password,
      commercialRegUrl: commercialRegUrl,
      taxCardUrl: taxCardUrl,
    );
    _tows.add(req);
  }

  List<TowCompanyRequest> pendingTowCompanies() {
    return _tows.where((t) => t.status == SellerStatus.pending).toList();
  }

  void rejectTow(String id, String reason) {
    final i = _tows.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _tows[i].status = SellerStatus.rejected;
    _tows[i].rejectReason = reason;
  }

  void approveTow(String reqId) {
    final idx = _tows.indexWhere((t) => t.id == reqId);
    if (idx == -1) return;

    final req = _tows[idx];
    req.status = SellerStatus.approved;

    final userId = "W-${DateTime.now().millisecondsSinceEpoch}";
    final user = AppUser(
      id: userId,
      name: req.contactName,
      email: req.contactEmail,
      phone: req.contactPhone,
      address: req.area,
      password: req.tempPassword ?? "1234",
      role: AppUserRole.winch,
      approved: true,
      canTow: true,
      towCompanyId: req.id,
    );

    usersRepo.addUser(user);
    UserPasswordStore.setPassword(userId, user.password);
    req.userId = userId;

    TowDirectory().addApproved(
      TowCompany(
        id: req.id,
        name: req.companyName,
        area: req.area,
        lat: req.lat,
        lng: req.lng,
        baseCost: req.baseCost,
        pricePerKm: req.pricePerKm,
        isOnline: true,
      ),
    );
  }

  List<TowCompanyRequest> get tows => List.unmodifiable(_tows);

  void signOutCurrentUser() {
    currentUser = null;
  }
}
