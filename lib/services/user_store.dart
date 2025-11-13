
import 'package:flutter/foundation.dart'; // لـ ChangeNotifier


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

  AppUser? get currentUser => _current;
  bool get isLoggedIn => _current != null;
  bool get isAdmin => _current?.role == AppUserRole.admin;
  bool get canSell =>
      _current?.role == AppUserRole.seller &&
          _current?.sellerStatus == SellerStatus.approved;

  bool emailExists(String email) => _users.containsKey(email.toLowerCase());

  AppUser? authenticate(String emailOrName, String password) {
    final key = emailOrName.trim().toLowerCase();

    AppUser? u = _users[key];

    if (u == null) {
      for (final e in _users.values) {
        if (e.name.toLowerCase() == key) {
          u = e;
          break;
        }
      }
    }

    if (u == null) return null;
    if (u.password != password) return null;

    _current = u;
    notifyListeners();
    return u;
  }

  void signOut() {
    _current = null;
    notifyListeners();
  }

  AppUser signUpBuyer({
    required String email,
    required String password,
    required String name,
    required String address,
    required String phone,
  }) {
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) {
      throw StateError('exists');
    }

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
    if (_users.containsKey(key)) {
      throw StateError('exists');
    }

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
    return _users.values
        .where((u) =>
    u.role == AppUserRole.seller &&
        u.sellerStatus == SellerStatus.pending)
        .toList();
  }

  void approveSeller(String email) {
    final key = email.toLowerCase();
    final u = _users[key];
    if (u == null || u.role != AppUserRole.seller) return;
    _users[key] = u.copyWith(sellerStatus: SellerStatus.approved);
    if (_current?.email == key) _current = _users[key];
    notifyListeners();
  }

  void rejectSeller(String email) {
    final key = email.toLowerCase();
    final u = _users[key];
    if (u == null || u.role != AppUserRole.seller) return;
    _users[key] = u.copyWith(sellerStatus: SellerStatus.rejected);
    if (_current?.email == key) _current = _users[key];
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
