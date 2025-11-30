import 'package:auto_spare/services/tow_requests.dart';
import 'package:flutter/material.dart';

class AdminTowRequestsTab extends StatelessWidget {
  const AdminTowRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: StreamBuilder<List<TowRequestDoc>>(
        stream: towRequestsRepo.watchAllAdmin(),
        builder: (_, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                'حدث خطأ أثناء تحميل طلبات السحب:\n${snap.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final list = snap.data ?? const <TowRequestDoc>[];

          if (snap.connectionState == ConnectionState.waiting && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (list.isEmpty) {
            return const Center(
              child: Text('لا توجد طلبات سحب مسجلة حتى الآن'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final r = list[i];
              return Card(
                elevation: 0,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: cs.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'طلب #${r.id}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الشركة: ${r.companyNameSnapshot} (${r.companyId})',
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الحالة: ${towStatusAr(r.status)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: r.status == TowRequestStatus.completed
                              ? Colors.green
                              : (r.status == TowRequestStatus.cancelled
                                    ? Colors.red
                                    : Colors.orange),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المركبة: ${r.vehicle} • اللوحة: ${r.plate}',
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الهاتف: ${r.contactPhone}',
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'إجمالي الخدمة: ${r.totalCost.toStringAsFixed(0)} جنيه',
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'من: (${r.fromLat.toStringAsFixed(4)}, ${r.fromLng.toStringAsFixed(4)})',
                        textAlign: TextAlign.right,
                      ),
                      if (r.destLat != null && r.destLng != null)
                        Text(
                          'إلى: (${r.destLat!.toStringAsFixed(4)}, ${r.destLng!.toStringAsFixed(4)})',
                          textAlign: TextAlign.right,
                        ),
                      if (r.problem.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('الوصف: ${r.problem}', textAlign: TextAlign.right),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
