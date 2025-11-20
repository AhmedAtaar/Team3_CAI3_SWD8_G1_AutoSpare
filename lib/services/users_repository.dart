// lib/services/users_repository.dart

import 'dart:async';
import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/tow_directory.dart';
import 'package:auto_spare/services/user_password_store.dart';

class UsersRepository {
  UsersRepository._internal();
  static final UsersRepository _instance = UsersRepository._internal();
  factory UsersRepository() => _instance;

  final Map<String, AppUser> _byId = {};
  final Map<String, String> _emailIndex = {};
  final Map<String, String> _phoneIndex = {};

  final _winchCtrl = StreamController<List<AppUser>>.broadcast();

  void init() {
    final admin = AppUser(
      id: 'admin-1',
      name: 'Admin',
      email: 'admin@local',
      phone: '0000',
      address: 'N/A',
      password: 'admin',        // مؤقت
      role: AppUserRole.admin,
      approved: true,
      canSell: false,
      canTow: false,
    );
    addUser(admin);
  }

  void _emitWinches() {
    final list = _byId.values.where((u) => u.canTow == true).toList();
    _winchCtrl.add(list);
  }

  Future<void> addUser(AppUser user) async {
    if (_emailIndex.containsKey(user.email) ||
        _phoneIndex.containsKey(user.phone)) {
      throw StateError('exists');
    }

    _byId[user.id] = user;
    _emailIndex[user.email] = user.id;
    _phoneIndex[user.phone] = user.id;

    // ✅ تخزين الباسورد الحقيقي في UserPasswordStore
    UserPasswordStore.setPassword(user.id, user.password);

    _emitWinches();
  }

  // ✅ تحديث بيانات يوزر موجود (نستخدمها في approve / reject seller)
  Future<void> updateUser(AppUser user) async {
    if (!_byId.containsKey(user.id)) return;
    _byId[user.id] = user;
    _emitWinches();
  }

  List<AppUser> get allUsers => _byId.values.toList();

  AppUser? findByPhoneAndPassword(String phone, String password) {
    final id = _phoneIndex[phone];
    if (id == null) return null;
    final u = _byId[id];
    if (u == null || UserPasswordStore.passwordOf(u.id) != password) {
      return null;
    }
    return u;
  }

  Stream<List<AppUser>> watchWinchUsers() => _winchCtrl.stream;

  Future<void> approveTowCompany(String userId, String companyId) async {
    final existing = _byId[userId];
    if (existing == null) return;
    final updated = existing.copyWith(
      canTow: true,
      towCompanyId: companyId,
      approved: true,
    );
    _byId[userId] = updated;

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

    _emitWinches();
  }
  // ✅ تحديث بيانات حساب ونش (قبول + عدد الأوناش)
  Future<void> updateWinch(
      String userId, {
        bool? approved,
        int? maxWinches,
      }) async {
    final existing = _byId[userId];
    if (existing == null) return;

    final updated = existing.copyWith(
      approved: approved ?? existing.approved,
      maxWinches: maxWinches ?? existing.maxWinches,
    );

    _byId[userId] = updated;
    _emitWinches();
  }
}

final UsersRepository usersRepo = UsersRepository()..init();
