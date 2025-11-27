import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/services/user_session.dart';
import 'package:auto_spare/view/screens/tow_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:auto_spare/view/widgets/profile/admin_orders_tab.dart';
import 'package:auto_spare/view/widgets/profile/seller_inventory_tab.dart';
import 'package:auto_spare/view/widgets/profile/orders_section.dart';
import 'package:auto_spare/view/screens/tow_operator_panel.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:auto_spare/services/tow_badge_stream.dart';
// Firebase / Firestore repos
import 'package:auto_spare/services/products.dart';
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/view/widgets/admin/admin_winch_tab.dart';
import 'package:auto_spare/services/tow_requests.dart'; // towRequestsRepo + TowRequestDoc + TowRequestStatus + towStatusAr
import 'package:auto_spare/services/tow_badge_controller.dart';
import 'package:auto_spare/view/screens/seller_orders_screen.dart';
import 'package:auto_spare/view/screens/admin_tow_orders_screen.dart';


enum ProductStatus { pending, approved, rejected }

class ModerationProduct {
  final String id;
  final String title;
  final String description;
  final String seller;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;

  final CarBrand brand;
  final String model;
  final List<int> years;
  final int stock;

  ProductStatus status;
  String? rejectReason;

  ModerationProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.seller,
    required this.price,
    this.imageUrl,
    required this.createdAt,
    required this.brand,
    required this.model,
    required this.years,
    required this.stock,
    this.status = ProductStatus.pending,
    this.rejectReason,
  });
}

class MockStore {
  static final MockStore _i = MockStore._();
  MockStore._();
  factory MockStore() => _i;

  final List<ModerationProduct> _products = [];

  List<ModerationProduct> byStatus(ProductStatus s, {String? seller}) {
    return _products
        .where((p) => p.status == s && (seller == null || p.seller == seller))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<ModerationProduct> pending({String? seller}) =>
      byStatus(ProductStatus.pending, seller: seller);
  List<ModerationProduct> approved({String? seller}) =>
      byStatus(ProductStatus.approved, seller: seller);
  List<ModerationProduct> rejected({String? seller}) =>
      byStatus(ProductStatus.rejected, seller: seller);

  void submit(ModerationProduct p) => _products.add(p);

  // ⬅️ هنا التعديل المهم: الموافقة ترفع المنتج لـ Firestore + الكتالوج في الذاكرة
  Future<void> approve(String id) async {
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final p = _products[idx];
      _products[idx].status = ProductStatus.approved;
      _products[idx].rejectReason = null;

      final cp = CatalogProduct(
        id: p.id,
        title: p.title,
        seller: p.seller,
        price: p.price,
        imageUrl: p.imageUrl,
        brand: p.brand,
        model: p.model,
        years: p.years,
        stock: p.stock,
        createdAt: p.createdAt,
      );

      // لو في أماكن لسه معتمدة على الكتالوج في الذاكرة
      Catalog().add(cp);

      // الأهم: رفع المنتج المعتمد إلى Firestore
      await productsRepo.upsertProduct(cp);
    }
  }

  void reject(String id, String reason) {
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _products[idx].status = ProductStatus.rejected;
      _products[idx].rejectReason = reason;
    }
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final store = MockStore();
  int _bottomIndex = 4;

  UserRole _mapRole(AppUserRole r) {
    switch (r) {
      case AppUserRole.admin:
        return UserRole.admin;
      case AppUserRole.seller:
        return UserRole.seller;
      case AppUserRole.buyer:
      default:
        return UserRole.buyer;
    }
  }


  @override
  @override
  void initState() {
    super.initState();
    final u = UserStore().currentUser;
    if (u != null && !UserSession.loggedIn) {
      UserSession.initFromProfile(
        name: u.name,
        email: u.email,
        phone: u.phone,
        role: _mapRole(u.role),
        canSell: u.canSell,
        canTow: u.canTow,
        towCompanyId: u.towCompanyId,
      );
    }

    // 🔴 مهم: حدّث عدّاد الإشعارات للمستخدم الحالي
    TowBadgeController().refreshForCurrentUser();
  }



  void _goTo(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void _logout() {
    UserStore().currentUser = null;
    UserSession.signOut();

    // صفّر العدادات
    TowBadgeController().refreshForCurrentUser();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }


  void _login() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _approveItem(String id) async {
    await store.approve(id); // ✅ نستنى Firestore
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت الموافقة على $id')),
    );
  }

  Future<void> _rejectItem(String id) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('رفض العنصر'),
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
    if (ok == true) {
      final reason = reasonCtrl.text.trim().isEmpty
          ? 'غير مُحدد'
          : reasonCtrl.text.trim();
      store.reject(id, reason);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفض $id • السبب: $reason')),
      );
    }
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('رابط غير صالح')));
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

  Widget _DocLink({
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
              '$label: ${has ? url! : '—'}',
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (has) ...[
            IconButton(
              tooltip: 'معاينة',
              onPressed: () => _openImagePreview(url!, title: label),
              icon: const Icon(Icons.visibility_outlined),
            ),
            IconButton(
              tooltip: 'فتح في المتصفح',
              onPressed: () => _openExternal(url!),
              icon: const Icon(Icons.open_in_new),
            ),
          ],
        ],
      ),
    );
  }
  /// Stream يرجّع عدد الطلبات الجديدة (اللي لسه ما اتشوفتش)
  /// لو الأكونت عليه towCompanyId → نستخدم طلبات الشركة
  /// غير كده → نستخدم طلبات المشتري
  Stream<int>? _notificationCountStreamForCurrentUser() {
    final user = UserStore().currentUser;
    if (user == null) return null;

    // لو أكونت شركة ونش
    if (user.towCompanyId != null) {
      final cid = user.towCompanyId!;
      return towRequestsRepo
          .watchCompanyRequests(cid)
          .map((list) => list.where((r) => !r.companySeen).length);
    }

    // لو مشتري عادي
    return towRequestsRepo
        .watchUserRequests(user.id)
        .map((list) => list.where((r) => !r.userSeen).length);
  }

  /// أيقونة "حسابي" ومعاها البادج لو في إشعارات
  Widget _buildProfileIcon(int badgeCount, {required bool selected}) {
    final baseIcon = Icon(
      selected ? Icons.person : Icons.person_outline,
    );

    if (badgeCount <= 0) {
      return baseIcon;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        baseIcon,
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Center(
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(int badgeCount) {
    return NavigationBar(
      selectedIndex: _bottomIndex,
      onDestinationSelected: (i) {
        setState(() => _bottomIndex = i);
        switch (i) {
          case 0:
            _goTo(const HomeScreen());
            break;
          case 1:
            _goTo(const CategoriesScreen());
            break;
          case 2:
            _goTo(const TowScreen());
            break;
          case 3:
            _goTo(const CartScreen());
            break;
          case 4:
          default:
            break;
        }
      },
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        const NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: 'التصنيفات',
        ),
        const NavigationDestination(
          icon: Icon(Icons.local_shipping_outlined),
          selectedIcon: Icon(Icons.local_shipping),
          label: 'الونش',
        ),
        const NavigationDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart),
          label: 'السلة',
        ),
        NavigationDestination(
          icon: _profileIconWithBadge(
            count: badgeCount,
            selected: false,
          ),
          selectedIcon: _profileIconWithBadge(
            count: badgeCount,
            selected: true,
          ),
          label: 'حسابي',
        ),
      ],
    );
  }



  // 👇 خلي الدالة دي برضه جوه نفس الـ class `_ProfileScreenState`
  Widget _profileIconWithBadge({
    required int count,
    required bool selected,
  }) {
    final baseIcon = Icon(
      selected ? Icons.person : Icons.person_outline,
    );

    if (count <= 0) return baseIcon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        baseIcon,
        Positioned(
          right: -4,
          top: -4,
          child: _AnimatedBadge(count: count),
        ),
      ],
    );
  }






  String _accountRoleLabel(UserRole? r) {
    switch (r) {
      case UserRole.admin:
        return 'أدمن (مراجعة فقط)';
      case UserRole.seller:
        return 'بائع';
      case UserRole.buyer:
        return 'مشتري';
      default:
        return 'غير معروف';
    }
  }

  Widget _roleBanner(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isAdmin = UserSession.isAdmin;
    final isSellerNow = UserSession.isSellerNow;
    final canSwitchToBuyer = UserSession.canSwitchToBuyer;
    final canSwitchToSeller = UserSession.canSwitchToSeller;
    final accountRole = _accountRoleLabel(UserSession.authRole);
    final name = UserSession.username ?? 'User';

    // حساب مشتري فقط (مايقدرش يبدّل لوضع بائع)
    final isPureBuyer =
        !isAdmin && !UserSession.canSell && UserSession.authRole == UserRole.buyer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // سطر الترحيب
          Row(
            children: [
              const Icon(Icons.account_circle_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'مرحباً $name',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // شيبس "الوضع الحالي" + "دور الحساب" جنب بعض
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    isAdmin
                        ? 'لوحة إدارة'
                        : 'الوضع: ${isSellerNow ? 'بائع' : 'مشتري'}',
                  ),
                  avatar: Icon(
                    isAdmin
                        ? Icons.admin_panel_settings_outlined
                        : (isSellerNow
                        ? Icons.storefront
                        : Icons.shopping_bag_outlined),
                  ),
                ),
                Chip(
                  label: Text('دور الحساب: $accountRole'),
                  avatar: const Icon(Icons.verified_user_outlined),
                ),
              ],
            ),
          ),

          // أزرار التبديل بين بائع/مشتري (لو ينفع يبدّل فعلاً فقط)
          if (!isAdmin && (canSwitchToBuyer || canSwitchToSeller)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (canSwitchToBuyer)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        UserSession.switchToBuyer();
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم التبديل إلى وضع مشتري'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('التبديل إلى مشتري'),
                    ),
                  ),
                if (canSwitchToBuyer && canSwitchToSeller)
                  const SizedBox(width: 8),
                if (canSwitchToSeller)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        UserSession.switchToSeller();
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم الرجوع إلى وضع بائع'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.storefront),
                      label: const Text('الرجوع إلى بائع'),
                    ),
                  ),
              ],
            ),
          ],

          // رسالة خفيفة لحساب المشتري فقط (من غير زحمة ولا أزرار باينة مقفولة)
          if (isPureBuyer) ...[
            const SizedBox(height: 6),
            Text(
              'هذا الحساب مسجّل كمشتري فقط.',
              style: TextStyle(
                fontSize: 12,
                color: cs.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }


  /// 🔹 Admin section (أنا سايبه من الكود الجديد زي ما هو لأنه شغال مظبوط عندك)
  Widget _adminModeration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final pendingProducts = store.pending();
    final pendingSellers = UserStore().pendingSellers();

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // زرارين فوق: إدارة الطلبات + إدارة طلبات الونش
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

          // TabBar بالعناوين الجديدة
          TabBar(
            labelColor: cs.primary,
            tabs: const [
              Tab(child: FittedBox(child: Text('مراجعة المنتجات'))),
              Tab(child: FittedBox(child: Text('اعتماد البائعين'))),
              Tab(child: FittedBox(child: Text('اعتماد شركات الأوناش'))),
              Tab(child: FittedBox(child: Text('حسابات الأوناش'))),
            ],
          ),
          const SizedBox(height: 8),

          // محتوى التابات
          Expanded(
            child: TabBarView(
              children: [
                // 1) مراجعة المنتجات (نفس الكود القديم)
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
                          const Text('لوحة مراجعة المنتجات',
                              textDirection: TextDirection.rtl),
                          const SizedBox(height: 6),
                          Text('في الانتظار: ${pendingProducts.length}',
                              textDirection: TextDirection.rtl),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: pendingProducts.isEmpty
                          ? const Center(
                        child: Text('لا توجد عناصر قيد المراجعة'),
                      )
                          : ListView.separated(
                        itemCount: pendingProducts.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final it = pendingProducts[i];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      _thumb(it.imageUrl),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(it.title,
                                                textDirection:
                                                TextDirection.rtl),
                                            const SizedBox(height: 4),
                                            Text(
                                              'رقم: ${it.id} • البائع: ${it.seller}\n'
                                                  'البراند: ${kBrandName[it.brand]} • الموديل: ${it.model}\n'
                                                  'السنوات: ${it.years.join(', ')} • المخزون: ${it.stock}\n'
                                                  '${it.description}',
                                              textDirection:
                                              TextDirection.rtl,
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
                                              _rejectItem(it.id),
                                          icon: const Icon(Icons.block,
                                              color: Colors.red),
                                          label: const Text(
                                            'رفض',
                                            style: TextStyle(
                                                color: Colors.red),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: () =>
                                              _approveItem(it.id),
                                          icon: const Icon(Icons.check),
                                          label:
                                          const Text('موافقة'),
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

                // 2) اعتماد البائعين (نفس القديم)
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
                          const Text('طلبات تسجيل كبائع (Pending)',
                              textDirection: TextDirection.rtl),
                          const SizedBox(height: 6),
                          Text('في الانتظار: ${pendingSellers.length}',
                              textDirection: TextDirection.rtl),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: pendingSellers.isEmpty
                          ? const Center(
                        child: Text(
                            'لا توجد طلبات بائعين قيد المراجعة'),
                      )
                          : ListView.separated(
                        itemCount: pendingSellers.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final s = pendingSellers[i];
                          return Card(
                            child: Padding(
                              padding:
                              const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                      child:
                                      Icon(Icons.storefront)),
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
                                              fontWeight:
                                              FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Email: ${s.email}\nPhone: ${s.phone}',
                                          textDirection:
                                          TextDirection.rtl,
                                        ),
                                        _DocLink(
                                          label: 'CR',
                                          url: s.commercialRegUrl,
                                          icon: Icons
                                              .picture_as_pdf_outlined,
                                        ),
                                        _DocLink(
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
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'رفض',
                                        onPressed: () {
                                          UserStore()
                                              .rejectSeller(
                                              s.email);
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
                                          UserStore()
                                              .approveSeller(
                                              s.email);
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

                // 3) اعتماد شركات الأوناش (هو الـ Tab القديم AdminTowRequestsTab)
                const AdminTowRequestsTab(),

                // 4) حسابات الأوناش (الشركات المسجلة + تفعيل/تعطيل/حذف)
                const AdminWinchAccountsTab(),
              ],
            ),
          ),
        ],
      ),
    );
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

  /// 🔹 واجهة البائع — رجعتها لنفس شكل الكود القديم (Column + Expanded + TabBarView)
  Widget _sellerSection(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // الهوية المستخدمة للبائع (زي ما بتستخدمها في أماكن تانية)
    final sellerId = UserSession.username ?? 'Seller';

    return Column(
      children: [
        // ====== الهيدر (صورة + زر إضافة منتج) ======
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              child: Icon(
                Icons.person,
                size: 50,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
            FilledButton.icon(
              onPressed: _openNewProductSheet,
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ====== تبويبات المنتجات من الفايربيز ======
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'قيد المراجعة'),
                      Tab(text: 'المقبولة'),
                      Tab(text: 'المرفوضة'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<List<CatalogProduct>>(
                      stream: productsRepo.watchAllSellerProducts(sellerId),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snap.hasError) {
                          return const Center(
                            child: Text(
                              'حدث خطأ أثناء تحميل المنتجات',
                              textAlign: TextAlign.right,
                            ),
                          );
                        }

                        final all = snap.data ?? const <CatalogProduct>[];

                        final pending = all
                            .where((p) => p.status == ProductStatus.pending)
                            .toList();
                        final approved = all
                            .where((p) => p.status == ProductStatus.approved)
                            .toList();
                        final rejected = all
                            .where((p) => p.status == ProductStatus.rejected)
                            .toList();

                        return TabBarView(
                          children: [
                            _sellerList(pending),
                            _sellerList(approved),
                            _RejectedList(list: rejected),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ====== أزرار إدارة المخزون + طلبات العملاء ======
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SellerInventoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('إدارة المخزون'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SellerOrdersScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('طلبات العملاء'),
              ),
            ),
          ],
        ),
      ],
    );
  }


// قائمة المنتجات (قيد المراجعة / المقبولة)
  Widget _sellerList(List<CatalogProduct> list) {
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'لا توجد منتجات في هذا التبويب حالياً',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final p = list[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                p.title.isNotEmpty ? p.title[0].toUpperCase() : '?',
              ),
            ),
            title: Text(
              p.title,
              textAlign: TextAlign.right,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'الماركة: ${kBrandName[p.brand]} • الموديل: ${p.model}',
                  textAlign: TextAlign.right,
                ),
                Text(
                  'السعر: ${p.price.toStringAsFixed(2)} جنيه • المخزون: ${p.stock}',
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                p.status == ProductStatus.approved
                    ? 'مقبول'
                    : (p.status == ProductStatus.pending ? 'قيد المراجعة' : 'مرفوض'),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openNewProductSheet() async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageCtrl = TextEditingController();

    CarBrand brand = CarBrand.nissan;
    String model = kModelsByBrand[CarBrand.nissan]!.first;
    final Set<int> selectedYears = {};
    final stockCtrl = TextEditingController(text: '1');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        final insets = MediaQuery.of(context).viewInsets;
        return Padding(
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: StatefulBuilder(
                builder: (context, setSheet) {
                  final models = kModelsByBrand[brand]!;
                  if (!models.contains(model)) model = models.first;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('إضافة منتج جديد',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(
                              labelText: 'اسم المنتج (مثال: فانوس أمامي)',
                              border: OutlineInputBorder()),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'مطلوب'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'السعر',
                              border: OutlineInputBorder()),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'مطلوب';
                            }
                            final d = double.tryParse(v);
                            if (d == null || d <= 0) return 'سعر غير صالح';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: descCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                              labelText:
                              'الوصف (مثال: يصلح لأعوام 2023-2025 نفس الشكل)',
                              border: OutlineInputBorder()),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'مطلوب'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<CarBrand>(
                          value: brand,
                          decoration: const InputDecoration(
                              labelText: 'البراند',
                              border: OutlineInputBorder()),
                          items: CarBrand.values
                              .map((b) => DropdownMenuItem(
                              value: b, child: Text(kBrandName[b]!)))
                              .toList(),
                          onChanged: (b) {
                            if (b == null) return;
                            setSheet(() {
                              brand = b;
                              model = kModelsByBrand[brand]!.first;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: model,
                          decoration: const InputDecoration(
                              labelText: 'الموديل',
                              border: OutlineInputBorder()),
                          items: kModelsByBrand[brand]!
                              .map((m) => DropdownMenuItem<String>(
                              value: m, child: Text(m)))
                              .toList(),
                          onChanged: (m) =>
                              setSheet(() => model = m ?? model),
                        ),
                        const SizedBox(height: 10),
                        const Text('السنوات المناسبة',
                            textDirection: TextDirection.rtl),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: kYears
                              .map(
                                (y) => FilterChip(
                              label: Text('$y'),
                              selected: selectedYears.contains(y),
                              onSelected: (sel) => setSheet(() {
                                if (sel) {
                                  selectedYears.add(y);
                                } else {
                                  selectedYears.remove(y);
                                }
                              }),
                            ),
                          )
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'المخزون المتاح',
                              border: OutlineInputBorder()),
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 0) return 'قيمة غير صالحة';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: imageCtrl,
                          decoration: const InputDecoration(
                              labelText: 'رابط الصورة (اختياري)',
                              hintText: 'https://...',
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            if (selectedYears.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text('اختر سنة واحدة على الأقل'),
                                ),
                              );
                              return;
                            }
                            final sellerName =
                                UserSession.username ?? 'Seller';
                            final id =
                                'P-${DateTime.now().millisecondsSinceEpoch}';
                            MockStore().submit(
                              ModerationProduct(
                                id: id,
                                title: titleCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                                seller: sellerName,
                                price:
                                double.parse(priceCtrl.text.trim()),
                                imageUrl: imageCtrl.text.trim().isEmpty
                                    ? null
                                    : imageCtrl.text.trim(),
                                createdAt: DateTime.now(),
                                brand: brand,
                                model: model,
                                years: selectedYears.toList()..sort(),
                                stock: int.parse(stockCtrl.text.trim()),
                                status: ProductStatus.pending,
                              ),
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'تم إرسال المنتج للمراجعة'),
                              ),
                            );
                            setState(() {});
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('إرسال للمراجعة'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🔹 واجهة المشتري — رجعتها لشكل القديم (Container + "طلباتي" + OrdersSection + زر اذهب للتسوق)
  /// 🔹 واجهة المشتري — فيها طلبات المنتجات + طلبات الونش
  Widget _buyerSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final u = UserStore().currentUser;

    if (u == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final uid = u.id;
    final displayName =
    (u.name.isNotEmpty ? u.name : (UserSession.username ?? 'عميلنا'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // كارت بسيط للمشتري (بدل "مرحباً أنت في وضع المشتري" الكبيرة)


        const SizedBox(height: 12),

        // Tabs: مشترياتي / طلبات الونش
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
                      // تبويب 1: طلبات المشتريات
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: OrdersSection(
                          key: ValueKey('buyer-orders-$uid'),
                          mode: OrdersSectionMode.buyer,
                          userId: uid,
                        ),
                      ),

                      // تبويب 2: طلبات الونش
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: _BuyerTowRequestsCard(userId: uid),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // زر "اذهب للتسوق"
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _goTo(const HomeScreen()),
            icon: const Icon(Icons.storefront),
            label: const Text('اذهب للتسوق'),
          ),
        ),
      ],
    );
  }









  @override
  Widget build(BuildContext context) {
    final userStore = UserStore();
    final user = userStore.currentUser;

    // 👈 لو Guest أو مفيش يوزر مسجّل أو الـ Session مش لوجين → رجّعه لشاشة اللوجين
    if (userStore.isGuest || !UserSession.loggedIn || user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // من هنا إنت أكيد logged in بحساب حقيقي
    final isAdmin = UserSession.isAdmin;
    final isSeller = UserSession.isSellerNow;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          centerTitle: true,
          actions: [
            if (UserStore().currentUser?.towCompanyId != null)
              StreamBuilder<List<TowRequestDoc>>(
                stream: towRequestsRepo.watchCompanyRequests(
                  UserStore().currentUser!.towCompanyId!,
                ),
                builder: (_, snap) {
                  final list = snap.data ?? const <TowRequestDoc>[];

                  // أول ما الطلبات توصل لصفحة الحساب، علّمها إنها اتشوفت
                  final unseen = list.where((r) => !r.userSeen).toList();
                  if (unseen.isNotEmpty) {
                    Future.microtask(() async {
                      for (final r in unseen) {
                        try {
                          await towRequestsRepo.markUserSeen(requestId: r.id);
                        } catch (_) {
                          // تجاهل الأخطاء البسيطة
                        }
                      }
                    });
                  }

                  final unread = list.where((r) => !r.companySeen).length;

                  return IconButton(
                    tooltip: 'لوحة مزود الونش',
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.build_circle_outlined),
                        if (unread > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  unread > 9 ? '9+' : '$unread',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () {
                      final cid = UserStore().currentUser!.towCompanyId!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TowOperatorPanel(companyId: cid),
                        ),
                      );
                    },
                  );
                },
              ),

            if (UserSession.loggedIn)
              IconButton(
                tooltip: 'تسجيل الخروج',
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              )
            else
              IconButton(
                tooltip: 'تسجيل الدخول',
                icon: const Icon(Icons.login),
                onPressed: _login,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _roleBanner(context),
              const SizedBox(height: 16),
              Expanded(
                child: isAdmin
                    ? _adminModeration(context)
                    : (isSeller
                    ? _sellerSection(context)
                    : _buyerSection(context)),
              ),
            ],
          ),
        ),
        bottomNavigationBar: StreamBuilder<int>(
          stream: towNotificationCountStreamForCurrentUser(),
          builder: (_, snap) {
            final count = snap.data ?? 0;
            return _buildBottomBar(count);
          },
        ),
      ),
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
        appBar: AppBar(
          title: const Text('إدارة الطلبات'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AdminOrdersTab(
            repo: ordersRepo, // ✅ Firestore repo
          ),
        ),
      ),
    );
  }
}

/// Badge صغيرة متحركة
class _AnimatedBadge extends StatelessWidget {
  final int count;

  const _AnimatedBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final display = count > 9 ? '9+' : '$count';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Container(
        key: ValueKey(display),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(999),
        ),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        child: Text(
          display,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


class SellerInventoryScreen extends StatelessWidget {
  const SellerInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerId = UserSession.username ?? 'Seller';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المخزون'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SellerInventoryTab(sellerId: sellerId),
        ),
      ),
    );
  }
}



class _RejectedList extends StatelessWidget {
  final List<CatalogProduct> list;

  const _RejectedList({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'لا توجد منتجات مرفوضة حالياً',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final p = list[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: Text(
              p.title,
              textAlign: TextAlign.right,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'الماركة: ${kBrandName[p.brand]} • الموديل: ${p.model}',
                  textAlign: TextAlign.right,
                ),
                Text(
                  'السعر: ${p.price.toStringAsFixed(2)} جنيه',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  p.rejectionReason == null || p.rejectionReason!.trim().isEmpty
                      ? 'سبب الرفض غير محدد'
                      : 'سبب الرفض: ${p.rejectionReason}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class _BuyerTowRequestsCard extends StatelessWidget {
  bool _canCancel(TowRequestStatus status) {
    // الحالات اللي لسا نقدر نلغي فيها الطلب
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
          const SnackBar(
            content: Text('تم إلغاء طلب الونش بنجاح'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر إلغاء الطلب: $e'),
        ),
      );
    }
  }

  final String userId;

  const _BuyerTowRequestsCard({
    super.key,
    required this.userId,
  });

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

            final list = snap.data ?? const <TowRequestDoc>[];

            // ✅ علّم الطلبات الجديدة كمقروءة بعد أول عرض
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
}




Widget _profileIconWithBadge({
  required int count,
  required bool selected,
}) {
  final baseIcon = Icon(
    selected ? Icons.person : Icons.person_outline,
  );

  if (count <= 0) return baseIcon;

  return Stack(
    clipBehavior: Clip.none,
    children: [
      baseIcon,
      Positioned(
        right: -4,
        top: -4,
        child: _AnimatedBadge(count: count),
      ),
    ],
  );
}


class AdminTowRequestsTab extends StatelessWidget {
  const AdminTowRequestsTab({super.key});

  Future<void> _openExternal(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('رابط غير صالح')));
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
              '$label: ${has ? url! : '—'}',
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (has) ...[
            IconButton(
              tooltip: 'معاينة',
              onPressed: () => _openImagePreview(context, url!, title: label),
              icon: const Icon(Icons.visibility_outlined),
            ),
            IconButton(
              tooltip: 'فتح في المتصفح',
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
              ? const Center(
            child: Text('لا توجد طلبات قيد المراجعة'),
          )
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
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                              if (a.commercialRegUrl
                                  ?.isNotEmpty ??
                                  false)
                                _docLink(
                                  context: context,
                                  label: 'رابط السجل التجاري',
                                  url: a.commercialRegUrl!,
                                  icon: Icons
                                      .picture_as_pdf_outlined,
                                ),
                              if (a.taxCardUrl?.isNotEmpty ??
                                  false)
                                _docLink(
                                  context: context,
                                  label: 'رابط البطاقة الضريبية',
                                  url: a.taxCardUrl!,
                                  icon: Icons
                                      .picture_as_pdf_outlined,
                                ),
                            ],
                            if (a.rejectReason != null &&
                                a.status ==
                                    SellerStatus.rejected)
                              Text(
                                'مرفوض: ${a.rejectReason}',
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
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
                              final ctrl =
                              TextEditingController();
                              final ok =
                              await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('سبب الرفض'),
                                  content: TextField(
                                    controller: ctrl,
                                    maxLines: 3,
                                    decoration:
                                    const InputDecoration(
                                      border:
                                      OutlineInputBorder(),
                                      hintText:
                                      'سبب الرفض (اختياري)',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(
                                              context, false),
                                      child: const Text('إلغاء'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(
                                              context, true),
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
                                (context as Element)
                                    .markNeedsBuild();
                              }
                            },
                            icon: const Icon(Icons.block,
                                color: Colors.red),
                          ),
                          IconButton(
                            tooltip: 'موافقة',
                            onPressed: () async {
                              await UserStore().approveTow(a.id);
                              (context as Element)
                                  .markNeedsBuild();
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

extension SellerAdminHelpers on UserStore {
  List<AppUser> pendingSellers() {
    return usersRepo.allUsers
        .where((u) =>
    u.role == AppUserRole.seller &&
        (u.approved == false))
        .toList();
  }

  void approveSeller(String email) {
    try {
      final u = usersRepo.allUsers.firstWhere(
            (u) => u.email == email && u.role == AppUserRole.seller,
      );

      final updated = u.copyWith(
        approved: true,
        canSell: true,
      );

      usersRepo.updateUser(updated);
    } catch (_) {}
  }

  void rejectSeller(String email) {
    try {
      final u = usersRepo.allUsers.firstWhere(
            (u) => u.email == email && u.role == AppUserRole.seller,
      );

      final updated = u.copyWith(
        approved: false,
        canSell: false,
      );

      usersRepo.updateUser(updated);
    } catch (_) {}
  }
}
