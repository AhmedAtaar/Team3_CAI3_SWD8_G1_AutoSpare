import 'package:flutter/material.dart';
import 'package:auto_spare/core/tow_status_localized.dart';

import 'package:auto_spare/view/widgets/profile/orders_section.dart';
import 'package:auto_spare/view/screens/home_screen.dart';
import 'package:auto_spare/services/tow_requests.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class BuyerProfileTab extends StatelessWidget {
  final String userId;

  const BuyerProfileTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

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
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: loc.buyer_profile_tab_my_orders),
                      Tab(text: loc.buyer_profile_tab_tow_requests),
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
                          key: const ValueKey('buyer-orders'),
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
            label: Text(loc.buyer_profile_go_shopping_button),
          ),
        ),
      ],
    );
  }
}

class _BuyerTowRequestsCard extends StatelessWidget {
  final String userId;

  const _BuyerTowRequestsCard({super.key, required this.userId});

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
    final loc = AppLocalizations.of(context);
    final reasonCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.buyer_tow_cancel_dialog_title),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: loc.buyer_tow_cancel_reason_label,
            hintText: loc.buyer_tow_cancel_reason_hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.admin_common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.buyer_tow_cancel_confirm_button),
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
          SnackBar(content: Text(loc.buyer_tow_cancel_success_message)),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.buyer_tow_cancel_error_prefix} $e')),
      );
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
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

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
              return Text(
                loc.buyer_tow_no_requests_message,
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
    final loc = AppLocalizations.of(context);
    final isNew = !r.userSeen;
    final canCancel = _canCancel(r.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            '${towStatusText(context, r.status)}'
            '${isNew ? ' ${loc.buyer_tow_status_new_suffix}' : ''}',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _statusColor(context, r.status),
            ),
          ),
          subtitle: Text(
            '${loc.admin_tow_orders_company_prefix} ${r.companyNameSnapshot}\n'
            '${loc.admin_tow_orders_total_cost_prefix} '
            '${r.totalCost.toStringAsFixed(0)} ${loc.currency_egp}\n'
            '${loc.admin_tow_orders_vehicle_label} ${r.vehicle} • '
            '${loc.admin_tow_orders_plate_label} ${r.plate}',
            textAlign: TextAlign.right,
          ),
        ),
        if (canCancel)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _cancelRequest(context, r),
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: Text(
                loc.buyer_tow_cancel_button,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }
}
