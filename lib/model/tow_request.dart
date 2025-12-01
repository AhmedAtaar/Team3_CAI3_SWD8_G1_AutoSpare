import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

enum TowRequestStatus {
  pending,
  accepted,
  onTheWay,
  completed,
  cancelled,
  rejected,
}

String towStatusAr(TowRequestStatus status) {
  switch (status) {
    case TowRequestStatus.pending:
      return 'tow_status.pending'.tr();
    case TowRequestStatus.accepted:
      return 'tow_status.accepted'.tr();
    case TowRequestStatus.onTheWay:
      return 'tow_status.on_the_way'.tr();
    case TowRequestStatus.completed:
      return 'tow_status.completed'.tr();
    case TowRequestStatus.cancelled:
      return 'tow_status.cancelled'.tr();
    case TowRequestStatus.rejected:
      return 'tow_status.rejected'.tr();
  }
}

class TowRequestDoc {
  final String id;

  final String companyId;
  final String companyNameSnapshot;
  final String? userId;

  final double fromLat;
  final double fromLng;
  final double? destLat;
  final double? destLng;

  final double baseCost;
  final double kmTotal;
  final double kmPrice;
  final double kmCost;
  final double totalCost;

  final String vehicle;
  final String plate;
  final String problem;
  final String contactPhone;

  final TowRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  final bool companySeen;
  final bool userSeen;

  TowRequestDoc({
    required this.id,
    required this.companyId,
    required this.companyNameSnapshot,
    required this.userId,
    required this.fromLat,
    required this.fromLng,
    required this.destLat,
    required this.destLng,
    required this.baseCost,
    required this.kmTotal,
    required this.kmPrice,
    required this.kmCost,
    required this.totalCost,
    required this.vehicle,
    required this.plate,
    required this.problem,
    required this.contactPhone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.companySeen,
    required this.userSeen,
  });

  static TowRequestStatus _statusFromString(String? value) {
    switch (value) {
      case 'pending':
        return TowRequestStatus.pending;
      case 'accepted':
        return TowRequestStatus.accepted;
      case 'onTheWay':
        return TowRequestStatus.onTheWay;
      case 'completed':
        return TowRequestStatus.completed;
      case 'cancelled':
        return TowRequestStatus.cancelled;
      case 'rejected':
        return TowRequestStatus.rejected;
      default:
        return TowRequestStatus.pending;
    }
  }

  factory TowRequestDoc.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final createdTs = data['createdAt'] as Timestamp?;
    final updatedTs = data['updatedAt'] as Timestamp?;

    return TowRequestDoc(
      id: doc.id,
      companyId: (data['companyId'] ?? '') as String,
      companyNameSnapshot: (data['companyNameSnapshot'] ?? '') as String,
      userId: data['userId'] as String?,
      fromLat: (data['fromLat'] as num).toDouble(),
      fromLng: (data['fromLng'] as num).toDouble(),
      destLat: (data['destLat'] as num?)?.toDouble(),
      destLng: (data['destLng'] as num?)?.toDouble(),
      baseCost: (data['baseCost'] as num).toDouble(),
      kmTotal: (data['kmTotal'] as num).toDouble(),
      kmPrice: (data['kmPrice'] as num).toDouble(),
      kmCost: (data['kmCost'] as num).toDouble(),
      totalCost: (data['totalCost'] as num).toDouble(),
      vehicle: (data['vehicle'] ?? '') as String,
      plate: (data['plate'] ?? '') as String,
      problem: (data['problem'] ?? '') as String,
      contactPhone: (data['contactPhone'] ?? '') as String,
      status: _statusFromString(data['status'] as String?),
      createdAt: createdTs?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: updatedTs?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      companySeen: (data['companySeen'] as bool?) ?? false,
      userSeen: (data['userSeen'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'companySeen': companySeen,
      'userSeen': userSeen,
    };
  }
}
