import 'package:flutter/material.dart';

import 'package:auto_spare/view/widgets/profile/orders_section.dart';
import 'package:auto_spare/view/screens/home_screen.dart';
import 'package:auto_spare/services/tow_requests.dart';

class BuyerProfileTab extends StatelessWidget {
  final String userId;

  const BuyerProfileTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: 'مشترياتي'),
                      Tab(text: 'طلبات الونش'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: OrdersSection(
                          key: ValueKey('buyer-orders'),
                          mode: OrdersSectionMode.buyer,
                          userId: userId,
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: _BuyerTowRequestsCard(userId: userId),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            icon: const Icon(Icons.storefront),
            label: const Text('اذهب للتسوق'),
          ),
        ),
      ],
    );
  }
}

class _BuyerTowRequestsCard extends StatelessWidget {
  final String userId;

  const _BuyerTowRequestsCard({required this.userId});

  bool _canCancel(TowRequestStatus status) {
    switch (status) {
      case TowRequestStatus.pending:
      case TowRequestStatus.accepted:
      case TowRequestStatus.onTheWay:
        return true;
      case TowRequestStatus.completed:
      case TowRequestStatus.cancelled:
      case TowRequestStatus.rejected:
        return false;
    }
  }

  Future<void> _cancelRequest(BuildContext context, TowRequestDoc r) async {
    final reasonCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إلغاء طلب الونش'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'سبب الإلغاء (اختياري)',
            hintText: 'مثال: الشركة اتأخرت / اتصرفّت بنفسي...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final reason = reasonCtrl.text.trim();

    try {
      await towRequestsRepo.cancelByUser(
        requestId: r.id,
        reason: reason.isEmpty ? null : reason,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء طلب الونش بنجاح')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذّر إلغاء الطلب: $e')));
    }
  }

  Color _statusColor(BuildContext context, TowRequestStatus status) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case TowRequestStatus.completed:
        return Colors.green;
      case TowRequestStatus.cancelled:
      case TowRequestStatus.rejected:
        return Colors.red;
      case TowRequestStatus.accepted:
      case TowRequestStatus.onTheWay:
        return cs.primary;
      case TowRequestStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<List<TowRequestDoc>>(
          stream: towRequestsRepo.watchUserRequests(userId),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final original = snap.data ?? const <TowRequestDoc>[];
            final list = List<TowRequestDoc>.from(original);

            if (list.isNotEmpty) {
              final unseen = list.where((r) => !r.userSeen).toList();
              if (unseen.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  for (final r in unseen) {
                    towRequestsRepo.markUserSeen(requestId: r.id);
                  }
                });
              }
            }

            if (list.isEmpty) {
              return const Text(
                'لا توجد طلبات سحب حتى الآن',
                textAlign: TextAlign.right,
              );
            }

            return Column(
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  _buildTowRow(context, list[i]),
                  if (i != list.length - 1) const Divider(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTowRow(BuildContext context, TowRequestDoc r) {
    final isNew = !r.userSeen;
    final canCancel = _canCancel(r.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            '${towStatusAr(r.status)}${isNew ? ' (جديد)' : ''}',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _statusColor(context, r.status),
            ),
          ),
          subtitle: Text(
            'الشركة: ${r.companyNameSnapshot}\n'
            'إجمالي: ${r.totalCost.toStringAsFixed(0)} جنيه\n'
            'المركبة: ${r.vehicle} • اللوحة: ${r.plate}',
            textAlign: TextAlign.right,
          ),
        ),
        if (canCancel)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _cancelRequest(context, r),
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: const Text(
                'إلغاء الطلب',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }
}
