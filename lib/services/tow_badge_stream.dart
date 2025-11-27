import 'dart:async';

import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/services/tow_requests.dart';

Stream<int> towNotificationCountStreamForCurrentUser() {
  final controller = StreamController<int>();

  StreamSubscription? buyerSub;
  StreamSubscription? companySub;

  void listenForUser() {
    final u = UserStore().currentUser;

    if (u == null) {
      controller.add(0);
      return;
    }

    final uid = u.id;
    final cid = u.towCompanyId;

    buyerSub = towRequestsRepo.watchUserRequests(uid).listen((list) {
      final buyerUnseen = list.where((r) => !r.userSeen).length;

      if (cid == null || cid.isEmpty) {
        controller.add(buyerUnseen);
      }
    });

    if (cid != null && cid.isNotEmpty) {
      companySub = towRequestsRepo.watchCompanyRequests(cid).listen((
        companyList,
      ) {
        final u2 = UserStore().currentUser;
        if (u2 == null) {
          controller.add(0);
          return;
        }

        final userListNow = [];
      });
    }
  }

  buyerSub?.cancel();
  companySub?.cancel();

  controller.onListen = () {
    final u = UserStore().currentUser;
    if (u == null) {
      controller.add(0);
      return;
    }

    final uid = u.id;
    final cid = u.towCompanyId;

    int buyerUnseen = 0;
    int companyUnseen = 0;

    buyerSub = towRequestsRepo.watchUserRequests(uid).listen((list) {
      buyerUnseen = list.where((r) => !r.userSeen).length;
      controller.add(buyerUnseen + companyUnseen);
    });

    if (cid != null && cid.isNotEmpty) {
      companySub = towRequestsRepo.watchCompanyRequests(cid).listen((list) {
        companyUnseen = list.where((r) => !r.companySeen).length;
        controller.add(buyerUnseen + companyUnseen);
      });
    } else {
      companyUnseen = 0;
      controller.add(buyerUnseen);
    }
  };

  controller.onCancel = () {
    buyerSub?.cancel();
    companySub?.cancel();
  };

  return controller.stream;
}
