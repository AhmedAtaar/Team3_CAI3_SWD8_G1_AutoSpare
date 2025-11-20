// lib/view/widgets/admin/admin_winch_tab.dart
//
// تبويب للأدمن لمراجعة حسابات الأوناش:
// - يشوف كل حسابات الـ UserType.winch
// - يطّلع على المستندات (docUrls)
// - يحدد عدد الأوناش maxWinches
// - يوافق على الحساب (approved = true)

import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:flutter/material.dart';

class AdminWinchTab extends StatelessWidget {
  const AdminWinchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: StreamBuilder<List<AppUser>>(
        stream: usersRepo.watchWinchUsers(),
        builder: (_, snap) {
          final list = snap.data ?? const <AppUser>[];

          if (list.isEmpty) {
            return const Center(
              child: Text('لا توجد حسابات أوناش مسجلة حتى الآن'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final u = list[i];
              // ✅ علشان ما نشتغلش على null
              final docs = u.docUrls ?? const <String>[];

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
                        'الونش: ${u.name} (${u.id})',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('الهاتف: ${u.phone}', textAlign: TextAlign.right),
                      const SizedBox(height: 4),
                      Text(
                        'الحالة: ${u.approved ? 'مقبول' : 'في انتظار المراجعة'}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: u.approved ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'عدد الأوناش المسموح: ${u.maxWinches}',
                        textAlign: TextAlign.right,
                      ),

                      // ✅ التعامل مع docUrls لو كانت null
                      if (docs.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'المستندات:',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                          tooltip: 'إجراءات',
                          onSelected: (val) async {
                            if (val == 'approve') {
                              final capacity =
                              await _askCapacity(context, u.maxWinches);
                              if (capacity != null) {
                                // ✅ استدعاء الميثود اللي هنضيفها في UsersRepository
                                await usersRepo.updateWinch(
                                  u.id,
                                  approved: true,
                                  maxWinches: capacity,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم قبول حساب الونش وتحديد عدد الأوناش = $capacity',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'approve',
                              child: Text('قبول وتحديد عدد الأوناش'),
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
  final ctrl = TextEditingController(text: current > 0 ? '$current' : '1');

  return showDialog<int>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('حدد عدد الأوناش في الخدمة'),
      content: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'عدد الأوناش',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            final n = int.tryParse(ctrl.text.trim());
            if (n == null || n <= 0) {
              return;
            }
            Navigator.pop(context, n);
          },
          child: const Text('حفظ'),
        ),
      ],
    ),
  );
}
