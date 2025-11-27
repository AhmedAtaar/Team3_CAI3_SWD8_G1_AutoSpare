import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:flutter/material.dart';

class TowAccountsAdminTab extends StatelessWidget {
  const TowAccountsAdminTab({super.key});

  Color _statusColor(bool approved, int maxWinches) {
    if (!approved) return Colors.orange;
    if (maxWinches <= 0) return Colors.redAccent;
    return Colors.green;
  }

  String _statusText(bool approved, int maxWinches) {
    if (!approved) return 'قيد المراجعة';
    if (maxWinches <= 0) return 'مقبول (لا توجد أوناش فعّالة حالياً)';
    return 'مقبول';
  }

  Future<void> _editTowUser(BuildContext context, AppUser u) async {
    final formKey = GlobalKey<FormState>();
    final capacityCtrl = TextEditingController(
      text: (u.maxWinches ?? 0).toString(),
    );
    bool approved = u.approved;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('إدارة حساب الونش — ${u.name}', textAlign: TextAlign.right),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'الإيميل: ${u.email}\nرقم الهاتف: ${u.phone}\nالعنوان: ${u.address ?? '-'}',
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'حالة الحساب',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              StatefulBuilder(
                builder: (_, setS) => SwitchListTile(
                  value: approved,
                  onChanged: (v) => setS(() => approved = v),
                  title: const Text('السماح بالعمل كـ ونش (مقبول)'),
                  subtitle: const Text(
                    'إغلاق السويتش = الحساب ينتقل لوضع قيد المراجعة / موقوف.',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد الأوناش المتاحة في الخدمة',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (!approved) return null;
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'أدخل رقم صحيح (> 0)';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'لو الحساب مقبول وعدد الأوناش = 0، مش هيقدر يفعّل أي ونش.',
                style: TextStyle(fontSize: 11, color: Colors.redAccent),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final n = int.tryParse(capacityCtrl.text.trim()) ?? (u.maxWinches ?? 0);

      await usersRepo.updateWinch(u.id, approved: approved, maxWinches: n);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تحديث حساب الونش بنجاح',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: StreamBuilder<List<AppUser>>(
        stream: usersRepo.watchWinchUsers(),
        builder: (context, snap) {
          final towUsers = snap.data ?? const <AppUser>[];

          if (towUsers.isEmpty) {
            return const Center(
              child: Text('لا توجد حسابات أوناش مسجّلة حاليًا'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: towUsers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final u = towUsers[i];
              final max = u.maxWinches ?? 0;
              final statusText = _statusText(u.approved, max);
              final statusColor = _statusColor(u.approved, max);

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGreenShade100,
                    child: const Icon(Icons.local_shipping_outlined),
                  ),
                  title: Text(u.name, textAlign: TextAlign.right),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الإيميل: ${u.email}'),
                      if (u.storeName != null) Text('الشركة: ${u.storeName}'),
                      Text(
                        'الحالة: $statusText',
                        style: TextStyle(color: statusColor),
                      ),
                      Text('عدد الأوناش: $max'),
                      if (u.commercialRegUrl != null &&
                          u.commercialRegUrl!.isNotEmpty)
                        Text(
                          'سجل تجاري: ${u.commercialRegUrl}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      if (u.taxCardUrl != null && u.taxCardUrl!.isNotEmpty)
                        Text(
                          'بطاقة ضريبية: ${u.taxCardUrl}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      if (u.towLicenseUrl != null &&
                          u.towLicenseUrl!.isNotEmpty)
                        Text(
                          'رخصة الونش: ${u.towLicenseUrl}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      if (u.towDriverIdUrl != null &&
                          u.towDriverIdUrl!.isNotEmpty)
                        Text(
                          'هوية السائق: ${u.towDriverIdUrl}',
                          style: const TextStyle(fontSize: 11),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editTowUser(context, u),
                    tooltip: 'تعديل',
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
