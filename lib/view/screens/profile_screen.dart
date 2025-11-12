import 'package:auto_spare/view/screens/tow_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

enum UserRole { buyer, seller, admin }

class UserSession {
  static bool loggedIn = false;
  static String? username;
  static UserRole? authRole;

  static bool get isAdmin => authRole == UserRole.admin;
  static bool get canSell => authRole == UserRole.seller;

  static UserRole currentRole = UserRole.buyer;

  static void initFromProfile({required String name, required UserRole role}) {
    username = name;
    authRole = role;
    loggedIn = true;
    currentRole = canSell ? UserRole.seller : UserRole.buyer;
  }

  static bool get isSellerNow => !isAdmin && currentRole == UserRole.seller;
  static bool get isBuyerNow => !isAdmin && currentRole == UserRole.buyer;

  static bool get canSwitchToSeller => canSell && isBuyerNow;
  static bool get canSwitchToBuyer => isSellerNow;

  static void switchToBuyer() {
    if (!isAdmin && isSellerNow) currentRole = UserRole.buyer;
  }

  static void switchToSeller() {
    if (!isAdmin && canSwitchToSeller) currentRole = UserRole.seller;
  }

  static void signOut() {
    loggedIn = false;
    username = null;
    authRole = null;
    currentRole = UserRole.buyer;
  }
}

enum ProductStatus { pending, approved, rejected }

class ModerationProduct {
  final String id;
  final String title;
  final String description;
  final String seller;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;
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

  void approve(String id) {
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _products[idx].status = ProductStatus.approved;
      _products[idx].rejectReason = null;
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

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});
  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage>
    with TickerProviderStateMixin {
  final store = MockStore();
  int _bottomIndex = 4;

  void _goTo(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void _logout() {
    UserSession.signOut();
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
    store.approve(id);
    setState(() {});
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('تمت الموافقة على $id')));
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
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('رفض')),
        ],
      ),
    );
    if (ok == true) {
      final reason =
      reasonCtrl.text.trim().isEmpty ? 'غير مُحدد' : reasonCtrl.text.trim();
      store.reject(id, reason);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفض $id • السبب: $reason')),
      );
    }
  }

  Widget _buildBottomBar() {
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
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية'),
        NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'التصنيفات'),
        NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'الونش'),
        NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'السلة'),
        NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي'),
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
    final isAdmin = UserSession.isAdmin;
    final isSellerNow = UserSession.isSellerNow;
    final canSwitchToBuyer = UserSession.canSwitchToBuyer;
    final canSwitchToSeller = UserSession.canSwitchToSeller;
    final accountRole = _accountRoleLabel(UserSession.authRole);
    final name = UserSession.username ?? 'User';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.account_circle_outlined),
            const SizedBox(width: 8),
            Text('مرحبا $name'),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(isAdmin
                    ? 'لوحة إدارة'
                    : 'الوضع الحالي: ${isSellerNow ? 'بائع' : 'مشتري'}'),
                avatar: Icon(isAdmin
                    ? Icons.admin_panel_settings_outlined
                    : (isSellerNow
                    ? Icons.storefront
                    : Icons.shopping_bag_outlined)),
              ),
              Chip(
                label: Text('دور الحساب: $accountRole'),
                avatar: const Icon(Icons.verified_user_outlined),
              ),
            ],
          ),
          if (!isAdmin) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: canSwitchToBuyer
                      ? () {
                    UserSession.switchToBuyer();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('تم التبديل إلى وضع مشتري')),
                    );
                  }
                      : null,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('التبديل إلى مشتري'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: canSwitchToSeller
                      ? () {
                    UserSession.switchToSeller();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('تم الرجوع إلى وضع بائع')),
                    );
                  }
                      : null,
                  icon: const Icon(Icons.storefront),
                  label: const Text('الرجوع إلى بائع'),
                ),
              ],
            ),
            if (!UserSession.canSell && UserSession.isBuyerNow) ...[
              const SizedBox(height: 6),
              const Text(
                  'هذا الحساب مسجّل كمشتري فقط — لا يمكن الترقية إلى بائع.'),
            ],
          ],
        ],
      ),
    );
  }

  Widget _adminModeration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pending = store.pending();
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
              const Text('لوحة مراجعة المنتجات'),
              const SizedBox(height: 6),
              Text('في الانتظار: ${pending.length}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: pending.isEmpty
              ? const Center(child: Text('لا توجد عناصر قيد المراجعة'))
              : ListView.separated(
            itemCount: pending.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final it = pending[i];
              return Card(
                child: ListTile(
                  leading: _thumb(it.imageUrl),
                  title: Text(it.title),
                  subtitle: Text(
                      'رقم: ${it.id} • البائع: ${it.seller}\n${it.description}'),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _rejectItem(it.id),
                        icon: const Icon(Icons.block, color: Colors.red),
                        label: const Text('رفض',
                            style: TextStyle(color: Colors.red)),
                      ),
                      FilledButton.icon(
                        onPressed: () => _approveItem(it.id),
                        icon: const Icon(Icons.check),
                        label: const Text('موافقة'),
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

  Future<void> _openNewProductSheet() async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageCtrl = TextEditingController();

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
              child: SingleChildScrollView(
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
                          labelText: 'اسم المنتج', border: OutlineInputBorder()),
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'السعر', border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'مطلوب';
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
                          labelText: 'الوصف', border: OutlineInputBorder()),
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: imageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'رابط الصورة (اختياري)',
                        hintText: 'https://...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final sellerName = UserSession.username ?? 'Seller';
                        final id =
                            'P-${DateTime.now().millisecondsSinceEpoch}';
                        store.submit(
                          ModerationProduct(
                            id: id,
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            seller: sellerName,
                            price: double.parse(priceCtrl.text.trim()),
                            imageUrl: imageCtrl.text.trim().isEmpty
                                ? null
                                : imageCtrl.text.trim(),
                            createdAt: DateTime.now(),
                            status: ProductStatus.pending,
                          ),
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تم إرسال المنتج للمراجعة')),
                        );
                        setState(() {});
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('إرسال للمراجعة'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sellerSection(BuildContext context) {
    final theme = Theme.of(context);
    final name = UserSession.username ?? 'Seller';
    final tabController = TabController(length: 3, vsync: this);

    final pending = store.pending(seller: name);
    final approved = store.approved(seller: name);
    final rejected = store.rejected(seller: name);

    Widget listOf(List<ModerationProduct> list) {
      if (list.isEmpty) {
        return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('لا توجد عناصر'),
            ));
      }
      return ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final p = list[i];
          return Card(
            child: ListTile(
              leading: _thumb(p.imageUrl),
              title: Text(p.title),
              subtitle: Text('رقم: ${p.id}\n${p.description}'),
              isThreeLine: true,
              trailing: Text(
                p.status == ProductStatus.approved
                    ? 'مقبول'
                    : p.status == ProductStatus.rejected
                    ? 'مرفوض'
                    : 'قيد المراجعة',
                style: TextStyle(
                  color: p.status == ProductStatus.approved
                      ? Colors.green
                      : p.status == ProductStatus.rejected
                      ? Colors.red
                      : Colors.orange,
                ),
              ),
            ),
          );
        },
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              child:
              Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("لوحة البائع"),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: _openNewProductSheet,
              icon: const Icon(Icons.add),
              label: const Text("إضافة منتج"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              TabBar(
                controller: tabController,
                tabs: const [
                  Tab(text: 'قيد المراجعة'),
                  Tab(text: 'المقبولة'),
                  Tab(text: 'المرفوضة'),
                ],
              ),
              SizedBox(
                height: 320,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    listOf(pending),
                    listOf(approved),
                    _RejectedList(list: rejected),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buyerSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
          child: const Text('مرحباً! أنت في وضع المشتري'),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: const [
              ListTile(
                leading: Icon(Icons.receipt_long_outlined),
                title: Text('طلب #10023'),
                subtitle: Text('قيد المعالجة'),
              ),
              ListTile(
                leading: Icon(Icons.receipt_long_outlined),
                title: Text('طلب #10022'),
                subtitle: Text('مكتمل'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _goTo(const HomeScreen()),
            icon: const Icon(Icons.storefront),
            label: const Text("اذهب للتسوق"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!UserSession.loggedIn) {
      return const LoginScreen();
    }

    final isAdmin = UserSession.isAdmin;
    final isSeller = UserSession.isSellerNow;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الملف الشخصي"),
          centerTitle: true,
          actions: [
            if (UserSession.loggedIn)
              IconButton(
                  tooltip: 'تسجيل الخروج',
                  icon: const Icon(Icons.logout),
                  onPressed: _logout)
            else
              IconButton(
                  tooltip: 'تسجيل الدخول',
                  icon: const Icon(Icons.login),
                  onPressed: _login),
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
                    : (isSeller ? _sellerSection(context) : _buyerSection(context)),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}

class _RejectedList extends StatelessWidget {
  final List<ModerationProduct> list;
  const _RejectedList({required this.list});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const Center(child: Text('لا توجد عناصر'));
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final p = list[i];
        return Card(
          child: ListTile(
            leading:
            const CircleAvatar(child: Icon(Icons.report_gmailerrorred_outlined)),
            title: Text(p.title),
            subtitle: Text(
                'رقم: ${p.id}\n${p.description}\nسبب الرفض: ${p.rejectReason ?? '—'}'),
            isThreeLine: true,
            trailing: const Text('مرفوض', style: TextStyle(color: Colors.red)),
          ),
        );
      },
    );
  }
}
