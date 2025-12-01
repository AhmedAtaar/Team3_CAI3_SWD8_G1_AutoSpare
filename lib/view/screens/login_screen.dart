import 'package:auto_spare/model/app_user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:auto_spare/services/user_session.dart';
import 'package:auto_spare/view/screens/home_screen.dart';
import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_buttons.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_form_field.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('من فضلك صحّح البيانات.')));
      return;
    }

    final email = _userController.text.trim();
    final pass = _passwordController.text.trim();

    final u = await _loginByEmail(email, pass);

    if (u == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('بيانات الدخول غير صحيحة')));
      return;
    }

    if (u.role == AppUserRole.winch && !u.approved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('حساب الونش غير مفعل بعد.')));
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _continueAsGuest() {
    UserStore().setGuest();
    UserSession.initFromProfile(name: "Guest", role: UserRole.buyer);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Remove Directionality, EasyLocalization handles it
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 40,
                            left: 20,
                            child: CustomToggleSwitch(
                              isArabicSelected:
                                  context.locale.languageCode == 'ar',
                              onChanged: (v) {
                                // State change handled in CustomToggleSwitch
                                setState(() {});
                              },
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/logo_light_theme.png',
                                  height: 70,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'login.welcome_back'.tr(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'login.sign_in_to_access'.tr(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomFormField(
                              controller: _userController,
                              labelText: "login.email".tr(),
                              hintText: "login.email_hint".tr(),
                              icon: Icons.email,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? "login.required".tr()
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            CustomFormField(
                              controller: _passwordController,
                              labelText: "login.password".tr(),
                              hintText: "login.password_hint".tr(),
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? "login.required".tr()
                                  : null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),

                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                ),
                                Text("login.remember_me".tr()),
                              ],
                            ),

                            const SizedBox(height: 16),
                            CustomElevatedButton(
                              text: "login.sign_in".tr(),
                              onPressed: _handleSignIn,
                            ),
                            const SizedBox(height: 14),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: Text("login.create_account".tr()),
                            ),

                            const SizedBox(height: 10),
                            const OrDivider(),
                            const SizedBox(height: 16),

                            CustomOutlinedButton(
                              text: "login.sign_in_google".tr(),
                              onPressed: () {},
                            ),
                            const SizedBox(height: 12),

                            CustomOutlinedButton(
                              text: "login.continue_guest".tr(),
                              onPressed: _continueAsGuest,
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
