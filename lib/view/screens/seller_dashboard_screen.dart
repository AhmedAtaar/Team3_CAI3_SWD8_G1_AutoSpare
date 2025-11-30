import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/services/user_session.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  DateTimeRange? _range;

  String _fmtMoney(double v) {
    final f = NumberFormat('#,##0.00', 'en');
    return '${f.format(v)} ج';
  }

  String _fmtRange(DateTimeRange? r) {
    if (r == null) return 'كل الوقت';
    final df = DateFormat('yyyy/MM/dd');
    return 'من ${df.format(r.start)} إلى ${df.format(r.end)}';
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final initial =
        _range ??
        DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial,
      helpText: 'اختر الفترة لعرض أرباحك',
      cancelText: 'إلغاء',
      confirmText: 'تم',
    );

    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  void _clearRange() {
    setState(() => _range = null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sellerId = UserSession.username ?? '';

    if (sellerId.isEmpty) {
      return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('لوحة تحكم البائع'),
            centerTitle: true,
          ),
          body: const Center(
            child: Text(
              'لا يمكن تحديد هوية البائع لهذا الحساب',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text('لوحة تحكم البائع'),
        ),
        body: StreamBuilder<List<OrderDoc>>(
          stream: ordersRepo.watchSellerOrders(sellerId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return const Center(
                child: Text(
                  'حدث خطأ أثناء تحميل الطلبات',
                  textAlign: TextAlign.center,
                ),
              );
            }

            final allOrders = snap.data ?? const <OrderDoc>[];

            final delivered = allOrders
                .where((o) => o.status == OrderStatus.delivered)
                .toList();

            if (delivered.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد طلبات مكتملة حتى الآن',
                  textAlign: TextAlign.center,
                ),
              );
            }

            double sellerItemsTotal(OrderDoc o) {
              return o.items
                  .where((it) => it.sellerId == sellerId)
                  .fold(0.0, (p, it) => p + it.price * it.qty);
            }

            int sellerItemsQty(OrderDoc o) {
              return o.items
                  .where((it) => it.sellerId == sellerId)
                  .fold(0, (p, it) => p + it.qty);
            }

            double sellerDiscountShare(OrderDoc o) {
              if (o.discount <= 0) return 0.0;
              final sellerTotal = sellerItemsTotal(o);
              if (sellerTotal <= 0) return 0.0;
              final allItemsTotal = o.itemsTotal <= 0
                  ? sellerTotal
                  : o.itemsTotal;
              if (allItemsTotal <= 0) return 0.0;
              final ratio = sellerTotal / allItemsTotal;
              return o.discount * ratio;
            }

            double sellerNetForOrder(OrderDoc o) {
              final baseTotal = sellerItemsTotal(o);
              final discountShare = sellerDiscountShare(o);
              return baseTotal - discountShare;
            }

            final totalNetAll = delivered.fold<double>(
              0.0,
              (sum, o) => sum + sellerNetForOrder(o),
            );

            List<OrderDoc> periodOrders = delivered;
            if (_range != null) {
              periodOrders = delivered.where((o) {
                final d = o.stamps.deliveredAt;
                if (d == null) return false;
                return !d.isBefore(_range!.start) && !d.isAfter(_range!.end);
              }).toList();
            }

            if (periodOrders.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SellerHeader(
                      totalNetAll: totalNetAll,
                      currentRangeText: _fmtRange(_range),
                      onPickRange: _pickRange,
                      onClearRange: _clearRange,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Center(
                        child: Text(
                          'لا توجد طلبات في الفترة المختارة.\nحاول تغيير فترة التاريخ.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final totalOrders = periodOrders.length;
            final totalQty = periodOrders.fold<int>(
              0,
              (sum, o) => sum + sellerItemsQty(o),
            );
            final totalBaseAmount = periodOrders.fold<double>(
              0.0,
              (sum, o) => sum + sellerItemsTotal(o),
            );
            final totalDiscount = periodOrders.fold<double>(
              0.0,
              (sum, o) => sum + sellerDiscountShare(o),
            );
            final totalNet = periodOrders.fold<double>(
              0.0,
              (sum, o) => sum + sellerNetForOrder(o),
            );

            final Map<String, double> couponDiscounts = {};
            for (final o in periodOrders) {
              final code = o.couponCode;
              if (code == null || code.trim().isEmpty) continue;
              final share = sellerDiscountShare(o);
              if (share <= 0) continue;
              final key = code.toUpperCase();
              couponDiscounts[key] = (couponDiscounts[key] ?? 0.0) + share;
            }

            final Map<DateTime, double> dailyNetMap = {};
            for (final o in periodOrders) {
              final d = o.stamps.deliveredAt;
              if (d == null) continue;
              final dayKey = DateTime(d.year, d.month, d.day);
              dailyNetMap[dayKey] =
                  (dailyNetMap[dayKey] ?? 0.0) + sellerNetForOrder(o);
            }
            final sortedDays = dailyNetMap.keys.toList()..sort();
            final dailyValues = sortedDays
                .map((d) => dailyNetMap[d] ?? 0.0)
                .toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth() {
                  final w = constraints.maxWidth;
                  if (w >= 1000) return (w - 48) / 3;
                  if (w >= 650) return (w - 32) / 2;
                  return w;
                }

                final cw = cardWidth();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SellerHeader(
                        totalNetAll: totalNetAll,
                        currentRangeText: _fmtRange(_range),
                        onPickRange: _pickRange,
                        onClearRange: _clearRange,
                      ),

                      const SizedBox(height: 20),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.end,
                        children: [
                          SizedBox(
                            width: cw,
                            child: _SellerStatCard(
                              title: 'عدد الطلبات المكتملة (في الفترة)',
                              value: '$totalOrders طلب',
                              icon: Icons.shopping_bag_outlined,
                              iconColor: cs.primary,
                            ),
                          ),
                          SizedBox(
                            width: cw,
                            child: _SellerStatCard(
                              title: 'إجمالي القطع المباعة',
                              value: '$totalQty قطعة',
                              icon: Icons.inventory_2_outlined,
                              iconColor: Colors.blue,
                            ),
                          ),
                          SizedBox(
                            width: cw,
                            child: _SellerStatCard(
                              title: 'قيمة المنتجات (قبل الخصم)',
                              value: _fmtMoney(totalBaseAmount),
                              subtitle: 'حسب السعر الذي أدخلته في المنتجات فقط',
                              icon: Icons.attach_money_outlined,
                              iconColor: Colors.teal,
                            ),
                          ),
                          SizedBox(
                            width: cw,
                            child: _SellerStatCard(
                              title: 'إجمالي الخصومات على منتجاتك',
                              value: _fmtMoney(totalDiscount),
                              subtitle: 'تشمل الخصومات والكوبونات في الفترة',
                              icon: Icons.local_offer_outlined,
                              iconColor: Colors.pink,
                            ),
                          ),
                          SizedBox(
                            width: cw,
                            child: _SellerStatCard(
                              title: 'صافي أرباحك بعد الخصم (في الفترة)',
                              value: _fmtMoney(totalNet),
                              subtitle:
                                  'لا يشمل عمولة التطبيق ٥٪ (هذه محسوبة على المشتري)',
                              icon: Icons.trending_up_outlined,
                              iconColor: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'توزيع صافي أرباحك حسب الأيام',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),
                      _SellerEarningsBarChart(
                        values: dailyValues,
                        days: sortedDays,
                        moneyFormatter: _fmtMoney,
                      ),

                      const SizedBox(height: 24),

                      if (couponDiscounts.isNotEmpty) ...[
                        Text(
                          'تأثير أكواد الخصم على أرباحك (في الفترة)',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: cs.outlineVariant.withOpacity(.4),
                              width: 0.6,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'إجمالي الخصم الناتج عن الكوبونات على منتجاتك في الفترة المحددة:',
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _fmtMoney(
                                    couponDiscounts.values.fold(
                                      0.0,
                                      (p, v) => p + v,
                                    ),
                                  ),
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.end,
                                  children: couponDiscounts.entries
                                      .map(
                                        (e) => Chip(
                                          label: Text(
                                            'كوبون ${e.key} – خصم ${_fmtMoney(e.value)}',
                                            textAlign: TextAlign.right,
                                          ),
                                          backgroundColor: cs.primary
                                              .withOpacity(.06),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: cs.outlineVariant.withOpacity(.4),
                              width: 0.6,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'لم يتم استخدام أي أكواد خصم على منتجاتك في الفترة المحددة.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'آخر تحديث: ${DateFormat('yyyy/MM/dd – HH:mm').format(DateTime.now())}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: cs.outline),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
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

class _SellerHeader extends StatelessWidget {
  final double totalNetAll;
  final String currentRangeText;
  final VoidCallback onPickRange;
  final VoidCallback onClearRange;

  const _SellerHeader({
    required this.totalNetAll,
    required this.currentRangeText,
    required this.onPickRange,
    required this.onClearRange,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [cs.primary.withOpacity(.14), cs.primary.withOpacity(.03)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ملخص أرباح متجرك',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'كل الأرقام في الأسفل محسوبة على أساس السعر الأصلي الذي تقوم بإدخاله في المنتجات قبل زيادة عمولة التطبيق ٥٪.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'صافي أرباحك (كل الوقت)',
                      style: TextStyle(fontSize: 11),
                    ),
                    Text(
                      NumberFormat('#,##0.00', 'en').format(totalNetAll) + ' ج',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  currentRangeText,
                  textAlign: TextAlign.right,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onPickRange,
                icon: const Icon(Icons.date_range),
                label: const Text('تغيير الفترة'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onClearRange,
                child: const Text('كل الوقت'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SellerStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final bool dense;

  const _SellerStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.subtitle,
    this.dense = false,
  });

  const _SellerStatCard.small({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.subtitle,
  }) : dense = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.4), width: 0.6),
      ),
      child: Padding(
        padding: EdgeInsets.all(dense ? 10 : 14),
        child: Row(
          crossAxisAlignment: dense
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Container(
              width: dense ? 34 : 40,
              height: dense ? 34 : 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: dense ? 20 : 24, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: dense ? 16 : 18,
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.right,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: cs.outline),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerEarningsBarChart extends StatelessWidget {
  final List<double> values;
  final List<DateTime> days;
  final String Function(double) moneyFormatter;

  const _SellerEarningsBarChart({
    required this.values,
    required this.days,
    required this.moneyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (values.isEmpty || values.every((v) => v == 0.0)) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: cs.outlineVariant.withOpacity(.4),
            width: 0.6,
          ),
        ),
        child: const SizedBox(
          height: 160,
          child: Center(
            child: Text('لا توجد بيانات كافية للرسم في الفترة المحددة'),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.4), width: 0.6),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'صافي أرباحك موزعة على الأيام',
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 190,
              child: CustomPaint(
                painter: _SellerBarChartPainter(
                  values: values,
                  barColor: cs.primary,
                  axisColor: cs.outlineVariant.withOpacity(.7),
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (days.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM').format(days.first),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.outline),
                  ),
                  if (days.length > 1)
                    Text(
                      DateFormat('dd/MM').format(days.last),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: cs.outline),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SellerBarChartPainter extends CustomPainter {
  final List<double> values;
  final Color barColor;
  final Color axisColor;

  _SellerBarChartPainter({
    required this.values,
    required this.barColor,
    required this.axisColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxVal = values
        .fold<double>(0.0, (p, v) => v > p ? v : p)
        .clamp(0.0, double.infinity);

    const double padding = 12;
    final double w = size.width - padding * 2;
    final double h = size.height - padding * 2;

    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 0.8;

    final baseY = size.height - padding;
    canvas.drawLine(
      Offset(padding, baseY),
      Offset(size.width - padding, baseY),
      axisPaint,
    );

    if (maxVal <= 0) {
      final midY = padding + h / 2;
      final flatPaint = Paint()
        ..color = barColor
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(padding, midY),
        Offset(size.width - padding, midY),
        flatPaint,
      );
      return;
    }

    final int n = values.length;
    final double barWidth = (w / (n * 1.8)).clamp(4.0, 24.0);
    final double gap = (w - barWidth * n) / (n + 1);

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < n; i++) {
      final v = values[i];
      final t = v / maxVal;
      final barHeight = t * h;

      final left = padding + gap * (i + 1) + barWidth * i;
      final top = baseY - barHeight;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SellerBarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.barColor != barColor ||
        oldDelegate.axisColor != axisColor;
  }
}
