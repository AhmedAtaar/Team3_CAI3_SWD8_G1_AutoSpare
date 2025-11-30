import 'package:flutter/material.dart';
import 'package:auto_spare/services/tow_directory.dart';
import 'package:auto_spare/services/tow_requests.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _openGoogleMaps(
  BuildContext context, {
  required double lat,
  required double lng,
}) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  );

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تعذّر فتح الخريطة')));
  }
}

bool _isActiveStatus(TowRequestStatus s) {
  switch (s) {
    case TowRequestStatus.pending:
    case TowRequestStatus.accepted:
    case TowRequestStatus.onTheWay:
      return true;

    case TowRequestStatus.completed:
    case TowRequestStatus.cancelled:
    case TowRequestStatus.rejected:
      return false;
  }
}

Color _statusColor(BuildContext ctx, TowRequestStatus s) {
  final cs = Theme.of(ctx).colorScheme;
  switch (s) {
    case TowRequestStatus.pending:
      return Colors.orange;
    case TowRequestStatus.accepted:
      return cs.primary;
    case TowRequestStatus.onTheWay:
      return Colors.blue;
    case TowRequestStatus.completed:
      return Colors.green;
    case TowRequestStatus.cancelled:
      return Colors.red;
    case TowRequestStatus.rejected:
      return Colors.deepOrange;
  }
}

class TowOperatorPanel extends StatelessWidget {
  final String companyId;
  const TowOperatorPanel({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    final dir = TowDirectory();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: dir,
        builder: (_, __) {
          final c = dir.all.firstWhere(
            (x) => x.id == companyId,
            orElse: () => throw Exception('Company not found: $companyId'),
          );

          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('لوحة ${c.name}'),
                actions: [
                  IconButton(
                    tooltip: c.isOnline
                        ? 'إيقاف استقبال الطلبات'
                        : 'تفعيل استقبال الطلبات',
                    onPressed: () => dir.toggleOnline(c.id),
                    icon: Icon(
                      Icons.power_settings_new,
                      color: c.isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'طلبات جارية'),
                    Tab(text: 'منتهية'),
                  ],
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            Icons.local_shipping_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          '${c.name} • ${c.area}',
                          textAlign: TextAlign.right,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'الإحداثيات: (${c.lat.toStringAsFixed(5)}, ${c.lng.toStringAsFixed(5)})',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  c.isOnline
                                      ? Icons.circle
                                      : Icons.circle_outlined,
                                  size: 10,
                                  color: c.isOnline
                                      ? Colors.green
                                      : Colors.redAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  c.isOnline
                                      ? 'متصل • يستقبل طلبات'
                                      : 'غير متصل',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: c.isOnline
                                        ? Colors.green
                                        : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      title: const Text('متاح الآن (Online)'),
                      subtitle: const Text('يمكن للعملاء رؤية شركتك والحجز'),
                      value: c.isOnline,
                      onChanged: (v) => dir.setOnline(c.id, v),
                    ),
                    const SizedBox(height: 4),
                    if (!c.isOnline)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: const Text(
                          'أنت خارج الخدمة حاليًا. فعّل الحالة لتظهر لعملائك القريبين.',
                          textAlign: TextAlign.right,
                        ),
                      ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: StreamBuilder<List<TowRequestDoc>>(
                        stream: towRequestsRepo.watchCompanyRequests(c.id),
                        builder: (context, snap) {
                          final raw = snap.data ?? const <TowRequestDoc>[];
                          final all = List<TowRequestDoc>.from(raw);


                          if (all.isNotEmpty) {
                            final unseen = all
                                .where((r) => !r.companySeen)
                                .toList();
                            if (unseen.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                for (final r in unseen) {
                                  towRequestsRepo.markCompanySeen(
                                    requestId: r.id,
                                  );
                                }
                              });
                            }
                          }

                          final active = all
                              .where((r) => _isActiveStatus(r.status))
                              .toList();
                          final history = all
                              .where((r) => !_isActiveStatus(r.status))
                              .toList();

                          if (all.isEmpty) {
                            return const Center(
                              child: Text('لا توجد طلبات حتى الآن'),
                            );
                          }

                          return TabBarView(
                            children: [
                              _RequestsList(
                                requests: active,
                                emptyText: 'لا توجد طلبات جارية حاليًا',
                              ),
                              _RequestsList(
                                requests: history,
                                emptyText: 'لا توجد طلبات منتهية حتى الآن',
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => dir.toggleOnline(c.id),
                      icon: const Icon(Icons.toggle_on),
                      label: Text(
                        c.isOnline ? 'تحويل إلى غير متاح' : 'تحويل إلى متاح',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  final List<TowRequestDoc> requests;
  final String emptyText;

  const _RequestsList({required this.requests, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(child: Text(emptyText, textAlign: TextAlign.center));
    }

    return ListView.separated(
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = requests[i];
        final isNew = !r.companySeen;
        final statusClr = _statusColor(context, r.status);
        final cs = Theme.of(context).colorScheme;

        return Card(
          color: isNew ? cs.primary.withOpacity(0.04) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      r.vehicle.isNotEmpty ? r.vehicle : 'مركبة بدون وصف',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      towStatusAr(r.status) + (isNew ? ' • جديد' : ''),
                      style: TextStyle(color: statusClr, fontSize: 12),
                    ),
                    backgroundColor: statusClr.withOpacity(0.08),
                    side: BorderSide(color: statusClr.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 0,
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'من: (${r.fromLat.toStringAsFixed(4)}, ${r.fromLng.toStringAsFixed(4)})\n'
                    'إلى: ${r.destLat != null ? '(${r.destLat!.toStringAsFixed(4)}, ${r.destLng!.toStringAsFixed(4)})' : 'غير محدد'}\n'
                    'إجمالي الخدمة: ${r.totalCost.toStringAsFixed(0)} جنيه\n'
                    'الهاتف: ${r.contactPhone}',
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          _openGoogleMaps(
                            context,
                            lat: r.fromLat,
                            lng: r.fromLng,
                          );
                        },
                        icon: const Icon(Icons.place_outlined, size: 16),
                        label: const Text('موقع العميل'),
                      ),
                      if (r.destLat != null && r.destLng != null)
                        TextButton.icon(
                          onPressed: () {
                            _openGoogleMaps(
                              context,
                              lat: r.destLat!,
                              lng: r.destLng!,
                            );
                          },
                          icon: const Icon(Icons.flag_outlined, size: 16),
                          label: const Text('مكان التسليم'),
                        ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (val) async {
                  TowRequestStatus next;
                  switch (val) {
                    case 'accept':
                      next = TowRequestStatus.accepted;
                      break;
                    case 'onway':
                      next = TowRequestStatus.onTheWay;
                      break;
                    case 'done':
                      next = TowRequestStatus.completed;
                      break;
                    case 'cancel':
                      next = TowRequestStatus.cancelled;
                      break;
                    default:
                      return;
                  }
                  await towRequestsRepo.updateStatus(
                    requestId: r.id,
                    next: next,
                  );
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'accept', child: Text('قبول الطلب')),
                  PopupMenuItem(value: 'onway', child: Text('في الطريق')),
                  PopupMenuItem(value: 'done', child: Text('تمت الخدمة')),
                  PopupMenuItem(value: 'cancel', child: Text('إلغاء')),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ),
          ),
        );
      },
    );
  }
}
