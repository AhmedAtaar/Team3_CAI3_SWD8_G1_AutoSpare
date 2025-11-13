import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_spare/view/screens/home_screen.dart';
import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_buttons.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_form_field.dart';
import 'package:auto_spare/view/widgets/login_screen_widgets/custom_toggle_switch.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isArabicSelected = false;
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors above.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Authentication error';
      if (e.code == 'user-not-found') {
        msg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        msg = 'Wrong password.';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email format.';
      } else if (e.message != null) {
        msg = e.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueAsGuest() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _auth.signInAnonymously();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guest sign-in failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openSignUp() {
    if (_busy) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbsorbPointer(
        absorbing: _busy,
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                          const Text(
                            'Welcome Back',
                            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Sign in to access your auto parts marketplace',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFormField(
                        controller: _emailCtrl,
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomFormField(
                        controller: _passwordCtrl,
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
                          const Spacer(),
                          if (_busy)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      CustomElevatedButton(text: 'Sign In', onPressed: _handleSignIn),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(onPressed: _openSignUp, child: const Text("Create a new account")),
                      ),
                      const SizedBox(height: 10),
                      const OrDivider(),
                      const SizedBox(height: 20),
                      CustomOutlinedButton(
                        text: 'Continue with Google',
                        onPressed: () {
                          if (_busy) return;
                        },
                        leadingIcon: Image.asset('assets/images/google_logo.png', height: 24),
                      ),
                      const SizedBox(height: 15),
                      CustomOutlinedButton(text: 'Continue as Guest', onPressed: _continueAsGuest),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
