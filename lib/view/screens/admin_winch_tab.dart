import 'package:flutter/material.dart';

import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class AdminWinchTab extends StatelessWidget {
  const AdminWinchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: StreamBuilder<List<AppUser>>(
        stream: usersRepo.watchWinchUsers(),
        builder: (_, snap) {
          final list = snap.data ?? const <AppUser>[];

          if (list.isEmpty) {
            return Center(
              child: Text(
                loc.adminWinchAccountsEmpty,
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final u = list[i];

              final docs = u.docUrls ?? const <String>[];

              final statusText = u.approved
                  ? loc.adminWinchTabStatusApproved
                  : loc.adminWinchTabStatusPending;

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
                        '${loc.adminWinchTabWinchTitlePrefix} ${u.name} (${u.id})',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.adminWinchAccountsPhonePrefix} ${u.phone}',
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.adminWinchTabStatusPrefix} $statusText',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: u.approved ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.adminWinchTabMaxWinchesPrefix} ${u.maxWinches}',
                        textAlign: TextAlign.right,
                      ),

                      if (docs.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          loc.adminWinchTabDocsTitle,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        for (final d in docs)
                          Text(
                            d,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                      ],

                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PopupMenuButton<String>(
                          tooltip: loc.adminWinchTabMenuTooltip,
                          onSelected: (val) async {
                            if (val == 'approve') {
                              final capacity = await _askCapacity(
                                context,
                                u.maxWinches,
                              );
                              if (capacity != null) {
                                await usersRepo.updateWinch(
                                  u.id,
                                  approved: true,
                                  maxWinches: capacity,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        loc.adminWinchTabApproveSuccess(
                                          capacity,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'approve',
                              child: Text(loc.adminWinchTabMenuApproveLabel),
                            ),
                          ],
                          child: const Icon(Icons.more_vert),
                        ),
                      ),
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

Future<int?> _askCapacity(BuildContext context, int current) async {
  final loc = AppLocalizations.of(context);
  final ctrl = TextEditingController(text: current > 0 ? '$current' : '1');

  return showDialog<int>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(loc.adminWinchTabCapacityDialogTitle),
      content: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: loc.adminWinchTabCapacityFieldLabel,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            final n = int.tryParse(ctrl.text.trim());
            if (n == null || n <= 0) {
              return;
            }
            Navigator.pop(context, n);
          },
          child: Text(loc.adminWinchTabDialogSave),
        ),
      ],
    ),
  );
}
