import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:auto_spare/services/user_session.dart';
import 'package:auto_spare/services/coupons_repo.dart';
import 'package:auto_spare/model/discount_coupon.dart';

class SellerCouponsScreen extends StatelessWidget {
  const SellerCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sellerId = UserSession.username ?? 'Seller';
    final df = DateFormat('yyyy-MM-dd HH:mm');

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('أكواد الخصم'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'قم بإنشاء وإدارة أكواد الخصم الخاصة بمتجرك.',
                  style: TextStyle(color: cs.outline, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openCreateCouponDialog(context, sellerId),
                  icon: const Icon(Icons.add),
                  label: const Text('إنشاء كود خصم جديد'),
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
                      return const Center(
                        child: Text(
                          'لا توجد أكواد خصم حالياً',
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
                            ? 'منتهي'
                            : (c.active ? 'مفعّل' : 'موقوف');

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
                                            'نسبة الخصم: ${c.discountPercent.toStringAsFixed(0)}٪',
                                            textAlign: TextAlign.right,
                                          ),
                                          const SizedBox(height: 2),
                                          if (c.expiresAt != null)
                                            Text(
                                              'ينتهي في: ${df.format(c.expiresAt!)}',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: cs.outline,
                                              ),
                                            )
                                          else
                                            Text(
                                              'بدون تاريخ انتهاء',
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
                                          ? 'إيقاف الكود'
                                          : 'تفعيل الكود',
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
                                      tooltip: 'حذف الكود',
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final ok = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('حذف الكود'),
                                            content: Text(
                                              'هل أنت متأكد من حذف الكود ${c.code}؟',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('إلغاء'),
                                              ),
                                              FilledButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text('حذف'),
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
  ) async {
    final formKey = GlobalKey<FormState>();
    final codeCtrl = TextEditingController();
    final percentCtrl = TextEditingController();
    final daysCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إنشاء كود خصم'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeCtrl,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'الكود (مثال: SAVE10)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'مطلوب';
                    }
                    if (v.contains(' ')) {
                      return 'الكود لا يجب أن يحتوي مسافات';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: percentCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'نسبة الخصم %',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'مطلوب';
                    }
                    final d = double.tryParse(v);
                    if (d == null || d <= 0 || d > 100) {
                      return 'أدخل نسبة بين 1 و 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: daysCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'مدة الصلاحية بالأيام (اختياري)',
                    hintText: 'اتركه فارغ بدون انتهاء',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context, true);
            },
            child: const Text('حفظ'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم إنشاء الكود $code بنجاح')));
    }
  }
}
