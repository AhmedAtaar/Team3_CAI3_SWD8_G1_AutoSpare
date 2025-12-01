import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:auto_spare/services/products.dart';
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/view/widgets/profile/admin_orders_tab.dart';
import 'package:auto_spare/view/screens/admin_tow_orders_screen.dart';
import 'package:auto_spare/view/screens/admin_earnings_screen.dart';

import 'admin_users_accounts_screen.dart';

class AdminProfileTab extends StatefulWidget {
  const AdminProfileTab({super.key});

  @override
  State<AdminProfileTab> createState() => _AdminProfileTabState();
}

class _AdminProfileTabState extends State<AdminProfileTab> {
  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('رابط غير صالح')));
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  Future<void> _openImagePreview(String url, {String? title}) async {
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
                    errorBuilder: (_, __, ___) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('تعذر تحميل الصورة'),
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
                  label: const Text('فتح في المتصفح'),
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
    final has = (url != null && url.trim().isNotEmpty);
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: ${has ? url : '—'}',
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (has) ...[
            IconButton(
              tooltip: 'معاينة',
              onPressed: () => _openImagePreview(url, title: label),
              icon: const Icon(Icons.visibility_outlined),
            ),
            IconButton(
              tooltip: 'فتح في المتصفح',
              onPressed: () => _openExternal(url),
              icon: const Icon(Icons.open_in_new),
            ),
          ],
        ],
      ),
    );
  }

  List<AppUser> _pendingSellers() {
    return usersRepo.allUsers
        .where((u) => u.role == AppUserRole.seller && u.approved != true)
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
              label: const Text('لوحة أرباح التطبيق'),
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
                  label: const Text('إدارة الطلبات'),
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
                  label: const Text('إدارة طلبات الونش'),
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
              label: const Text('حسابات المستخدمين'),
            ),
          ),
          const SizedBox(height: 8),

          TabBar(
            isScrollable: true,
            labelColor: cs.primary,
            labelStyle: const TextStyle(fontSize: 12),
            tabs: const [
              Tab(text: 'مراجعة المنتجات'),
              Tab(text: 'اعتماد البائعين'),
              Tab(text: 'اعتماد شركات الأوناش'),
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
                          const Text(
                            'طلبات تسجيل كبائع (Pending)',
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'في الانتظار: ${pendingSellers.length}',
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: pendingSellers.isEmpty
                          ? const Center(
                              child: Text('لا توجد طلبات بائعين قيد المراجعة'),
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
                                                textDirection:
                                                    TextDirection.rtl,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Email: ${s.email}\nPhone: ${s.phone}',
                                                textDirection:
                                                    TextDirection.rtl,
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
                                              tooltip: 'رفض',
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
                                              tooltip: 'موافقة',
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
  const _PendingProductsAdminTab();

  Future<void> _approveProduct(BuildContext context, CatalogProduct p) async {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تمت الموافقة على ${p.id}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في التحديث: $e')));
    }
  }

  Future<void> _rejectProduct(BuildContext context, CatalogProduct p) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('رفض المنتج'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            labelText: 'سبب الرفض',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final reason = reasonCtrl.text.trim().isEmpty
        ? 'غير مُحدد'
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
        SnackBar(content: Text('تم رفض ${p.id} • السبب: $reason')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في التحديث: $e')));
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

    return StreamBuilder<List<CatalogProduct>>(
      stream: productsRepo.watchAllProducts(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return const Center(child: Text('حدث خطأ أثناء تحميل المنتجات'));
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
                  const Text(
                    'لوحة مراجعة المنتجات',
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'في الانتظار: ${pending.length}',
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: pending.isEmpty
                  ? const Center(child: Text('لا توجد عناصر قيد المراجعة'))
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
                                          Text(
                                            it.title,
                                            textDirection: TextDirection.rtl,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'رقم: ${it.id} • البائع: ${it.seller}\n'
                                            'البراند: ${kBrandName[it.brand]} • الموديل: ${it.model}\n'
                                            'السنوات: ${it.years.join(', ')} • المخزون: ${it.stock}\n'
                                            '${it.description}',
                                            textDirection: TextDirection.rtl,
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
                                        label: const Text(
                                          'رفض',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () =>
                                            _approveProduct(context, it),
                                        icon: const Icon(Icons.check),
                                        label: const Text('موافقة'),
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة الطلبات'), centerTitle: true),
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
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('رابط غير صالح')));
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
                    errorBuilder: (_, __, ___) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('تعذر تحميل الصورة'),
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
                  label: const Text('فتح في المتصفح'),
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
    final has = (url != null && url.trim().isNotEmpty);
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: ${has ? url : '—'}',
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (has) ...[
            IconButton(
              tooltip: 'معاينة',
              onPressed: () => _openImagePreview(context, url, title: label),
              icon: const Icon(Icons.visibility_outlined),
            ),
            IconButton(
              tooltip: 'فتح في المتصفح',
              onPressed: () => _openExternal(context, url),
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
              const Text(
                'طلبات شركات الونش (Pending)',
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              Text(
                'في الانتظار: ${pendingTow.length}',
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: pendingTow.isEmpty
              ? const Center(child: Text('لا توجد طلبات قيد المراجعة'))
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
                                    'صاحب الحساب: ${a.contactName}\n'
                                    'Email: ${a.contactEmail}\n'
                                    'Phone: ${a.contactPhone}',
                                    textDirection: TextDirection.rtl,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'سعر الخدمة: ${a.baseCost.toStringAsFixed(0)}ج • '
                                    'سعر الكيلو: ${a.pricePerKm.toStringAsFixed(0)}ج',
                                  ),
                                  Text(
                                    '(${a.lat.toStringAsFixed(6)}, ${a.lng.toStringAsFixed(6)})',
                                  ),
                                  if ((a.commercialRegUrl?.isNotEmpty ??
                                          false) ||
                                      (a.taxCardUrl?.isNotEmpty ?? false)) ...[
                                    const SizedBox(height: 8),
                                    const Text(
                                      'المستندات المرفوعة:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (a.commercialRegUrl?.isNotEmpty ?? false)
                                      _docLink(
                                        context: context,
                                        label: 'رابط السجل التجاري',
                                        url: a.commercialRegUrl!,
                                        icon: Icons.picture_as_pdf_outlined,
                                      ),
                                    if (a.taxCardUrl?.isNotEmpty ?? false)
                                      _docLink(
                                        context: context,
                                        label: 'رابط البطاقة الضريبية',
                                        url: a.taxCardUrl!,
                                        icon: Icons.picture_as_pdf_outlined,
                                      ),
                                  ],
                                  if (a.rejectReason != null &&
                                      a.status == SellerStatus.rejected)
                                    Text(
                                      'مرفوض: ${a.rejectReason}',
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
                                  tooltip: 'رفض',
                                  onPressed: () async {
                                    final ctrl = TextEditingController();
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('سبب الرفض'),
                                        content: TextField(
                                          controller: ctrl,
                                          maxLines: 3,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'سبب الرفض (اختياري)',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('إلغاء'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('رفض'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      UserStore().rejectTow(
                                        a.id,
                                        ctrl.text.trim().isEmpty
                                            ? 'غير محدد'
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
                                  tooltip: 'موافقة',
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
