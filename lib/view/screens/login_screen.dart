import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:auto_spare/services/user_session.dart';
import 'package:auto_spare/view/screens/home_screen.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_buttons.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_form_field.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:auto_spare/main.dart';
import 'package:auto_spare/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRemember = prefs.getBool('remember_me') ?? false;

    if (savedRemember) {
      final savedEmail = prefs.getString('saved_email') ?? '';
      final savedPass = prefs.getString('saved_password') ?? '';

      setState(() {
        _rememberMe = true;
        _userController.text = savedEmail;
        _passwordController.text = savedPass;
      });
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  UserRole _mapRole(AppUserRole r) {
    switch (r) {
      case AppUserRole.admin:
        return UserRole.admin;
      case AppUserRole.seller:
      case AppUserRole.winch:
        return UserRole.seller;
      default:
        return UserRole.buyer;
    }
  }

  Future<AppUser?> _loginByEmail(String email, String pass) {
    return usersRepo.signInWithEmailAndPassword(email, pass);
  }

  Future<void> _handleSignIn() async {
    final loc = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.login_fix_errors_message)));
      return;
    }

    final email = _userController.text.trim();
    final pass = _passwordController.text.trim();

    final u = await _loginByEmail(email, pass);
    if (!mounted) return;

    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.login_invalid_credentials_message)),
      );
      return;
    }

    if (u.role == AppUserRole.winch && !u.approved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.login_winch_not_approved_message)),
      );
      return;
    }

    UserStore().setLoggedInUser(u);

    UserSession.initFromProfile(
      name: u.name,
      email: u.email,
      phone: u.phone,
      role: _mapRole(u.role),
      canSell: u.canSell,
      canTow: u.canTow,
      towCompanyId: u.towCompanyId,
    );

    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', pass);
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _continueAsGuest() {
    final loc = AppLocalizations.of(context);

    UserStore().setGuest();
    UserSession.initFromProfile(
      name: loc.login_guest_name,
      role: UserRole.buyer,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF065F46)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        _buildAnimatedHeader(context, loc, isArabic),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),

                          child: Theme(
                            data: theme.copyWith(
                              cardColor: isDarkTheme
                                  ? const Color(0xFF020617)
                                  : Colors.white,
                              inputDecorationTheme: theme.inputDecorationTheme
                                  .copyWith(
                                    filled: true,
                                    fillColor: isDarkTheme
                                        ? const Color(0xFF0B1120)
                                        : const Color(0xFFF5F5F5),
                                    labelStyle: TextStyle(
                                      color: isDarkTheme
                                          ? Colors.grey[300]
                                          : Colors.grey[800],
                                    ),
                                    hintStyle: TextStyle(
                                      color: isDarkTheme
                                          ? Colors.grey[400]
                                          : Colors.grey[500],
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: isDarkTheme
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF4CAF50),
                                        width: 1.6,
                                      ),
                                    ),
                                  ),
                            ),
                            child: Card(
                              elevation: 18,
                              shadowColor: Colors.black.withValues(alpha: .35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        loc.login_title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: isDarkTheme
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        loc.login_subtitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDarkTheme
                                              ? Colors.grey.withValues(
                                                  alpha: .75,
                                                )
                                              : Colors.grey.withValues(
                                                  alpha: .6,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 18),

                                      CustomFormField(
                                        controller: _userController,
                                        labelText: loc.login_email_label,
                                        hintText: loc.login_email_hint,
                                        icon: Icons.email_outlined,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                            ? loc.login_required
                                            : null,
                                      ),
                                      const SizedBox(height: 14),

                                      CustomFormField(
                                        controller: _passwordController,
                                        labelText: loc.login_password_label,
                                        hintText: loc.login_password_hint,
                                        icon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                            ? loc.login_required
                                            : null,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _rememberMe,
                                            onChanged: (v) {
                                              setState(() {
                                                _rememberMe = v ?? false;
                                              });
                                            },
                                          ),
                                          Text(
                                            loc.login_remember_me,
                                            style: TextStyle(
                                              color: isDarkTheme
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      CustomElevatedButton(
                                        text: loc.login_button,
                                        onPressed: _handleSignIn,
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const SignUpScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          loc.login_signup_button,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isDarkTheme
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const OrDivider(),
                                      const SizedBox(height: 10),

                                      OutlinedButton(
                                        onPressed: _continueAsGuest,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: isDarkTheme
                                                ? Colors.white.withOpacity(0.85)
                                                : Colors.grey.shade500,
                                            width: 1.2,
                                          ),
                                          foregroundColor: isDarkTheme
                                              ? Colors.white
                                              : Colors.grey.shade800,
                                          backgroundColor: isDarkTheme
                                              ? Colors.transparent
                                              : Colors.grey.shade100,
                                        ),
                                        child: Text(
                                          loc.login_continue_as_guest,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 6),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(
    BuildContext context,
    AppLocalizations loc,
    bool isArabic,
  ) {
    final appState = MyApp.of(context);
    final isDark = appState.isDarkMode;

    return SizedBox(
      height: 185,
      child: Stack(
        children: [
          Positioned(
            top: 26,
            left: isArabic ? 20 : null,
            right: isArabic ? null : 20,
            child: Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: Colors.white,
                    ),
                    onPressed: appState.toggleThemeMode,
                  ),
                  const SizedBox(width: 8),
                  CustomToggleSwitch(
                    isArabicSelected: isArabic,
                    onChanged: (v) {
                      final locale = v
                          ? const Locale('ar')
                          : const Locale('en');
                      MyApp.of(context).setLocale(locale);
                    },
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - value) * 24),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .35),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .4),
                              ),
                              color: Colors.black.withValues(alpha: .12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/images/logo_dark_theme.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: isArabic
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.appTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                loc.login_subtitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, _) {
                        final glow = _glowAnimation.value;
                        final textOpacity = 0.4 + glow * 0.6;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF22C55E), Color(0xFF0EA5E9)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(
                                  alpha: .18 + glow * .30,
                                ),
                                blurRadius: 10 + glow * 8,
                                spreadRadius: glow * 2,
                              ),
                            ],
                          ),
                          child: Opacity(
                            opacity: textOpacity,
                            child: const Text(
                              'Auto Spare',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
