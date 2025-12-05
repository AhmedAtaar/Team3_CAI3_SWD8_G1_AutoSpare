import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_spare/core/tow_status_localized.dart';

import 'package:auto_spare/services/tow_requests.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class AdminTowOrdersScreen extends StatelessWidget {
  const AdminTowOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final col = FirebaseFirestore.instance.collection('tow_requests');
    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.admin_tow_orders_title),
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
                return Center(child: Text(loc.admin_tow_orders_no_requests));
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

                  String statusLine = towStatusText(context, r.status);
                  if (r.status == TowRequestStatus.cancelled) {
                    if (isCancelledByUser) {
                      statusLine +=
                          loc.admin_tow_orders_status_cancelled_by_user_suffix;
                    } else {
                      statusLine += loc
                          .admin_tow_orders_status_cancelled_by_company_suffix;
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
                            '${loc.admin_tow_orders_company_prefix} ${r.companyNameSnapshot}',
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            '${loc.admin_tow_orders_total_cost_prefix} ${r.totalCost.toStringAsFixed(0)} ${loc.currency_egp}',
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            '${loc.admin_tow_orders_vehicle_label} ${r.vehicle} • '
                            '${loc.admin_tow_orders_plate_label} ${r.plate}',
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            '${loc.admin_tow_orders_customer_phone_label} ${r.contactPhone}',
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
                                    loc.admin_tow_orders_cancel_reason_title,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userCancelReason!,
                                    textAlign: TextAlign.right,
                                  ),
                                  if (userCancelledAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${loc.admin_tow_orders_cancel_date_prefix} ${_formatDate(userCancelledAt)}',
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
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} – '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
