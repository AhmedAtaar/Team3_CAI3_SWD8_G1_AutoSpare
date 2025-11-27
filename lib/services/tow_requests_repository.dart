import 'package:auto_spare/model/tow_request.dart';

abstract class TowRequestsRepository {
  Future<void> createRequest({
    required String companyId,
    required String companyNameSnapshot,
    required String? userId,
    required double fromLat,
    required double fromLng,
    double? destLat,
    double? destLng,
    required double baseCost,
    required double kmTotal,
    required double kmPrice,
    required double kmCost,
    required double totalCost,
    required String vehicle,
    required String plate,
    required String problem,
    required String contactPhone,
  });

  Stream<List<TowRequestDoc>> watchCompanyRequests(String companyId);

  Stream<List<TowRequestDoc>> watchUserRequests(String userId);

  Stream<List<TowRequestDoc>> watchAllAdmin();

  Future<void> updateStatus({
    required String requestId,
    required TowRequestStatus next,
  });

  Future<void> markCompanySeen({required String requestId});

  Future<void> markUserSeen({required String requestId});

  Future<void> cancelByUser({required String requestId, String? reason});
}
