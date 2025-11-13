import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/view/screens/home_screen.dart';
import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_buttons.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_form_field.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
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
  bool _isArabicSelected = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  UserRole _mapRole(AppUserRole r) {
    switch (r) {
      case AppUserRole.admin:  return UserRole.admin;
      case AppUserRole.seller: return UserRole.seller;
      case AppUserRole.buyer:
      default:                 return UserRole.buyer;
    }
  }

  void _handleSignIn() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors above.')),
      );
      return;
    }

    final user = _userController.text.trim();
    final pass = _passwordController.text.trim();

    final u = UserStore().authenticate(user, pass);
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
      return;
    }

    UserSession.initFromProfile(name: u.name, role: _mapRole(u.role));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _continueAsGuest() {
    UserSession.initFromProfile(name: 'Guest', role: UserRole.buyer);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              decoration: const BoxDecoration(color: AppColors.primaryGreen),
              child: Stack(
                children: [
                  Positioned(
                    top: 40,
                    right: 20,
                    child: CustomToggleSwitch(
                      isArabicSelected: _isArabicSelected,
                      onChanged: (bool v) => setState(() => _isArabicSelected = v),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo_light_theme.png', height: 60),
                        const SizedBox(height: 5),
                        const Text('Welcome Back',
                            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        const Text('Sign in to access your auto parts marketplace',
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFormField(
                      controller: _userController,
                      labelText: 'Email or Name',
                      hintText: 'ahmed@admin.com أو Ahmed',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomFormField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v ?? false),
                          activeColor: AppColors.primaryGreen,
                        ),
                        const Text('Remember me'),
                      ],
                    ),
                    const SizedBox(height: 25),
                    CustomElevatedButton(text: 'Sign In', onPressed: _handleSignIn),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        ),
                        child: const Text("Create a new account"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const OrDivider(),
                    const SizedBox(height: 20),
                    CustomOutlinedButton(text: 'Continue with Google', onPressed: () {}),
                    const SizedBox(height: 15),
                    CustomOutlinedButton(text: 'Continue as Guest', onPressed: _continueAsGuest),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
