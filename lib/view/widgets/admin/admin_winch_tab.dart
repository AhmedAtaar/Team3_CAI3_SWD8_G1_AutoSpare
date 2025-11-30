import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminWinchAccountsTab extends StatelessWidget {
  const AdminWinchAccountsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final col = FirebaseFirestore.instance.collection('tow_companies');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: col.orderBy('name').snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: Text(
                  'خطأ في تحميل حسابات الأوناش:\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snap.data?.docs ?? const [];

            if (docs.isEmpty) {
              return const Center(
                child: Text('لا توجد حسابات أوناش مسجلة حتى الآن'),
              );
            }

            return ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final doc = docs[i];
                final data = doc.data();

                final name = (data['name'] ?? 'بدون اسم') as String;
                final area = (data['area'] ?? 'بدون منطقة') as String;
                final phone = (data['phone'] ?? '') as String;
                final baseCost = (data['baseCost'] as num?)?.toDouble() ?? 0.0;
                final pricePerKm =
                    (data['pricePerKm'] as num?)?.toDouble() ?? 0.0;
                final isOnline = (data['isOnline'] as bool?) ?? false;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
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
                            const Icon(Icons.local_shipping_outlined),
                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                name,
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            SizedBox(
                              width: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isOnline ? 'مُفعّل' : 'مُعطّل',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isOnline
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  Switch(
                                    value: isOnline,
                                    onChanged: (value) async {
                                      await col.doc(doc.id).update({
                                        'isOnline': value,
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('حذف حساب الونش'),
                                      content: Text(
                                        'هل أنت متأكد من حذف حساب "$name" نهائيًا؟',
                                        textAlign: TextAlign.right,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('إلغاء'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('تأكيد الحذف'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (ok == true) {
                                    await col.doc(doc.id).delete();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'تم حذف حساب $name',
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('حذف الحساب'),
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'المنطقة: $area',
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'سعر الخدمة الأساسية: ${baseCost.toStringAsFixed(0)} جنيه',
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          'سعر الكيلو: ${pricePerKm.toStringAsFixed(0)} جنيه/كم',
                          textAlign: TextAlign.right,
                        ),
                        if (phone.isNotEmpty)
                          Text(
                            'رقم الهاتف: $phone',
                            textAlign: TextAlign.right,
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
