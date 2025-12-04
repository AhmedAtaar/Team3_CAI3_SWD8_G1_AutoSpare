import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:auto_spare/services/user_session.dart';
import 'package:auto_spare/services/coupons_repo.dart';
import 'package:auto_spare/model/discount_coupon.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class SellerCouponsScreen extends StatelessWidget {
  const SellerCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final sellerId = UserSession.username ?? 'Seller';
    final df = DateFormat('yyyy-MM-dd HH:mm');

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.seller_coupons_title),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  loc.seller_coupons_help_text,
                  style: TextStyle(color: cs.outline, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      _openCreateCouponDialog(context, sellerId, loc),
                  icon: const Icon(Icons.add),
                  label: Text(loc.seller_coupons_create_button),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<List<DiscountCoupon>>(
                  stream: couponsRepo.watchSellerCoupons(sellerId),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting &&
                        !snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final list = snap.data ?? const <DiscountCoupon>[];
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          loc.seller_coupons_empty_message,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final c = list[i];
                        final isExpired = c.isExpired;
                        final isActive = c.active && !isExpired;
                        final statusText = isExpired
                            ? loc.seller_coupons_status_expired
                            : (c.active
                                  ? loc.seller_coupons_status_active
                                  : loc.seller_coupons_status_inactive);

                        final statusColor = isActive
                            ? Colors.green.withOpacity(.12)
                            : Colors.grey.withOpacity(.12);

                        final statusTextColor = isActive
                            ? Colors.green[800]
                            : Colors.grey[800];

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            c.code,
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${loc.seller_coupons_discount_percent_prefix} '
                                            '${c.discountPercent.toStringAsFixed(0)}٪',
                                            textAlign: TextAlign.right,
                                          ),
                                          const SizedBox(height: 2),
                                          if (c.expiresAt != null)
                                            Text(
                                              '${loc.seller_coupons_expires_at_prefix} '
                                              '${df.format(c.expiresAt!)}',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: cs.outline,
                                              ),
                                            )
                                          else
                                            Text(
                                              loc.seller_coupons_no_expiry,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: cs.outline,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Chip(
                                      label: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusTextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: statusColor,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),
                                const Divider(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      tooltip: c.active
                                          ? loc.seller_coupons_toggle_tooltip_deactivate
                                          : loc.seller_coupons_toggle_tooltip_activate,
                                      icon: Icon(
                                        c.active
                                            ? Icons.pause_circle_outline
                                            : Icons.play_circle_outline,
                                        color: c.active
                                            ? Colors.orange
                                            : Colors.green,
                                      ),
                                      onPressed: () async {
                                        await couponsRepo.setActive(
                                          c.id,
                                          !c.active,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      tooltip:
                                          loc.seller_coupons_delete_tooltip,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final ok = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text(
                                              loc.seller_coupons_delete_dialog_title,
                                            ),
                                            content: Text(
                                              '${loc.seller_coupons_delete_dialog_message_prefix} ${c.code}؟',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: Text(
                                                  loc.seller_coupons_delete_dialog_cancel_button,
                                                ),
                                              ),
                                              FilledButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: Text(
                                                  loc.seller_coupons_delete_dialog_confirm_button,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (ok == true) {
                                          await couponsRepo.deleteCoupon(c.id);
                                        }
                                      },
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateCouponDialog(
    BuildContext context,
    String sellerId,
    AppLocalizations loc,
  ) async {
    final formKey = GlobalKey<FormState>();
    final codeCtrl = TextEditingController();
    final percentCtrl = TextEditingController();
    final daysCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.seller_coupons_create_dialog_title),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeCtrl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: loc.seller_coupons_code_label,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return loc.seller_coupons_code_required_error;
                    }
                    if (v.contains(' ')) {
                      return loc.seller_coupons_code_no_spaces_error;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: percentCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: loc.seller_coupons_percent_label,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return loc.seller_coupons_percent_required_error;
                    }
                    final d = double.tryParse(v);
                    if (d == null || d <= 0 || d > 100) {
                      return loc.seller_coupons_percent_invalid_error;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: daysCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: loc.seller_coupons_days_label,
                    hintText: loc.seller_coupons_days_hint,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.seller_coupons_form_cancel_button),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context, true);
            },
            child: Text(loc.seller_coupons_form_save_button),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final code = codeCtrl.text.trim().toUpperCase();
    final percent = double.parse(percentCtrl.text.trim());
    DateTime? expiresAt;
    if (daysCtrl.text.trim().isNotEmpty) {
      final days = int.tryParse(daysCtrl.text.trim());
      if (days != null && days > 0) {
        expiresAt = DateTime.now().add(Duration(days: days));
      }
    }

    await couponsRepo.createCoupon(
      code: code,
      sellerId: sellerId,
      discountPercent: percent,
      expiresAt: expiresAt,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.seller_coupons_created_snackbar_prefix} $code'),
        ),
      );
    }
  }
}
