import 'dart:ui' as ui;
import 'package:auto_spare/services/tow_requests.dart';
import 'package:flutter/material.dart';
import 'package:auto_spare/l10n/app_localizations.dart';
import 'package:auto_spare/core/tow_status_localized.dart';

class AdminTowRequestsTab extends StatelessWidget {
  const AdminTowRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: StreamBuilder<List<TowRequestDoc>>(
        stream: towRequestsRepo.watchAllAdmin(),
        builder: (_, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                '${loc.adminTowRequestsErrorLoading}\n${snap.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final list = snap.data ?? const <TowRequestDoc>[];

          if (snap.connectionState == ConnectionState.waiting && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (list.isEmpty) {
            return Center(child: Text(loc.adminTowRequestsEmpty));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final r = list[i];
              final statusColor = r.status == TowRequestStatus.completed
                  ? Colors.green
                  : (r.status == TowRequestStatus.cancelled
                        ? Colors.red
                        : Colors.orange);

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
                        '${loc.adminTowRequestsItemTitlePrefix} #${r.id}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.adminTowRequestsCompanyPrefix} '
                        '${r.companyNameSnapshot} (${r.companyId})',
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.adminTowRequestsStatusPrefix} '
                        '${towStatusText(context, r.status)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.adminTowRequestsVehiclePlatePrefix} '
                        '${r.vehicle} • ${r.plate}',
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.adminTowRequestsPhonePrefix} ${r.contactPhone}',
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.adminTowRequestsTotalCostPrefix} '
                        '${r.totalCost.toStringAsFixed(0)} '
                        '${loc.currencyEgp}',
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.adminTowRequestsFromPrefix} '
                        '(${r.fromLat.toStringAsFixed(4)}, ${r.fromLng.toStringAsFixed(4)})',
                        textAlign: TextAlign.right,
                      ),
                      if (r.destLat != null && r.destLng != null)
                        Text(
                          '${loc.adminTowRequestsToPrefix} '
                          '(${r.destLat!.toStringAsFixed(4)}, ${r.destLng!.toStringAsFixed(4)})',
                          textAlign: TextAlign.right,
                        ),
                      if (r.problem.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${loc.adminTowRequestsProblemPrefix} ${r.problem}',
                          textAlign: TextAlign.right,
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
    );
  }
}
