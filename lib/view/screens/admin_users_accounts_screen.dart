import 'package:flutter/material.dart';

import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

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

  String _statusText(AppUser u, AppLocalizations loc) {
    if (_isBanned(u)) return loc.admin_users_status_banned;
    if (u.approved == true) return loc.admin_users_status_active;
    return loc.admin_users_status_frozen;
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
    if (u.role == AppUserRole.admin) return;

    final loc = AppLocalizations.of(context);
    final displayName = u.name.isNotEmpty ? u.name : u.email;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.admin_users_permanent_ban_dialog_title),
        content: Text(
          '${loc.admin_users_permanent_ban_dialog_body_prefix} '
          '$displayName '
          '${loc.admin_users_permanent_ban_dialog_body_suffix}',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.admin_common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.admin_users_permanent_ban_confirm),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final updated = u.copyWith(
      approved: false,
      canSell: false,
      canTow: u.role == AppUserRole.winch ? false : u.canTow,
    );

    await usersRepo.updateUser(updated);
    if (mounted) setState(() {});
  }

  Widget _userCard(AppUser u) {
    final loc = AppLocalizations.of(context);
    final status = _statusText(u, loc);
    final color = _statusColor(u);
    final banned = _isBanned(u);
    final frozen = _isFrozen(u);

    final String freezeLabel = banned
        ? loc.admin_users_unban_and_activate
        : (frozen ? loc.admin_users_unfreeze : loc.admin_users_freeze);

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
                    u.name.isNotEmpty ? u.name : loc.admin_users_no_name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loc.admin_users_email_label}: ${u.email}',
                    textDirection: TextDirection.ltr,
                  ),
                  if (u.phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${loc.admin_users_phone_label}: ${u.phone}',
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                  if (u.storeName != null && u.storeName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('${loc.admin_users_store_label} ${u.storeName}'),
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
                  label: Text(
                    loc.admin_users_permanent_ban_button,
                    style: const TextStyle(color: Colors.red),
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

    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(loc.admin_users_title),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: loc.admin_users_tab_buyers),
                Tab(text: loc.admin_users_tab_sellers),
                Tab(text: loc.admin_users_tab_winches),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              buyers.isEmpty
                  ? Center(child: Text(loc.admin_users_no_buyer_accounts))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: buyers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _userCard(buyers[i]),
                    ),
              sellers.isEmpty
                  ? Center(child: Text(loc.admin_users_no_seller_accounts))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: sellers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _userCard(sellers[i]),
                    ),
              winches.isEmpty
                  ? Center(child: Text(loc.admin_users_no_winch_accounts))
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
