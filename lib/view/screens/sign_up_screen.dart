import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/services/users_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'tow_location_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();

  final _store = TextEditingController();
  final _crUrl = TextEditingController();
  final _taxUrl = TextEditingController();

  final _company = TextEditingController();
  final _area = TextEditingController();
  final _baseCost = TextEditingController();
  final _pricePerKm = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  final _towCrUrl = TextEditingController();
  final _towTaxUrl = TextEditingController();

  bool _isSeller = false;
  bool _isTow = false;

  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _name.dispose();
    _address.dispose();
    _phone.dispose();

    _store.dispose();
    _crUrl.dispose();
    _taxUrl.dispose();

    _company.dispose();
    _area.dispose();
    _baseCost.dispose();
    _pricePerKm.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();

    _towCrUrl.dispose();
    _towTaxUrl.dispose();

    super.dispose();
  }

  void _pickRoleBuyer() => setState(() {
    _isSeller = false;
    _isTow = false;
  });

  void _pickRoleSeller() => setState(() {
    _isSeller = true;
    _isTow = false;
  });

  void _pickRoleTow() => setState(() {
    _isSeller = false;
    _isTow = true;
  });

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<TowPickedLocation>(
      context,
      MaterialPageRoute(builder: (_) => const TowLocationPickerScreen()),
    );
    if (result != null) {
      _latCtrl.text = result.lat.toStringAsFixed(6);
      _lngCtrl.text = result.lng.toStringAsFixed(6);
      setState(() {});
    }
  }

  InputDecoration _dec(String label, {Widget? suffix}) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    suffixIcon: suffix,
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_password.text.trim() != _confirm.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final pass = _password.text.trim();
    final name = _name.text.trim();
    final addr = _address.text.trim();

    if (!_isTow) {
      final sameEmailUsers = usersRepo.allUsers
          .where((u) => u.email.toLowerCase() == email.toLowerCase())
          .toList();

      if (sameEmailUsers.isNotEmpty) {
        final existing = sameEmailUsers.first;
        final bool isBanned =
            existing.approved == false && existing.canSell == false;

        if (isBanned) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'لا يمكن إنشاء حساب جديد بهذا البريد.\n'
                'تم حظر الحساب نهائيًا من قبل الإدارة.',
                textAlign: TextAlign.right,
              ),
            ),
          );
          return;
        }
      }
    }

    try {
      if (_isTow) {
        final lat = double.tryParse(_latCtrl.text.trim());
        final lng = double.tryParse(_lngCtrl.text.trim());
        final base = double.tryParse(_baseCost.text.trim());
        final km = double.tryParse(_pricePerKm.text.trim());
        if (lat == null || lng == null || base == null || km == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('برجاء إدخال بيانات صحيحة للّوكيشن/الأسعار'),
            ),
          );
          return;
        }

        UserStore().signUpTow(
          companyName: _company.text.trim(),
          area: _area.text.trim(),
          lat: lat,
          lng: lng,
          baseCost: base,
          pricePerKm: km,
          contactName: name.isEmpty ? _company.text.trim() : name,
          contactEmail: email,
          contactPhone: phone,
          password: pass,
          commercialRegUrl: _towCrUrl.text.trim().isEmpty
              ? null
              : _towCrUrl.text.trim(),
          taxCardUrl: _towTaxUrl.text.trim().isEmpty
              ? null
              : _towTaxUrl.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال طلب شركة الونش للمراجعة')),
        );
      } else if (_isSeller) {
        await UserStore().signUpSeller(
          email: email,
          password: pass,
          name: name,
          address: addr,
          phone: phone,
          storeName: _store.text.trim(),
          commercialRegUrl: _crUrl.text.trim().isEmpty
              ? null
              : _crUrl.text.trim(),
          taxCardUrl: _taxUrl.text.trim().isEmpty ? null : _taxUrl.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال طلب تسجيل كبائع للمراجعة')),
        );
      } else {
        await UserStore().signUpBuyer(
          email: email,
          password: pass,
          name: name,
          address: addr,
          phone: phone,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إنشاء حساب مشتري')));
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } on FirebaseAuthException catch (e) {
      String msg = 'حدث خطأ أثناء إنشاء الحساب';
      if (e.code == 'email-already-in-use') {
        msg = 'الحساب موجود بالفعل لهذا الإيميل';
      } else if (e.code == 'weak-password') {
        msg = 'كلمة المرور ضعيفة، برجاء اختيار كلمة أقوى';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } on StateError catch (e) {
      if (e.message == 'exists') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('الحساب موجود بالفعل')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: ${e.message}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ غير متوقع: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء حساب')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('مشتري'),
                        selected: !_isSeller && !_isTow,
                        onSelected: (_) => _pickRoleBuyer(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('بائع'),
                        selected: _isSeller,
                        onSelected: (_) => _pickRoleSeller(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('ونش'),
                        selected: _isTow,
                        onSelected: (_) => _pickRoleTow(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _dec('الإيميل'),
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure1,
                  decoration: _dec(
                    'كلمة المرور',
                    suffix: IconButton(
                      icon: Icon(
                        _obscure1 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 4) ? 'على الأقل 4 حروف' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirm,
                  obscureText: _obscure2,
                  decoration: _dec(
                    'تأكيد كلمة المرور',
                    suffix: IconButton(
                      icon: Icon(
                        _obscure2 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _name,
                  decoration: _dec('الاسم'),
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _address,
                  decoration: _dec('العنوان'),
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: _dec('رقم التليفون'),
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),

                if (_isSeller) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _store,
                    decoration: _dec('اسم المتجر'),
                    validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _crUrl,
                    decoration: _dec('رابط صورة السجل التجاري (Drive/Link)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _taxUrl,
                    decoration: _dec('رابط صورة البطاقة الضريبية (Drive/Link)'),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ملحوظة: يمكنك رفع الملفات على Google Drive وإرسال الروابط للمراجعة.',
                    ),
                  ),
                ],

                if (_isTow) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _company,
                    decoration: _dec('اسم الشركة'),
                    validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _area,
                    decoration: _dec('المنطقة/التغطية'),
                    validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _baseCost,
                    keyboardType: TextInputType.number,
                    decoration: _dec('سعر الخدمة (جنيه)'),
                    validator: (v) => (double.tryParse(v ?? '') == null)
                        ? 'أدخل رقمًا صحيحًا'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _pricePerKm,
                    keyboardType: TextInputType.number,
                    decoration: _dec('سعر الكيلو (جنيه)'),
                    validator: (v) => (double.tryParse(v ?? '') == null)
                        ? 'أدخل رقمًا صحيحًا'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _dec('Latitude'),
                          validator: (v) => (double.tryParse(v ?? '') == null)
                              ? 'أدخل رقمًا'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _lngCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _dec('Longitude'),
                          validator: (v) => (double.tryParse(v ?? '') == null)
                              ? 'أدخل رقمًا'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _openLocationPicker,
                      icon: const Icon(Icons.my_location),
                      label: const Text(
                        'تحديد الموقع (موقعي الآن / إدخال يدوي)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _towCrUrl,
                    decoration: _dec('رابط صورة السجل التجاري (Drive/Link)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _towTaxUrl,
                    decoration: _dec('رابط صورة البطاقة الضريبية (Drive/Link)'),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ملحوظة: يمكنك رفع الملفات على Google Drive وإرسال الروابط للمراجعة.',
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: const Text('إنشاء الحساب'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
