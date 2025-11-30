import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/services/user_session.dart';
import 'package:auto_spare/view/screens/tow_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

import 'package:auto_spare/view/screens/tow_operator_panel.dart';
import 'package:auto_spare/services/tow_badge_stream.dart';
import 'package:auto_spare/services/tow_badge_controller.dart';
import 'package:auto_spare/services/tow_requests.dart';

import 'admin_profile_tab.dart';
import 'seller_profile_tab.dart';
import 'buyer_profile_tab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
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

    TowBadgeController().refreshForCurrentUser();
  }

  void _goTo(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void _logout() {
    UserStore().currentUser = null;
    UserSession.signOut();

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
          child: const _AnimatedBadge(count: 0),
        ),
        Positioned(
          right: -4,
          top: -4,
          child: _AnimatedBadge(count: count),
        ),
      ],
    );
  }

  Widget _buildBottomBar(int badgeCount) {
    return NavigationBar(
      selectedIndex: _bottomIndex,
      onDestinationSelected: (i) {
        if (_bottomIndex == i) return;
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

  Widget _roleBanner(BuildContext context, AppUser user) {
    final cs = Theme.of(context).colorScheme;

    final bool isAdminAccount = user.role == AppUserRole.admin;
    final bool isSellerAccount = user.role == AppUserRole.seller;

    final bool isSellerNow =
        isSellerAccount && UserSession.isSellerNow;

    final bool canSwitchToBuyer =
        isSellerAccount && UserSession.canSwitchToBuyer;
    final bool canSwitchToSeller =
        isSellerAccount && UserSession.canSwitchToSeller;

    final accountRole = _accountRoleLabel(UserSession.authRole);
    final name = UserSession.username ?? 'User';

    final bool isPureBuyer =
        !isAdminAccount &&
            !isSellerAccount &&
            UserSession.authRole == UserRole.buyer;

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
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    isAdminAccount
                        ? 'لوحة إدارة'
                        : 'الوضع: ${isSellerNow ? 'بائع' : 'مشتري'}',
                  ),
                  avatar: Icon(
                    isAdminAccount
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
          if (!isAdminAccount &&
              isSellerAccount &&
              (canSwitchToBuyer || canSwitchToSeller)) ...[
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

  @override
  Widget build(BuildContext context) {
    final userStore = UserStore();
    final user = userStore.currentUser;

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

    final bool isAdminRole = user.role == AppUserRole.admin;
    final bool isSellerRole = user.role == AppUserRole.seller;

    final bool isAdmin = isAdminRole;
    final bool isSeller = isSellerRole && UserSession.isSellerNow;

    final Widget mainTab = isAdmin
        ? const AdminProfileTab()
        : (isSeller
        ? const SellerProfileTab()
        : BuyerProfileTab(userId: user.id));

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

                  final unseen = list.where((r) => !r.companySeen).toList();
                  if (unseen.isNotEmpty) {
                    Future.microtask(() async {
                      for (final r in unseen) {
                        try {
                          await towRequestsRepo
                              .markCompanySeen(requestId: r.id);
                        } catch (_) {}
                      }
                    });
                  }

                  final unread =
                      list.where((r) => !r.companySeen).length;

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
        body: LayoutBuilder(
          builder: (context, constraints) {

            final isLandscape =
                constraints.maxWidth > constraints.maxHeight;

            double tabHeight;
            if (isLandscape) {

              tabHeight = constraints.maxHeight - 16 - 190;
            } else {
              tabHeight = constraints.maxHeight - 16 - 160;
            }

            if (tabHeight < 220) tabHeight = 220;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _roleBanner(context, user),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: tabHeight,
                    child: mainTab,
                  ),
                ],
              ),
            );
          },
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
