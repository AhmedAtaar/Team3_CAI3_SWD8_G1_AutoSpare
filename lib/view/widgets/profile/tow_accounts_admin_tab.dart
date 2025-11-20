// lib/view/widgets/profile/tow_accounts_admin_tab.dart
// تبويب للأدمن لإدارة حسابات الأوناش (نسخة مبسطة)

import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:flutter/material.dart';

class TowAccountsAdminTab extends StatefulWidget {
  const TowAccountsAdminTab({super.key});

  @override
  State<TowAccountsAdminTab> createState() => _TowAccountsAdminTabState();
}

class _TowAccountsAdminTabState extends State<TowAccountsAdminTab> {
  List<AppUser> _towUsers = const [];

  @override
  void initState() {
    super.initState();
    _loadTowUsers();
  }

  void _loadTowUsers() {
    // لحد ما نوصلها فعليًا بقاعدة بيانات المستخدمين
    // هنخليها فاضية عشان ما يحصلش Errors
    _towUsers = UserStore()
        .getAllUsers()
        .where((u) => u.role == AppUserRole.winch)
        .toList();
    setState(() {});
  }

  Color _statusColor(SellerStatus? s) {
    switch (s) {
      case SellerStatus.approved:
        return Colors.green;
      case SellerStatus.rejected:
        return Colors.red;
      case SellerStatus.pending:
      default:
        return Colors.orange;
    }
  }

  String _statusText(SellerStatus? s) {
    switch (s) {
      case SellerStatus.approved:
        return 'مقبول';
      case SellerStatus.rejected:
        return 'مرفوض';
      case SellerStatus.pending:
      default:
        return 'قيد المراجعة';
    }
  }

  Future<void> _editTowUser(AppUser u) async {
    final formKey = GlobalKey<FormState>();
    final capacityCtrl =
    TextEditingController(text: (u.towCapacity ?? 0).toString());
    SellerStatus status = u.sellerStatus ?? SellerStatus.pending;

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
                'الإيميل: ${u.email}\nرقم الهاتف: ${u.phone}\nالعنوان: ${u.address}',
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
                builder: (_, setS) => Column(
                  children: [
                    RadioListTile<SellerStatus>(
                      value: SellerStatus.pending,
                      groupValue: status,
                      onChanged: (v) => setS(() => status = v ?? status),
                      title: const Text('قيد المراجعة'),
                    ),
                    RadioListTile<SellerStatus>(
                      value: SellerStatus.approved,
                      groupValue: status,
                      onChanged: (v) => setS(() => status = v ?? status),
                      title: const Text('مقبول'),
                    ),
                    RadioListTile<SellerStatus>(
                      value: SellerStatus.rejected,
                      groupValue: status,
                      onChanged: (v) => setS(() => status = v ?? status),
                      title: const Text('مرفوض'),
                    ),
                  ],
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
                  if (status != SellerStatus.approved) return null;
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'أدخل رقم صحيح (> 0)';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'لو الحساب مقبول وعدد الأوناش = 0، مش هيقدر يسجل دخول كـ ونش.',
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
      final n = int.tryParse(capacityCtrl.text.trim()) ?? (u.towCapacity ?? 0);
      UserStore().updateTowAccount(
        userId: u.id,
        sellerStatus: status,
        towCapacity: n,
      );
      _loadTowUsers();
      if (!mounted) return;
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
    if (_towUsers.isEmpty) {
      return const Center(
        child: Text('لا توجد حسابات أوناش مسجّلة حاليًا'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _towUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final u = _towUsers[i];
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
                Text('الحالة: ${_statusText(u.sellerStatus)}'),
                Text('عدد الأوناش: ${u.towCapacity ?? 0}'),
                if (u.commercialRegUrl != null)
                  Text('سجل تجاري: ${u.commercialRegUrl}',
                      style: const TextStyle(fontSize: 11)),
                if (u.taxCardUrl != null)
                  Text('بطاقة ضريبية: ${u.taxCardUrl}',
                      style: const TextStyle(fontSize: 11)),
                if (u.towLicenseUrl != null)
                  Text('رخصة الونش: ${u.towLicenseUrl}',
                      style: const TextStyle(fontSize: 11)),
                if (u.towDriverIdUrl != null)
                  Text('هوية السائق: ${u.towDriverIdUrl}',
                      style: const TextStyle(fontSize: 11)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editTowUser(u),
              tooltip: 'تعديل',
            ),
          ),
        );
      },
    );
  }
}
