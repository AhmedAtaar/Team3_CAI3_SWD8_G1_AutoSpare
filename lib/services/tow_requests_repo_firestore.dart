import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_spare/model/tow_request.dart';
import 'package:auto_spare/services/tow_requests_repository.dart';

class TowRequestsRepoFirestore implements TowRequestsRepository {
  final _col = FirebaseFirestore.instance.collection('tow_requests');

  @override
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
  }) async {
    final now = DateTime.now();

    await _col.add({
      'companyId': companyId,
      'companyNameSnapshot': companyNameSnapshot,
      'userId': userId,
      'fromLat': fromLat,
      'fromLng': fromLng,
      'destLat': destLat,
      'destLng': destLng,
      'baseCost': baseCost,
      'kmTotal': kmTotal,
      'kmPrice': kmPrice,
      'kmCost': kmCost,
      'totalCost': totalCost,
      'vehicle': vehicle,
      'plate': plate,
      'problem': problem,
      'contactPhone': contactPhone,
      'status': TowRequestStatus.pending.name,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),

      'companySeen': false,
      'userSeen': false,
    });
  }

  @override
  Stream<List<TowRequestDoc>> watchCompanyRequests(String companyId) {
    return _col
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => TowRequestDoc.fromSnapshot(doc)).toList(),
        );
  }

  @override
  Stream<List<TowRequestDoc>> watchUserRequests(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => TowRequestDoc.fromSnapshot(doc)).toList(),
        );
  }

  @override
  Stream<List<TowRequestDoc>> watchAllAdmin() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => TowRequestDoc.fromSnapshot(doc)).toList(),
        );
  }

  @override
  Future<void> updateStatus({
    required String requestId,
    required TowRequestStatus next,
  }) async {
    final now = DateTime.now();

    await _col.doc(requestId).update({
      'status': next.name,
      'updatedAt': Timestamp.fromDate(now),

      'companySeen': true,

      'userSeen': false,
    });
  }

  @override
  Future<void> markCompanySeen({required String requestId}) async {
    await _col.doc(requestId).update({'companySeen': true});
  }

  @override
  Future<void> markUserSeen({required String requestId}) async {
    await _col.doc(requestId).update({'userSeen': true});
  }

  @override
  Future<void> cancelByUser({required String requestId, String? reason}) async {
    await _col.doc(requestId).update({
      'status': TowRequestStatus.cancelled.name,
      'userCancelReason': reason,
      'userCancelledAt': Timestamp.now(),

      'companySeen': false,

      'userSeen': true,
      'updatedAt': Timestamp.now(),
    });
  }
}
