import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:auto_spare/services/tow_requests.dart';

class AdminTowOrdersScreen extends StatelessWidget {
  const AdminTowOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final col = FirebaseFirestore.instance.collection('tow_requests');

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('admin.tow_orders_title'.tr()),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: col.orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snap.data?.docs ?? const [];

              if (docs.isEmpty) {
                return Center(child: Text('admin.no_tow_orders'.tr()));
              }

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final doc = docs[i];
                  final data = doc.data();

                  final r = TowRequestDoc.fromSnapshot(doc);

                  final userCancelReason = (data['userCancelReason'] as String?)
                      ?.trim();
                  final userCancelledAt =
                      (data['userCancelledAt'] as Timestamp?)?.toDate();

                  final isCancelledByUser =
                      r.status == TowRequestStatus.cancelled &&
                      (userCancelReason != null && userCancelReason.isNotEmpty);

                  String statusLine = towStatusAr(r.status);
                  if (r.status == TowRequestStatus.cancelled) {
                    if (isCancelledByUser) {
                      statusLine += ' • ${'admin.cancelled_by_buyer'.tr()}';
                    } else {
                      statusLine += ' • ${'admin.cancelled_by_company'.tr()}';
                    }
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                color: _towStatusColor(cs, r.status),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  statusLine,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(r.createdAt),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          Text(
                            'admin.company_label'.tr(
                              args: [r.companyNameSnapshot],
                            ),
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            'admin.total_label'.tr(
                              args: [
                                r.totalCost.toStringAsFixed(0),
                                'currency.egp'.tr(),
                              ],
                            ),
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            '${'admin.vehicle_label'.tr(args: [r.vehicle])} • ${'admin.plate_label'.tr(args: [r.plate])}',
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            'admin.client_phone'.tr(args: [r.contactPhone]),
                            textAlign: TextAlign.right,
                          ),

                          if (isCancelledByUser) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.withOpacity(.4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'admin.cancellation_reason_buyer'.tr(),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userCancelReason,
                                    textAlign: TextAlign.right,
                                  ),
                                  if (userCancelledAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'admin.cancellation_date'.tr(
                                        args: [_formatDate(userCancelledAt)],
                                      ),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Color _towStatusColor(ColorScheme cs, TowRequestStatus status) {
    switch (status) {
      case TowRequestStatus.completed:
        return Colors.green;
      case TowRequestStatus.cancelled:
      case TowRequestStatus.rejected:
        return Colors.red;
      case TowRequestStatus.accepted:
      case TowRequestStatus.onTheWay:
        return cs.primary;
      case TowRequestStatus.pending:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} – '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
