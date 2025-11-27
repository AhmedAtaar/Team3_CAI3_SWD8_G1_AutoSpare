import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:auto_spare/services/tow_directory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final String? commercialRegUrl;
  final String? taxCardUrl;

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

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'area': area,
      'lat': lat,
      'lng': lng,
      'baseCost': baseCost,
      'pricePerKm': pricePerKm,
      'contactName': contactName,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'commercialRegUrl': commercialRegUrl,
      'taxCardUrl': taxCardUrl,
      'status': status.name,
      'rejectReason': rejectReason,
      'userId': userId,
      'tempPassword': tempPassword,
    };
  }

  factory TowCompanyRequest.fromDoc(String id, Map<String, dynamic> data) {
    final statusStr = data['status'] as String? ?? 'pending';
    final status = SellerStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => SellerStatus.pending,
    );

    return TowCompanyRequest(
      id: id,
      companyName: data['companyName'] as String? ?? '',
      area: data['area'] as String? ?? '',
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      baseCost: (data['baseCost'] as num?)?.toDouble() ?? 0.0,
      pricePerKm: (data['pricePerKm'] as num?)?.toDouble() ?? 0.0,
      contactName: data['contactName'] as String? ?? '',
      contactEmail: data['contactEmail'] as String? ?? '',
      contactPhone: data['contactPhone'] as String? ?? '',
      commercialRegUrl: data['commercialRegUrl'] as String?,
      taxCardUrl: data['taxCardUrl'] as String?,
      status: status,
      rejectReason: data['rejectReason'] as String?,
      userId: data['userId'] as String?,
      tempPassword: data['tempPassword'] as String?,
    );
  }
}

class UserStore {
  UserStore._internal() {
    _listenTowRequests();
  }

  static final UserStore _instance = UserStore._internal();
  factory UserStore() => _instance;

  AppUser? currentUser;

  bool isGuest = false;

  void setGuest() {
    currentUser = null;
    isGuest = true;
  }

  void setLoggedInUser(AppUser user) {
    currentUser = user;
    isGuest = false;
  }

  final List<TowCompanyRequest> _tows = [];

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _towCol =>
      _db.collection('towCompanyRequests');

  void _listenTowRequests() {
    _towCol.snapshots().listen((snap) {
      _tows
        ..clear()
        ..addAll(
          snap.docs.map((d) => TowCompanyRequest.fromDoc(d.id, d.data())),
        );
    });
  }

  Future<void> signUpBuyer({
    required String email,
    required String password,
    required String name,
    required String address,
    required String phone,
  }) async {
    final auth = FirebaseAuth.instance;
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final id = cred.user!.uid;

    final user = AppUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      password: '',
      role: AppUserRole.buyer,
    );

    await usersRepo.addUser(user);
  }

  Future<void> signUpSeller({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String storeName,
    String? commercialRegUrl,
    String? taxCardUrl,
  }) async {
    final auth = FirebaseAuth.instance;
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final id = cred.user!.uid;

    final user = AppUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      password: '',
      role: AppUserRole.seller,
      approved: false,
      canSell: false,
      storeName: storeName,
      commercialRegUrl: commercialRegUrl,
      taxCardUrl: taxCardUrl,
    );

    await usersRepo.addUser(user);
  }

  Future<void> signUpTow({
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
  }) async {
    final doc = _towCol.doc();
    final req = TowCompanyRequest(
      id: doc.id,
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
      status: SellerStatus.pending,
    );

    await doc.set(req.toMap());
  }

  List<TowCompanyRequest> pendingTowCompanies() {
    return _tows.where((t) => t.status == SellerStatus.pending).toList();
  }

  List<TowCompanyRequest> get tows => List.unmodifiable(_tows);

  Future<void> rejectTow(String id, String reason) async {
    final i = _tows.indexWhere((t) => t.id == id);
    if (i == -1) return;

    final req = _tows[i];
    req.status = SellerStatus.rejected;
    req.rejectReason = reason;

    await _towCol.doc(id).update({
      'status': SellerStatus.rejected.name,
      'rejectReason': reason,
    });
  }

  Future<void> approveTow(String reqId) async {
    final idx = _tows.indexWhere((t) => t.id == reqId);
    if (idx == -1) return;

    final req = _tows[idx];
    req.status = SellerStatus.approved;

    final auth = FirebaseAuth.instance;
    final email = req.contactEmail;
    final password = req.tempPassword ?? '1234';

    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final userId = cred.user!.uid;

    final user = AppUser(
      id: userId,
      name: req.contactName,
      email: req.contactEmail,
      phone: req.contactPhone,
      address: req.area,
      password: '',
      role: AppUserRole.winch,
      approved: true,
      canTow: true,
      towCompanyId: req.id,
    );

    await usersRepo.addUser(user);
    req.userId = userId;

    await _towCol.doc(req.id).update({
      'status': SellerStatus.approved.name,
      'userId': userId,
      'rejectReason': null,
      'tempPassword': null,
    });

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

  Future<void> signOutCurrentUser() async {
    currentUser = null;
    isGuest = false;
    await FirebaseAuth.instance.signOut();
  }
}
