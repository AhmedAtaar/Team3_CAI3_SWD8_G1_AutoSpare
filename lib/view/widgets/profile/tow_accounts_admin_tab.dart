import 'package:auto_spare/model/app_user.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
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
    if (!approved) return 'admin.pending_review'.tr();
    if (maxWinches <= 0) return 'admin.approved_no_active_winches'.tr();
    return 'admin.approved'.tr();
  }

  Future<void> _editTowUser(BuildContext context, AppUser u) async {
    final formKey = GlobalKey<FormState>();
    final capacityCtrl = TextEditingController(text: u.maxWinches.toString());
    bool approved = u.approved;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: Text('admin.manage_winch_account'.tr(args: [u.name])),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'admin.user_details'.tr(
                      args: [u.email, u.phone, u.address],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'admin.account_status'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  StatefulBuilder(
                    builder: (_, setS) => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: approved,
                      onChanged: (v) => setS(() => approved = v),
                      title: Text('admin.allow_winch_work'.tr()),
                      subtitle: Text(
                        'admin.switch_explanation'.tr(),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: capacityCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'admin.available_winches_count'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (!approved) return null;
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null || n <= 0)
                        return 'admin.enter_valid_number'.tr();
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'admin.zero_winches_warning'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('admin.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: Text('admin.save'.tr()),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final n = int.tryParse(capacityCtrl.text.trim()) ?? u.maxWinches;

      await usersRepo.updateWinch(u.id, approved: approved, maxWinches: n);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'admin.winch_account_updated'.tr(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Directionality handled by EasyLocalization
    return StreamBuilder<List<AppUser>>(
      stream: usersRepo.watchWinchUsers(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final base = snap.data ?? const <AppUser>[];
        final towUsers = List<AppUser>.from(base)
          ..sort((a, b) => a.name.compareTo(b.name));

        if (towUsers.isEmpty) {
          return Center(child: Text('admin.no_winch_accounts'.tr()));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: towUsers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final u = towUsers[i];
            final max = u.maxWinches;
            final statusText = _statusText(u.approved, max);
            final statusColor = _statusColor(u.approved, max);

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryGreenShade100,
                  child: const Icon(Icons.local_shipping_outlined),
                ),
                title: Text(
                  u.name,
                ), // Name usually doesn't need translation if it's user input
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'admin.user_details'
                          .tr(args: [u.email, '', ''])
                          .split('\n')[0],
                    ), // Hacky reuse or create new key? Better create new key or reuse properly.
                    // Let's stick to the extracted keys.
                    // Actually, the original code had: Text('الإيميل: ${u.email}'),
                    // My extracted key: "user_details": "الإيميل: {}\nرقم الهاتف: {}\nالعنوان: {}",
                    // I should probably split this key or use a new one for list item.
                    // For now, I will use simple string interpolation with tr for labels if I had them, but here I have full strings.
                    // I will create new keys for these list items to be cleaner.
                    // "email_label": "Email: {}", "company_label": "Company: {}", etc.
                    // I already added "company_name": "Company: {}"
                    // I need "email_label": "Email: {}"
                    // I'll add them to JSON in next step if needed, or just use what I have.
                    // "user_details" is complex.
                    // Let's use: Text('admin.user_details'.tr(args: [u.email, u.phone, u.address ?? '-'])),
                    // But wait, the list item shows different things.
                    // Original:
                    // Text('الإيميل: ${u.email}'),
                    // if (u.storeName != null) Text('الشركة: ${u.storeName}'),
                    // Text('الحالة: $statusText', ...),
                    // Text('عدد الأوناش: $max'),
                    // ...

                    // I will use the keys I created:
                    // "company_name": "Company: {}",
                    // "status_label": "Status: {}",
                    // "winches_count": "Winches Count: {}",
                    // "commercial_reg": "Commercial Reg: {}",
                    // "tax_card": "Tax Card: {}",
                    // "winch_license": "Winch License: {}",
                    // "driver_id": "Driver ID: {}",

                    // I missed "email_label". I'll add it or just hardcode "Email: " + email for now? No, user wants translation.
                    // I'll add "email_label": "Email: {}" to the JSONs in a separate call or just use a generic one.
                    // Actually I can just use "login.email" + ": ${u.email}"?
                    // "login.email" is "Email".
                    Text('${'admin.email_label'.tr(args: [u.email])}'),
                    if (u.storeName != null)
                      Text('admin.company_name'.tr(args: [u.storeName!])),
                    Text(
                      'admin.status_label'.tr(args: [statusText]),
                      style: TextStyle(color: statusColor),
                    ),
                    Text('admin.winches_count'.tr(args: [max.toString()])),
                    if (u.commercialRegUrl != null &&
                        u.commercialRegUrl!.isNotEmpty)
                      Text(
                        'admin.commercial_reg'.tr(args: [u.commercialRegUrl!]),
                        style: const TextStyle(fontSize: 11),
                      ),
                    if (u.taxCardUrl != null && u.taxCardUrl!.isNotEmpty)
                      Text(
                        'admin.tax_card'.tr(args: [u.taxCardUrl!]),
                        style: const TextStyle(fontSize: 11),
                      ),
                    if (u.towLicenseUrl != null && u.towLicenseUrl!.isNotEmpty)
                      Text(
                        'admin.winch_license'.tr(args: [u.towLicenseUrl!]),
                        style: const TextStyle(fontSize: 11),
                      ),
                    if (u.towDriverIdUrl != null &&
                        u.towDriverIdUrl!.isNotEmpty)
                      Text(
                        'admin.driver_id'.tr(args: [u.towDriverIdUrl!]),
                        style: const TextStyle(fontSize: 11),
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTowUser(context, u),
                  tooltip: 'admin.edit'.tr(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
