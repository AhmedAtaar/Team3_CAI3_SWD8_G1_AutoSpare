import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:auto_spare/model/order.dart';
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/core/earnings_utils.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class AdminEarningsScreen extends StatefulWidget {
  const AdminEarningsScreen({super.key});

  @override
  State<AdminEarningsScreen> createState() => _AdminEarningsScreenState();
}

class _AdminEarningsScreenState extends State<AdminEarningsScreen> {
  late DateTimeRange _range;

  String _fmt(BuildContext context, double v) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final f = NumberFormat('#,##0.00', locale);
    final loc = AppLocalizations.of(context);
    return '${f.format(v)} ${loc.currency_egp}';
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    _range = DateTimeRange(
      start: now.subtract(const Duration(days: 29)),
      end: now,
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final loc = AppLocalizations.of(context);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range,
      helpText: loc.admin_earnings_date_range_help,
      confirmText: loc.admin_earnings_date_range_confirm,
      cancelText: loc.admin_earnings_date_range_cancel,
    );

    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  List<OrderDoc> _filterByRange(List<OrderDoc> delivered, DateTimeRange range) {
    final end = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      23,
      59,
      59,
    );
    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );

    return delivered.where((o) {
      final d = o.stamps.deliveredAt;
      if (d == null) return false;
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy/MM/dd');
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(loc.admin_earnings_title),
      ),
      body: StreamBuilder<List<OrderDoc>>(
        stream: ordersRepo.watchAllOrdersAdmin(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Text(
                loc.admin_earnings_error_loading_orders,
                textAlign: TextAlign.center,
              ),
            );
          }

          final all = snap.data ?? const <OrderDoc>[];

          final delivered = all
              .where((o) => o.status == OrderStatus.delivered)
              .toList();

          if (delivered.isEmpty) {
            return Center(
              child: Text(
                loc.admin_earnings_no_completed_orders,
                textAlign: TextAlign.center,
              ),
            );
          }

          final filtered = _filterByRange(delivered, _range);

          double sumGrand(List<OrderDoc> list) =>
              list.fold(0.0, (p, o) => p + o.grandTotal);

          double sumItems(List<OrderDoc> list) =>
              list.fold(0.0, (p, o) => p + o.itemsTotal);

          double sumDiscount(List<OrderDoc> list) =>
              list.fold(0.0, (p, o) => p + o.discount);

          double sumAppFee(List<OrderDoc> list) =>
              list.fold(0.0, (p, o) => p + computeOrderAppFee(o));

          final totalOrders = filtered.length;
          final totalRevenue = sumGrand(filtered);
          final totalItemsAmount = sumItems(filtered);
          final totalDiscount = sumDiscount(filtered);
          final totalAppFee = sumAppFee(filtered);

          final Map<DateTime, double> dailyFeeMap = {};
          for (final o in filtered) {
            final d = o.stamps.deliveredAt;
            if (d == null) continue;
            final dayKey = DateTime(d.year, d.month, d.day);
            dailyFeeMap[dayKey] =
                (dailyFeeMap[dayKey] ?? 0.0) + computeOrderAppFee(o);
          }
          final sortedDays = dailyFeeMap.keys.toList()..sort();
          final dailyValues = sortedDays
              .map((d) => dailyFeeMap[d] ?? 0.0)
              .toList();

          double cardWidth(double maxWidth) {
            if (maxWidth >= 1000) return (maxWidth - 48) / 3;
            if (maxWidth >= 650) return (maxWidth - 32) / 2;
            return maxWidth;
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final cw = cardWidth(constraints.maxWidth);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  loc.admin_earnings_current_period_label,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${df.format(_range.start)}  →  ${df.format(_range.end)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () => _pickRange(context),
                          icon: const Icon(Icons.date_range),
                          label: Text(loc.admin_earnings_change_period_button),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            cs.primary.withOpacity(.12),
                            cs.primary.withOpacity(.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cs.primary.withOpacity(.12)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  loc.admin_earnings_summary_title,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  loc.admin_earnings_summary_desc,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: cs.onSurfaceVariant),
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
                                Text(
                                  loc.admin_earnings_total_app_fee_label,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                Text(
                                  _fmt(context, totalAppFee),
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
                    ),

                    const SizedBox(height: 20),

                    if (filtered.isEmpty) ...[
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: cs.outlineVariant.withOpacity(.4),
                            width: 0.6,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            loc.admin_earnings_no_completed_in_range,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ] else ...[
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.end,
                        children: [
                          SizedBox(
                            width: cw,
                            child: _StatCard(
                              title:
                                  loc.admin_earnings_period_orders_count_title,
                              value: '$totalOrders',
                              icon: Icons.shopping_bag_outlined,
                              iconColor: cs.primary,
                            ),
                          ),
                          SizedBox(
                            width: cw,
                            child: _StatCard(
                              title: loc.admin_earnings_period_total_paid_title,
                              value: _fmt(context, totalRevenue),
                              subtitle: loc.admin_earnings_total_paid_subtitle,
                              icon: Icons.payments_outlined,
                              iconColor: Colors.teal,
                            ),
                          ),
                          SizedBox(
                            width: cw,
                            child: _StatCard(
                              title: loc.admin_earnings_total_items_title,
                              value: _fmt(context, totalItemsAmount),
                              subtitle: loc.admin_earnings_total_items_subtitle,
                              icon: Icons.inventory_2_outlined,
                              iconColor: Colors.blue,
                            ),
                          ),
                          SizedBox(
                            width: cw,
                            child: _StatCard(
                              title: loc.admin_earnings_total_discount_title,
                              value: _fmt(context, totalDiscount),
                              icon: Icons.local_offer_outlined,
                              iconColor: Colors.pink,
                            ),
                          ),
                          SizedBox(
                            width: cw,
                            child: _StatCard(
                              title:
                                  loc.admin_earnings_total_app_fee_card_title,
                              value: _fmt(context, totalAppFee),
                              subtitle:
                                  loc.admin_earnings_total_app_fee_subtitle,
                              icon: Icons.trending_up_outlined,
                              iconColor: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Text(
                        loc.admin_earnings_chart_section_title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),

                      _EarningsChart(values: dailyValues, days: sortedDays),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceVariant.withOpacity(.25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.end,
                          children: [
                            SizedBox(
                              width: cw,
                              child: _StatCard.small(
                                title: loc
                                    .admin_earnings_period_orders_count_title,
                                value: '$totalOrders',
                                icon: Icons.receipt_long_outlined,
                                iconColor: cs.primary,
                              ),
                            ),
                            SizedBox(
                              width: cw,
                              child: _StatCard.small(
                                title:
                                    loc.admin_earnings_period_total_paid_title,
                                value: _fmt(context, totalRevenue),
                                icon: Icons.payments_rounded,
                                iconColor: Colors.teal,
                              ),
                            ),
                            SizedBox(
                              width: cw,
                              child: _StatCard.small(
                                title: loc.admin_earnings_period_app_fee_title,
                                value: _fmt(context, totalAppFee),
                                icon: Icons.trending_up,
                                iconColor: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${loc.admin_earnings_last_updated_prefix} '
                        '${DateFormat('yyyy/MM/dd – HH:mm').format(DateTime.now())}',
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
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final bool dense;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.subtitle,
    this.dense = false,
  });

  const _StatCard.small({
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

class _EarningsChart extends StatelessWidget {
  final List<double> values;
  final List<DateTime> days;

  const _EarningsChart({required this.values, required this.days});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    if (values.isEmpty || values.every((v) => v == 0.0)) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: cs.outlineVariant.withOpacity(.4),
              width: 0.6,
            ),
          ),
          child: SizedBox(
            height: 160,
            child: Center(
              child: Text(
                loc.admin_earnings_chart_no_data,
                textAlign: TextAlign.center,
              ),
            ),
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
              loc.admin_earnings_chart_title,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 170,
              child: CustomPaint(
                painter: _LineChartPainter(
                  values: values,
                  lineColor: cs.primary,
                  fillColor: cs.primary.withOpacity(.12),
                  axisColor: cs.outlineVariant.withOpacity(.7),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (days.isNotEmpty)
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

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final Color axisColor;

  _LineChartPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.axisColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxVal = values.fold<double>(0.0, (p, v) => v > p ? v : p);
    const double minVal = 0.0;

    const double chartPadding = 12;
    final double w = size.width - chartPadding * 2;
    final double h = size.height - chartPadding * 2;

    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 0.8;

    canvas.drawLine(
      Offset(chartPadding, size.height - chartPadding),
      Offset(size.width - chartPadding, size.height - chartPadding),
      axisPaint,
    );

    if (maxVal <= 0) {
      final midY = chartPadding + h / 2;
      final flatPaint = Paint()
        ..color = lineColor
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(chartPadding, midY),
        Offset(size.width - chartPadding, midY),
        flatPaint,
      );
      return;
    }

    double normY(double value) {
      final t = (value - minVal) / (maxVal - minVal);
      return size.height - chartPadding - (t * h);
    }

    final int n = values.length;
    final double dx = n == 1 ? 0 : w / (n - 1);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < n; i++) {
      final x = chartPadding + dx * i;
      final y = normY(values[i]);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - chartPadding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(chartPadding + dx * (n - 1), size.height - chartPadding);
    fillPath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    for (int i = 0; i < n; i++) {
      final x = chartPadding + dx * i;
      final y = normY(values[i]);
      canvas.drawCircle(Offset(x, y), 3.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.axisColor != axisColor;
  }
}
