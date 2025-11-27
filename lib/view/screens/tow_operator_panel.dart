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

          return Scaffold(
            appBar: AppBar(
              title: Text('لوحة ${c.name}'),
              actions: [
                IconButton(
                  tooltip: 'تبديل الحالة',
                  onPressed: () => dir.toggleOnline(c.id),
                  icon: const Icon(Icons.power_settings_new),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_shipping_outlined),
                      title: Text('${c.name} • ${c.area}'),
                      subtitle: Text(
                        '(${c.lat.toStringAsFixed(5)}, ${c.lng.toStringAsFixed(5)})',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('متاح الآن (Online)'),
                    subtitle: const Text('يمكن للعملاء رؤية شركتك والحجز'),
                    value: c.isOnline,
                    onChanged: (v) => dir.setOnline(c.id, v),
                  ),
                  const SizedBox(height: 8),
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

                  Text(
                    'طلبات السحب الحالية',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: StreamBuilder<List<TowRequestDoc>>(
                      stream: towRequestsRepo.watchCompanyRequests(c.id),
                      builder: (context, snap) {
                        final list = snap.data ?? const <TowRequestDoc>[];

                        if (list.isNotEmpty) {
                          final unseen = list
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

                        if (list.isEmpty) {
                          return const Center(
                            child: Text('لا توجد طلبات حاليًا'),
                          );
                        }

                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final r = list[i];
                            final isNew = !r.companySeen;

                            return Card(
                              color: isNew
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.05)
                                  : null,
                              child: ListTile(
                                title: Text(
                                  '${r.vehicle} • ${towStatusAr(r.status)}'
                                  '${isNew ? ' (جديد)' : ''}',
                                  textAlign: TextAlign.right,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'من: (${r.fromLat.toStringAsFixed(4)}, ${r.fromLng.toStringAsFixed(4)})\n'
                                      'إلى: ${r.destLat != null ? '(${r.destLat!.toStringAsFixed(4)}, ${r.destLng!.toStringAsFixed(4)})' : 'غير محدد'}\n'
                                      'إجمالي الخدمة: ${r.totalCost.toStringAsFixed(0)} جنيه\n'
                                      'الهاتف: ${r.contactPhone}',
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(height: 4),

                                    Wrap(
                                      alignment: WrapAlignment.end,
                                      spacing: 8,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            _openGoogleMaps(
                                              context,
                                              lat: r.fromLat,
                                              lng: r.fromLng,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.place_outlined,
                                            size: 16,
                                          ),
                                          label: const Text('موقع العميل'),
                                        ),
                                        if (r.destLat != null &&
                                            r.destLng != null)
                                          TextButton.icon(
                                            onPressed: () {
                                              _openGoogleMaps(
                                                context,
                                                lat: r.destLat!,
                                                lng: r.destLng!,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.flag_outlined,
                                              size: 16,
                                            ),
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
                                    PopupMenuItem(
                                      value: 'accept',
                                      child: Text('قبول الطلب'),
                                    ),
                                    PopupMenuItem(
                                      value: 'onway',
                                      child: Text('في الطريق'),
                                    ),
                                    PopupMenuItem(
                                      value: 'done',
                                      child: Text('تمت الخدمة'),
                                    ),
                                    PopupMenuItem(
                                      value: 'cancel',
                                      child: Text('إلغاء'),
                                    ),
                                  ],
                                  child: const Icon(Icons.more_vert),
                                ),
                              ),
                            );
                          },
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
          );
        },
      ),
    );
  }
}
