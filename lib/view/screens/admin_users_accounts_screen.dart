import 'package:flutter/material.dart';

import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/users_repository.dart';

class AdminUsersAccountsScreen extends StatefulWidget {
  const AdminUsersAccountsScreen({super.key});

  @override
  State<AdminUsersAccountsScreen> createState() =>
      _AdminUsersAccountsScreenState();
}

class _AdminUsersAccountsScreenState extends State<AdminUsersAccountsScreen> {
  bool _isBanned(AppUser u) {
    if (u.role == AppUserRole.admin) return false;

    return (u.approved == false && u.canSell == false);
  }

  bool _isFrozen(AppUser u) {
    return (u.approved == false && !_isBanned(u));
  }

  String _statusText(AppUser u) {
    if (_isBanned(u)) return 'محظور نهائياً';
    if (u.approved == true) return 'نشط';
    return 'مجمّد / غير مفعل';
  }

  Color _statusColor(AppUser u) {
    if (_isBanned(u)) return Colors.red;
    if (u.approved == true) return Colors.green;
    return Colors.orange;
  }

  Future<void> _toggleFreeze(AppUser u) async {
    final banned = _isBanned(u);
    final frozen = _isFrozen(u);

    AppUser updated;

    if (banned) {
      updated = u.copyWith(
        approved: true,
        canSell: true,
        canTow: u.role == AppUserRole.winch ? true : u.canTow,
      );
    } else if (frozen) {
      updated = u.copyWith(approved: true);
    } else {
      updated = u.copyWith(approved: false);
    }

    await usersRepo.updateUser(updated);
    if (mounted) setState(() {});
  }

  Future<void> _banUser(AppUser u) async {
    if (u.role == AppUserRole.admin) {
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحظر النهائي'),
        content: Text(
          'هل أنت متأكد من حظر ${u.name.isNotEmpty ? u.name : u.email} نهائياً؟\n'
          'لن يستطيع استخدام الحساب أو إنشاء حساب جديد بنفس البريد.',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد الحظر'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    AppUser updated = u.copyWith(
      approved: false,
      canSell: false,
      canTow: u.role == AppUserRole.winch ? false : u.canTow,
    );

    await usersRepo.updateUser(updated);
    if (mounted) setState(() {});
  }

  Widget _userCard(AppUser u) {
    final status = _statusText(u);
    final color = _statusColor(u);
    final banned = _isBanned(u);
    final frozen = _isFrozen(u);

    final String freezeLabel = banned
        ? 'إلغاء الحظر / تفعيل'
        : (frozen ? 'إلغاء التجميد' : 'تجميد');

    final IconData freezeIcon = banned
        ? Icons.lock_open
        : (frozen ? Icons.lock_open : Icons.pause_circle);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.name.isNotEmpty ? u.name : 'بدون اسم',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text('Email: ${u.email}', textDirection: TextDirection.ltr),
                  if (u.phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('Phone: ${u.phone}', textDirection: TextDirection.ltr),
                  ],
                  if (u.storeName != null && u.storeName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('المتجر: ${u.storeName}'),
                  ],
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(status),
                    backgroundColor: color.withOpacity(0.08),
                    labelStyle: TextStyle(color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () => _toggleFreeze(u),
                  icon: Icon(freezeIcon),
                  label: Text(freezeLabel),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () => _banUser(u),
                  icon: const Icon(Icons.block, color: Colors.red),
                  label: const Text(
                    'حظر نهائي',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = usersRepo.allUsers;

    final buyers = all.where((u) => u.role == AppUserRole.buyer).toList();

    final sellers = all.where((u) => u.role == AppUserRole.seller).toList();

    final winches = all.where((u) => u.role == AppUserRole.winch).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('حسابات المستخدمين'),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'حسابات المشترين'),
                Tab(text: 'حسابات البائعين'),
                Tab(text: 'حسابات الأوناش'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              buyers.isEmpty
                  ? const Center(child: Text('لا توجد حسابات مشترين'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: buyers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _userCard(buyers[i]),
                    ),

              sellers.isEmpty
                  ? const Center(child: Text('لا توجد حسابات بائعين'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: sellers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _userCard(sellers[i]),
                    ),

              winches.isEmpty
                  ? const Center(child: Text('لا توجد حسابات أوناش'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: winches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _userCard(winches[i]),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
