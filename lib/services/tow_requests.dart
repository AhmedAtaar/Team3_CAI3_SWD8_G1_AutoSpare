import 'package:auto_spare/services/tow_requests_repository.dart';
import 'package:auto_spare/services/tow_requests_repo_firestore.dart';

export 'package:auto_spare/model/tow_request.dart'
    show TowRequestDoc, TowRequestStatus, towStatusAr;

final TowRequestsRepository towRequestsRepo = TowRequestsRepoFirestore();
