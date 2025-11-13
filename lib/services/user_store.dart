// lib/services/user_store.dart
import 'package:flutter/foundation.dart';
import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/tow_directory.dart';

class TowApplicant {
  final String id; // TA-...
  final String companyName;
  final String area;
  final double lat;
  final double lng;
  final double baseCost;
  final double pricePerKm;

  final String contactName;
  final String contactEmail;
  final String contactPhone;

  final DateTime createdAt;
  String status; // pending | approved | rejected
  String? rejectReason;

  TowApplicant({
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
    required this.createdAt,
    this.status = 'pending',
    this.rejectReason,
  });
}

class UserStore extends ChangeNotifier {
  UserStore._internal() {
    final admin = AppUser(
      id: 'U-1',
      email: 'ahmed@admin.com',
      password: '1234',
      name: 'Ahmed',
      address: 'Cairo',
      phone: '01000000000',
      role: AppUserRole.admin,
    );
    _users[admin.email.toLowerCase()] = admin;
  }
  static final UserStore _instance = UserStore._internal();
  factory UserStore() => _instance;

  final Map<String, AppUser> _users = {};
  AppUser? _current;

  final List<TowApplicant> _pendingTow = [];

  AppUser? get currentUser => _current;
  bool get isLoggedIn => _current != null;
  bool get isAdmin => _current?.role == AppUserRole.admin;
  bool get canSell =>
      _current?.role == AppUserRole.seller &&
          _current?.sellerStatus == SellerStatus.approved;

  bool emailExists(String email) => _users.containsKey(email.toLowerCase());

  // -------- Auth --------
  AppUser? authenticate(String emailOrName, String password) {
    final key = emailOrName.trim().toLowerCase();
    AppUser? u = _users[key];
    if (u == null) {
      for (final e in _users.values) {
        if (e.name.toLowerCase() == key) { u = e; break; }
      }
    }
    if (u == null) return null;
    if (u.password != password) return null;
    _current = u;
    notifyListeners();
    return u;
  }

  void signOut() { _current = null; notifyListeners(); }

  // -------- Sign Up --------
  AppUser signUpBuyer({
    required String email,
    required String password,
    required String name,
    required String address,
    required String phone,
  }) {
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) { throw StateError('exists'); }
    final u = AppUser(
      id: 'U-${DateTime.now().millisecondsSinceEpoch}',
      email: key,
      password: password,
      name: name,
      address: address,
      phone: phone,
      role: AppUserRole.buyer,
    );
    _users[key] = u;
    notifyListeners();
    return u;
  }

  AppUser signUpSeller({
    required String email,
    required String password,
    required String name,
    required String address,
    required String phone,
    required String storeName,
    String? commercialRegUrl,
    String? taxCardUrl,
  }) {
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) { throw StateError('exists'); }
    final u = AppUser(
      id: 'U-${DateTime.now().millisecondsSinceEpoch}',
      email: key,
      password: password,
      name: name,
      address: address,
      phone: phone,
      role: AppUserRole.seller,
      storeName: storeName,
      commercialRegUrl: commercialRegUrl,
      taxCardUrl: taxCardUrl,
      sellerStatus: SellerStatus.pending,
    );
    _users[key] = u;
    notifyListeners();
    return u;
  }

  List<AppUser> pendingSellers() {
    final r = _users.values.where((u) =>
    u.role == AppUserRole.seller && u.sellerStatus == SellerStatus.pending
    ).toList();
    r.sort((a,b)=> a.name.compareTo(b.name));
    return r;
  }

  // -------- Tow sign-up --------
  TowApplicant signUpTow({
    required String companyName,
    required String area,
    required double lat,
    required double lng,
    required double baseCost,
    required double pricePerKm,
    required String contactName,
    required String contactEmail,
    required String contactPhone,
  }) {
    final a = TowApplicant(
      id: 'TA-${DateTime.now().millisecondsSinceEpoch}',
      companyName: companyName,
      area: area,
      lat: lat,
      lng: lng,
      baseCost: baseCost,
      pricePerKm: pricePerKm,
      contactName: contactName,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      createdAt: DateTime.now(),
    );
    _pendingTow.add(a);
    notifyListeners();
    return a;
  }

  List<TowApplicant> pendingTowCompanies() =>
      _pendingTow.where((x) => x.status == 'pending').toList()
        ..sort((a,b)=> b.createdAt.compareTo(a.createdAt));

  void approveTow(String applicantId) {
    final idx = _pendingTow.indexWhere((x) => x.id == applicantId);
    if (idx == -1) return;
    final a = _pendingTow[idx];
    _pendingTow[idx].status = 'approved';
    _pendingTow[idx].rejectReason = null;

    TowDirectory().addApproved(
      TowCompany(
        id: a.id,
        name: a.companyName,
        area: a.area,
        lat: a.lat,
        lng: a.lng,
        baseCost: a.baseCost,
        pricePerKm: a.pricePerKm,
      ),
    );
    notifyListeners();
  }

  void rejectTow(String applicantId, String reason) {
    final idx = _pendingTow.indexWhere((x) => x.id == applicantId);
    if (idx == -1) return;
    _pendingTow[idx].status = 'rejected';
    _pendingTow[idx].rejectReason = reason;
    notifyListeners();
  }

  // -------- Admin seller actions --------
  void approveSeller(String email) {
    final key = email.toLowerCase();
    final u = _users[key];
    if (u == null || u.role != AppUserRole.seller) return;
    _users[key] = u.copyWith(sellerStatus: SellerStatus.approved);
    notifyListeners();
  }

  void rejectSeller(String email) {
    final key = email.toLowerCase();
    final u = _users[key];
    if (u == null || u.role != AppUserRole.seller) return;
    _users[key] = u.copyWith(sellerStatus: SellerStatus.rejected);
    notifyListeners();
  }

  void updateBuyerProfile({
    required String email,
    String? name,
    String? address,
    String? phone,
  }) {
    final key = email.toLowerCase();
    final u = _users[key];
    if (u == null) return;
    _users[key] = u.copyWith(name: name, address: address, phone: phone);
    if (_current?.email == key) _current = _users[key];
    notifyListeners();
  }
}
