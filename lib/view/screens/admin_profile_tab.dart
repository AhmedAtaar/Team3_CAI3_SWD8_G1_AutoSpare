import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:auto_spare/services/products.dart';
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/services/tow_requests.dart';
import 'package:auto_spare/view/widgets/profile/admin_orders_tab.dart';
import 'package:auto_spare/view/widgets/admin/admin_winch_tab.dart';
import 'package:auto_spare/view/screens/admin_tow_orders_screen.dart';
import 'package:auto_spare/view/screens/admin_earnings_screen.dart';
import 'package:auto_spare/view/screens/admin_users_accounts_screen.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class AdminProfileTab extends StatefulWidget {
  const AdminProfileTab({super.key});

  @override
  State<AdminProfileTab> createState() => _AdminProfileTabState();
}

class _AdminProfileTabState extends State<AdminProfileTab> {
  Future<void> _openExternal(String url) async {
    final loc = AppLocalizations.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.common_invalid_url)));
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  Future<void> _openImagePreview(String url, {String? title}) async {
    final loc = AppLocalizations.of(context);

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            Flexible(
              child: AspectRatio(
                aspectRatio: 1,
                child: InteractiveViewer(
                  maxScale: 5,
                  minScale: 0.5,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(loc.common_image_load_failed),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _openExternal(url),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(loc.common_open_in_browser),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _docLink({
    required String label,
    required String? url,
    IconData icon = Icons.insert_drive_file_outlined,
  }) {
    final loc = AppLocalizations.of(context);
    final has = (url != null && url.trim().isNotEmpty);
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: ${has ? url! : '—'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (has) ...[
            IconButton(
              tooltip: loc.common_preview,
              onPressed: () => _openImagePreview(url!, title: label),
              icon: const Icon(Icons.visibility_outlined),
            ),
            IconButton(
              tooltip: loc.common_open_in_browser,
              onPressed: () => _openExternal(url!),
              icon: const Icon(Icons.open_in_new),
            ),
          ],
        ],
      ),
    );
  }

  List<AppUser> _pendingSellers() {
    return usersRepo.allUsers
        .where(
          (u) =>
              u.role == AppUserRole.seller &&
              (u.approved == false || u.approved == null),
        )
        .toList();
  }

  void _approveSeller(AppUser u) {
    final updated = u.copyWith(approved: true, canSell: true);
    usersRepo.updateUser(updated);
  }

  void _rejectSeller(AppUser u) {
    final updated = u.copyWith(approved: false, canSell: false);
    usersRepo.updateUser(updated);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final pendingSellers = _pendingSellers();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminEarningsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart_outlined),
              label: Text(loc.admin_profile_earnings_button),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminOrdersScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: Text(loc.admin_profile_manage_orders_button),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminTowOrdersScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: Text(loc.admin_profile_manage_tow_orders_button),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUsersAccountsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.people_alt_outlined),
              label: Text(loc.admin_profile_users_accounts_button),
            ),
          ),
          const SizedBox(height: 8),

          TabBar(
            isScrollable: true,
            labelColor: cs.primary,
            labelStyle: const TextStyle(fontSize: 12),
            tabs: [
              Tab(text: loc.admin_profile_tab_products_review),
              Tab(text: loc.admin_profile_tab_sellers_approval),
              Tab(text: loc.admin_profile_tab_tow_approval),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                const _PendingProductsAdminTab(),

                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.admin_profile_pending_sellers_title),
                          const SizedBox(height: 6),
                          Text(
                            '${loc.admin_profile_pending_label_prefix} ${pendingSellers.length}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: pendingSellers.isEmpty
                          ? Center(
                              child: Text(loc.admin_profile_no_pending_sellers),
                            )
                          : ListView.separated(
                              itemCount: pendingSellers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final s = pendingSellers[i];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CircleAvatar(
                                          child: Icon(Icons.storefront),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${s.name} • ${s.storeName ?? '—'}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Email: ${s.email}\n${loc.signup_phone_label} ${s.phone}',
                                              ),
                                              _docLink(
                                                label: 'CR',
                                                url: s.commercialRegUrl,
                                                icon: Icons
                                                    .picture_as_pdf_outlined,
                                              ),
                                              _docLink(
                                                label: 'Tax',
                                                url: s.taxCardUrl,
                                                icon: Icons
                                                    .picture_as_pdf_outlined,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              tooltip: loc.admin_common_reject,
                                              onPressed: () {
                                                _rejectSeller(s);
                                                setState(() {});
                                              },
                                              icon: const Icon(
                                                Icons.block,
                                                color: Colors.red,
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: loc.admin_common_approve,
                                              onPressed: () {
                                                _approveSeller(s);
                                                setState(() {});
                                              },
                                              icon: const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),

                const AdminTowRequestsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingProductsAdminTab extends StatelessWidget {
  const _PendingProductsAdminTab({super.key});

  Future<void> _approveProduct(BuildContext context, CatalogProduct p) async {
    final loc = AppLocalizations.of(context);

    final updated = CatalogProduct(
      id: p.id,
      title: p.title,
      description: p.description,
      seller: p.seller,
      price: p.price,
      imageUrl: p.imageUrl,
      brand: p.brand,
      model: p.model,
      years: p.years,
      stock: p.stock,
      createdAt: p.createdAt,
      status: ProductStatus.approved,
      rejectionReason: null,
    );

    try {
      await productsRepo.upsertProduct(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.admin_products_approve_success_prefix} ${p.id}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.admin_products_update_failed_prefix} $e'),
        ),
      );
    }
  }

  Future<void> _rejectProduct(BuildContext context, CatalogProduct p) async {
    final loc = AppLocalizations.of(context);
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.admin_products_reject_dialog_title),
        content: TextField(
          controller: reasonCtrl,
          decoration: InputDecoration(
            labelText: loc.admin_products_reject_reason_label,
            border: const OutlineInputBorder(),
            hintText: loc.admin_products_reject_reason_hint,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.admin_common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.admin_common_reject),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final reason = reasonCtrl.text.trim().isEmpty
        ? loc.admin_products_reject_reason_default
        : reasonCtrl.text.trim();

    final updated = CatalogProduct(
      id: p.id,
      title: p.title,
      description: p.description,
      seller: p.seller,
      price: p.price,
      imageUrl: p.imageUrl,
      brand: p.brand,
      model: p.model,
      years: p.years,
      stock: p.stock,
      createdAt: p.createdAt,
      status: ProductStatus.rejected,
      rejectionReason: reason,
    );

    try {
      await productsRepo.upsertProduct(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${loc.admin_products_rejected_with_reason_prefix} ${p.id} • ${loc.admin_products_reject_reason_label}: $reason',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.admin_products_update_failed_prefix} $e'),
        ),
      );
    }
  }

  Widget _thumb(String? url) {
    if (url == null || url.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.image_outlined));
    }
    return CircleAvatar(
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
      child: const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return StreamBuilder<List<CatalogProduct>>(
      stream: productsRepo.watchAllProducts(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(child: Text(loc.admin_products_error_loading));
        }

        final all = snap.data ?? const <CatalogProduct>[];
        final pending = all
            .where((p) => p.status == ProductStatus.pending)
            .toList();

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.admin_profile_products_panel_title),
                  const SizedBox(height: 6),
                  Text(
                    '${loc.admin_profile_pending_label_prefix} ${pending.length}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: pending.isEmpty
                  ? Center(child: Text(loc.admin_profile_no_pending_products))
                  : ListView.separated(
                      itemCount: pending.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final it = pending[i];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _thumb(it.imageUrl),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(it.title),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${loc.admin_products_label_id}: ${it.id} • '
                                            '${loc.admin_products_label_seller}: ${it.seller}\n'
                                            '${loc.admin_products_label_brand}: ${kBrandName[it.brand]} • '
                                            '${loc.admin_products_label_model}: ${it.model}\n'
                                            '${loc.admin_products_label_years}: ${it.years.join(', ')} • '
                                            '${loc.admin_products_label_stock}: ${it.stock}\n'
                                            '${it.description}',
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _rejectProduct(context, it),
                                        icon: const Icon(
                                          Icons.block,
                                          color: Colors.red,
                                        ),
                                        label: Text(
                                          loc.admin_common_reject,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () =>
                                            _approveProduct(context, it),
                                        icon: const Icon(Icons.check),
                                        label: Text(loc.admin_common_approve),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(loc.admin_orders_title), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AdminOrdersTab(repo: ordersRepo),
        ),
      ),
    );
  }
}

class AdminTowRequestsTab extends StatelessWidget {
  const AdminTowRequestsTab({super.key});

  Future<void> _openExternal(BuildContext context, String url) async {
    final loc = AppLocalizations.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.common_invalid_url)));
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  Future<void> _openImagePreview(
    BuildContext context,
    String url, {
    String? title,
  }) async {
    final loc = AppLocalizations.of(context);

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            Flexible(
              child: AspectRatio(
                aspectRatio: 1,
                child: InteractiveViewer(
                  maxScale: 5,
                  minScale: 0.5,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(loc.common_image_load_failed),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _openExternal(context, url),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(loc.common_open_in_browser),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _docLink({
    required BuildContext context,
    required String label,
    required String? url,
    IconData icon = Icons.insert_drive_file_outlined,
  }) {
    final loc = AppLocalizations.of(context);
    final has = (url != null && url.trim().isNotEmpty);
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: ${has ? url! : '—'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (has) ...[
            IconButton(
              tooltip: loc.common_preview,
              onPressed: () => _openImagePreview(context, url!, title: label),
              icon: const Icon(Icons.visibility_outlined),
            ),
            IconButton(
              tooltip: loc.common_open_in_browser,
              onPressed: () => _openExternal(context, url!),
              icon: const Icon(Icons.open_in_new),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final pendingTow = UserStore().pendingTowCompanies();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.admin_tow_requests_pending_title),
              const SizedBox(height: 6),
              Text(
                '${loc.admin_profile_pending_label_prefix} ${pendingTow.length}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: pendingTow.isEmpty
              ? Center(child: Text(loc.admin_tow_requests_no_pending))
              : ListView.separated(
                  itemCount: pendingTow.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final a = pendingTow[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              child: Icon(Icons.local_shipping_outlined),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${a.companyName} • ${a.area}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${loc.admin_tow_requests_account_owner_label} ${a.contactName}\n'
                                    'Email: ${a.contactEmail}\n'
                                    '${loc.signup_phone_label} ${a.contactPhone}',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${loc.admin_tow_requests_service_price_prefix} ${a.baseCost.toStringAsFixed(0)} ${AppLocalizations.of(context).currency_egp} • '
                                    '${loc.admin_tow_requests_price_per_km_prefix} ${a.pricePerKm.toStringAsFixed(0)} ${AppLocalizations.of(context).currency_egp}',
                                  ),
                                  Text(
                                    '${loc.admin_tow_requests_location_label} '
                                    '(${a.lat.toStringAsFixed(6)}, ${a.lng.toStringAsFixed(6)})',
                                  ),
                                  if ((a.commercialRegUrl?.isNotEmpty ??
                                          false) ||
                                      (a.taxCardUrl?.isNotEmpty ?? false)) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      loc.admin_profile_uploaded_docs_title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (a.commercialRegUrl?.isNotEmpty ?? false)
                                      _docLink(
                                        context: context,
                                        label: loc.signup_tow_cr_url_label,
                                        url: a.commercialRegUrl!,
                                        icon: Icons.picture_as_pdf_outlined,
                                      ),
                                    if (a.taxCardUrl?.isNotEmpty ?? false)
                                      _docLink(
                                        context: context,
                                        label: loc.signup_tow_tax_url_label,
                                        url: a.taxCardUrl!,
                                        icon: Icons.picture_as_pdf_outlined,
                                      ),
                                  ],
                                  if (a.rejectReason != null &&
                                      a.status == SellerStatus.rejected)
                                    Text(
                                      '${loc.admin_profile_rejected_with_reason_prefix} ${a.rejectReason}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: loc.admin_common_reject,
                                  onPressed: () async {
                                    final ctrl = TextEditingController();
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(
                                          loc.admin_products_reject_reason_label,
                                        ),
                                        content: TextField(
                                          controller: ctrl,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            hintText: loc
                                                .admin_products_reject_reason_hint,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(
                                              loc.admin_common_cancel,
                                            ),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(
                                              loc.admin_common_reject,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      UserStore().rejectTow(
                                        a.id,
                                        ctrl.text.trim().isEmpty
                                            ? loc.admin_products_reject_reason_default
                                            : ctrl.text.trim(),
                                      );
                                      (context as Element).markNeedsBuild();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.block,
                                    color: Colors.red,
                                  ),
                                ),
                                IconButton(
                                  tooltip: loc.admin_common_approve,
                                  onPressed: () async {
                                    await UserStore().approveTow(a.id);
                                    (context as Element).markNeedsBuild();
                                  },
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
