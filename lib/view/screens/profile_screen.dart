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
import 'package:auto_spare/l10n/app_localizations.dart';

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
      case AppUserRole.winch:
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

  void _logout(AppLocalizations loc) {
    UserStore().currentUser = null;
    UserSession.signOut();

    TowBadgeController().refreshForCurrentUser();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _login() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Widget _profileIconWithBadge({required int count, required bool selected}) {
    final baseIcon = Icon(selected ? Icons.person : Icons.person_outline);

    if (count <= 0) return baseIcon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        baseIcon,
        const Positioned(right: -4, top: -4, child: _AnimatedBadge(count: 0)),
        Positioned(right: -4, top: -4, child: _AnimatedBadge(count: count)),
      ],
    );
  }

  Widget _buildBottomBar(int badgeCount, AppLocalizations loc) {
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
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: loc.nav_home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.grid_view_outlined),
          selectedIcon: const Icon(Icons.grid_view),
          label: loc.nav_categories,
        ),
        NavigationDestination(
          icon: const Icon(Icons.local_shipping_outlined),
          selectedIcon: const Icon(Icons.local_shipping),
          label: loc.nav_tow,
        ),
        NavigationDestination(
          icon: const Icon(Icons.shopping_cart_outlined),
          selectedIcon: const Icon(Icons.shopping_cart),
          label: loc.nav_cart,
        ),
        NavigationDestination(
          icon: _profileIconWithBadge(count: badgeCount, selected: false),
          selectedIcon: _profileIconWithBadge(
            count: badgeCount,
            selected: true,
          ),
          label: loc.nav_profile,
        ),
      ],
    );
  }

  String _accountRoleLabel(
    AppLocalizations loc,
    UserRole? r,
    AppUserRole dbRole,
  ) {
    if (dbRole == AppUserRole.winch) {
      return loc.profile_role_label_winch;
    }

    switch (r) {
      case UserRole.admin:
        return loc.profile_role_label_admin;
      case UserRole.seller:
        return loc.profile_role_label_seller;
      case UserRole.buyer:
        return loc.profile_role_label_buyer;
      default:
        return loc.profile_role_label_unknown;
    }
  }

  Widget _roleBanner(BuildContext context, AppUser user, AppLocalizations loc) {
    final cs = Theme.of(context).colorScheme;

    final bool isAdminAccount = user.role == AppUserRole.admin;
    final bool isSellerAccount = user.role == AppUserRole.seller;
    final bool isWinchAccount = user.role == AppUserRole.winch;

    final bool isSellerNow = isSellerAccount && UserSession.isSellerNow;

    final bool canSwitchToBuyer =
        isSellerAccount && UserSession.canSwitchToBuyer;
    final bool canSwitchToSeller =
        isSellerAccount && UserSession.canSwitchToSeller;

    final accountRole = _accountRoleLabel(loc, UserSession.authRole, user.role);
    final name = UserSession.username ?? 'User';

    final bool isPureBuyer =
        !isAdminAccount &&
        !isSellerAccount &&
        !isWinchAccount &&
        UserSession.authRole == UserRole.buyer;

    late final String modeText;
    late final IconData modeIcon;

    if (isAdminAccount) {
      modeText = loc.profile_mode_admin_label;
      modeIcon = Icons.admin_panel_settings_outlined;
    } else if (isWinchAccount) {
      modeText = loc.profile_mode_winch_label;
      modeIcon = Icons.local_shipping_outlined;
    } else {
      modeText =
          '${loc.profile_mode_prefix} ${isSellerNow ? loc.profile_mode_seller_label : loc.profile_mode_buyer_label}';
      modeIcon = isSellerNow ? Icons.storefront : Icons.shopping_bag_outlined;
    }

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
                  '${loc.profile_greeting_prefix} $name',
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
                Chip(label: Text(modeText), avatar: Icon(modeIcon)),
                Chip(
                  label: Text(
                    '${loc.profile_role_chip_label_prefix} $accountRole',
                  ),
                  avatar: const Icon(Icons.verified_user_outlined),
                ),
              ],
            ),
          ),

          if (!isAdminAccount &&
              isSellerAccount &&
              !isWinchAccount &&
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
                          SnackBar(
                            content: Text(
                              loc.profile_switched_to_buyer_message,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.swap_horiz),
                      label: Text(loc.profile_switch_to_buyer_button),
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
                          SnackBar(
                            content: Text(
                              loc.profile_switched_to_seller_message,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.storefront),
                      label: Text(loc.profile_switch_to_seller_button),
                    ),
                  ),
              ],
            ),
          ],

          if (isWinchAccount) ...[
            const SizedBox(height: 6),
            Text(
              loc.profile_winch_hint_text,
              style: TextStyle(fontSize: 12, color: cs.outline),
              textAlign: TextAlign.right,
            ),
          ],

          if (isPureBuyer) ...[
            const SizedBox(height: 6),
            Text(
              loc.profile_pure_buyer_hint_text,
              style: TextStyle(fontSize: 12, color: cs.outline),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final userStore = UserStore();
    final user = userStore.currentUser;

    if (userStore.isGuest || !UserSession.loggedIn || user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isAdminRole = user.role == AppUserRole.admin;
    final bool isSellerRole = user.role == AppUserRole.seller;
    final bool isWinchRole = user.role == AppUserRole.winch;

    final bool isAdmin = isAdminRole;
    final bool isSeller = isSellerRole && UserSession.isSellerNow;

    final Widget mainTab = isAdmin
        ? const AdminProfileTab()
        : (isSeller
              ? const SellerProfileTab()
              : BuyerProfileTab(userId: user.id));

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.profile_app_bar_title),
          centerTitle: true,
          actions: [
            if (user.towCompanyId != null && isWinchRole)
              StreamBuilder<List<TowRequestDoc>>(
                stream: towRequestsRepo.watchCompanyRequests(
                  user.towCompanyId!,
                ),
                builder: (_, snap) {
                  final list = snap.data ?? const <TowRequestDoc>[];

                  final unseen = list.where((r) => !r.companySeen).toList();
                  if (unseen.isNotEmpty) {
                    Future.microtask(() async {
                      for (final r in unseen) {
                        try {
                          await towRequestsRepo.markCompanySeen(
                            requestId: r.id,
                          );
                        } catch (_) {}
                      }
                    });
                  }

                  final unread = list.where((r) => !r.companySeen).length;

                  return IconButton(
                    tooltip: loc.profile_winch_requests_button_tooltip,
                    onPressed: () {
                      final cid = user.towCompanyId!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TowOperatorPanel(companyId: cid),
                        ),
                      );
                    },
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.local_shipping_outlined),
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
                        const SizedBox(width: 4),
                        Text(
                          loc.profile_winch_requests_button_label,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (UserSession.loggedIn)
              IconButton(
                tooltip: loc.profile_logout_tooltip,
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(loc),
              )
            else
              IconButton(
                tooltip: loc.profile_login_tooltip,
                icon: const Icon(Icons.login),
                onPressed: _login,
              ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

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
                  _roleBanner(context, user, loc),
                  const SizedBox(height: 16),
                  SizedBox(height: tabHeight, child: mainTab),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: StreamBuilder<int>(
          stream: towNotificationCountStreamForCurrentUser(),
          builder: (_, snap) {
            final count = snap.data ?? 0;
            return _buildBottomBar(count, loc);
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
