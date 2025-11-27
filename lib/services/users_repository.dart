import 'dart:async';

import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/tow_directory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsersRepository {
  UsersRepository._internal() {
    _init();
  }

  static final UsersRepository _instance = UsersRepository._internal();
  factory UsersRepository() => _instance;

  final Map<String, AppUser> _byId = {};
  final Map<String, String> _emailIndex = {};
  final Map<String, String> _phoneIndex = {};

  final _winchCtrl = StreamController<List<AppUser>>.broadcast();

  final CollectionReference<Map<String, dynamic>> _usersCol = FirebaseFirestore
      .instance
      .collection('users');

  void _init() {
    _usersCol.snapshots().listen((snapshot) {
      _byId.clear();
      _emailIndex.clear();
      _phoneIndex.clear();

      for (final doc in snapshot.docs) {
        final user = _fromFirestore(doc.id, doc.data());
        _byId[user.id] = user;
        _emailIndex[user.email] = user.id;
        _phoneIndex[user.phone] = user.id;
      }

      final winches = _byId.values
          .where((u) => u.role == AppUserRole.winch || u.canTow == true)
          .toList(growable: false);
      _winchCtrl.add(winches);
    });
  }

  AppUser _fromFirestore(String id, Map<String, dynamic> data) {
    final roleString = (data['role'] as String?) ?? 'buyer';
    final role = AppUserRole.values.firstWhere(
      (r) => r.name == roleString,
      orElse: () => AppUserRole.buyer,
    );

    return AppUser(
      id: id,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      phone: (data['phone'] ?? '') as String,
      address: (data['address'] ?? '') as String,
      password: '',
      role: role,
      approved: (data['approved'] as bool?) ?? false,
      canSell: (data['canSell'] as bool?) ?? false,
      canTow: (data['canTow'] as bool?) ?? false,
      maxWinches: (data['maxWinches'] as int?) ?? 0,
      docUrls: (data['docUrls'] as List?)?.cast<String>(),
      towLicenseUrl: data['towLicenseUrl'] as String?,
      towDriverIdUrl: data['towDriverIdUrl'] as String?,
      towCompanyId: data['towCompanyId'] as String?,
      storeName: data['storeName'] as String?,
      commercialRegUrl: data['commercialRegUrl'] as String?,
      taxCardUrl: data['taxCardUrl'] as String?,
    );
  }

  Map<String, dynamic> _toFirestore(AppUser user) {
    return {
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'address': user.address,
      'role': user.role.name,
      'approved': user.approved,
      'canSell': user.canSell,
      'canTow': user.canTow,
      'maxWinches': user.maxWinches,
      'docUrls': user.docUrls,
      'towLicenseUrl': user.towLicenseUrl,
      'towDriverIdUrl': user.towDriverIdUrl,
      'towCompanyId': user.towCompanyId,
      'storeName': user.storeName,
      'commercialRegUrl': user.commercialRegUrl,
      'taxCardUrl': user.taxCardUrl,
    };
  }

  Future<void> addUser(AppUser user) async {
    final emailSnap = await _usersCol
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (emailSnap.docs.isNotEmpty) {
      throw StateError('exists');
    }

    final phoneSnap = await _usersCol
        .where('phone', isEqualTo: user.phone)
        .limit(1)
        .get();
    if (phoneSnap.docs.isNotEmpty) {
      throw StateError('exists');
    }

    await _usersCol.doc(user.id).set(_toFirestore(user));
  }

  Future<void> updateUser(AppUser user) async {
    await _usersCol.doc(user.id).update(_toFirestore(user));
  }

  List<AppUser> get allUsers => _byId.values.toList(growable: false);

  Future<AppUser?> findByPhoneAndPassword(String phone, String password) async {
    final snap = await _usersCol
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      return null;
    }

    final doc = snap.docs.first;
    final data = doc.data();
    final email = (data['email'] as String?) ?? '';
    if (email.isEmpty) {
      return null;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      return null;
    }

    final user = _fromFirestore(doc.id, data);

    _byId[user.id] = user;
    _emailIndex[user.email] = user.id;
    _phoneIndex[user.phone] = user.id;

    return user;
  }

  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;
      final doc = await _usersCol.doc(uid).get();
      if (!doc.exists) return null;

      final user = _fromFirestore(doc.id, doc.data()!);

      _byId[user.id] = user;
      _emailIndex[user.email] = user.id;
      _phoneIndex[user.phone] = user.id;

      return user;
    } on FirebaseAuthException {
      return null;
    }
  }

  Stream<List<AppUser>> watchWinchUsers() => _winchCtrl.stream;

  Future<void> approveTowCompany(String userId, String companyId) async {
    final doc = await _usersCol.doc(userId).get();
    if (!doc.exists) return;
    final existing = _fromFirestore(doc.id, doc.data()!);

    final updated = existing.copyWith(
      canTow: true,
      towCompanyId: companyId,
      approved: true,
    );

    await _usersCol.doc(userId).update(_toFirestore(updated));

    TowDirectory().addApproved(
      TowCompany(
        id: companyId,
        name: updated.name,
        area: "Cairo",
        lat: 30.0,
        lng: 31.0,
        baseCost: 300,
        pricePerKm: 45,
        isOnline: true,
      ),
    );
  }

  Future<void> updateWinch(
    String userId, {
    bool? approved,
    int? maxWinches,
  }) async {
    final doc = await _usersCol.doc(userId).get();
    if (!doc.exists) return;
    final existing = _fromFirestore(doc.id, doc.data()!);

    final updated = existing.copyWith(
      approved: approved ?? existing.approved,
      maxWinches: maxWinches ?? existing.maxWinches,
    );

    await _usersCol.doc(userId).update(_toFirestore(updated));
  }
}

final UsersRepository usersRepo = UsersRepository();
