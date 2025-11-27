import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/services/tow_requests.dart';

class TowBadgeController extends ChangeNotifier {
  TowBadgeController._internal();
  static final TowBadgeController _instance = TowBadgeController._internal();
  factory TowBadgeController() => _instance;

  int buyerUnseen = 0;
  int companyUnseen = 0;

  StreamSubscription<List<TowRequestDoc>>? _buyerSub;
  StreamSubscription<List<TowRequestDoc>>? _companySub;

  int get totalBadge => buyerUnseen + companyUnseen;

  void refreshForCurrentUser() {
    _buyerSub?.cancel();
    _companySub?.cancel();

    final u = UserStore().currentUser;

    if (u == null) {
      buyerUnseen = 0;
      companyUnseen = 0;
      notifyListeners();
      return;
    }

    final uid = u.id;

    _buyerSub = towRequestsRepo.watchUserRequests(uid).listen((list) {
      final newCount = list.where((r) => !r.userSeen).length;
      if (newCount != buyerUnseen) {
        buyerUnseen = newCount;
        notifyListeners();
      }
    });

    final cid = u.towCompanyId;
    if (cid != null && cid.isNotEmpty) {
      _companySub = towRequestsRepo.watchCompanyRequests(cid).listen((list) {
        final newCount = list.where((r) => !r.companySeen).length;
        if (newCount != companyUnseen) {
          companyUnseen = newCount;
          notifyListeners();
        }
      });
    } else {
      if (companyUnseen != 0) {
        companyUnseen = 0;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _buyerSub?.cancel();
    _companySub?.cancel();
    super.dispose();
  }
}
