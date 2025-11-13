import 'package:auto_spare/services/user_store.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

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

  bool _isSeller = false;
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
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text.trim() != _confirm.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    try {
      if (_isSeller) {
        UserStore().signUpSeller(
          email: _email.text.trim(),
          password: _password.text.trim(),
          name: _name.text.trim(),
          address: _address.text.trim(),
          phone: _phone.text.trim(),
          storeName: _store.text.trim(),
          commercialRegUrl: _crUrl.text.trim().isEmpty ? null : _crUrl.text.trim(),
          taxCardUrl: _taxUrl.text.trim().isEmpty ? null : _taxUrl.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء حساب بائع (بانتظار اعتماد الأدمن)')));
      } else {
        UserStore().signUpBuyer(
          email: _email.text.trim(),
          password: _password.text.trim(),
          name: _name.text.trim(),
          address: _address.text.trim(),
          phone: _phone.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء حساب مشتري')));
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } on StateError catch (e) {
      if (e.message == 'exists') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الحساب موجود بالفعل')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: ${e.message}')));
      }
    }
  }

  InputDecoration _dec(String label, {Widget? suffix}) =>
      InputDecoration(labelText: label, border: const OutlineInputBorder(), suffixIcon: suffix);

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
                        selected: !_isSeller,
                        onSelected: (_) => setState(() => _isSeller = false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('بائع'),
                        selected: _isSeller,
                        onSelected: (_) => setState(() => _isSeller = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: _dec('الإيميل'), validator: (v) => (v==null||v.isEmpty)?'مطلوب':null),
                const SizedBox(height: 10),
                TextFormField(controller: _password, obscureText: _obscure1, decoration: _dec('كلمة المرور', suffix: IconButton(icon: Icon(_obscure1?Icons.visibility_off:Icons.visibility), onPressed: ()=>setState(()=>_obscure1=!_obscure1))), validator: (v)=> (v==null||v.length<4)?'على الأقل 4 حروف':null),
                const SizedBox(height: 10),
                TextFormField(controller: _confirm, obscureText: _obscure2, decoration: _dec('تأكيد كلمة المرور', suffix: IconButton(icon: Icon(_obscure2?Icons.visibility_off:Icons.visibility), onPressed: ()=>setState(()=>_obscure2=!_obscure2))), validator: (v)=> (v==null||v.isEmpty)?'مطلوب':null),
                const SizedBox(height: 10),
                TextFormField(controller: _name, decoration: _dec('الاسم'), validator: (v)=> (v==null||v.isEmpty)?'مطلوب':null),
                const SizedBox(height: 10),
                TextFormField(controller: _address, decoration: _dec('العنوان'), validator: (v)=> (v==null||v.isEmpty)?'مطلوب':null),
                const SizedBox(height: 10),
                TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: _dec('رقم التليفون'), validator: (v)=> (v==null||v.isEmpty)?'مطلوب':null),

                if (_isSeller) ...[
                  const SizedBox(height: 16),
                  TextFormField(controller: _store, decoration: _dec('اسم المتجر'), validator: (v)=> (v==null||v.isEmpty)?'مطلوب':null),
                  const SizedBox(height: 10),
                  TextFormField(controller: _crUrl, decoration: _dec('رابط صورة السجل التجاري (Drive/Link)')),
                  const SizedBox(height: 10),
                  TextFormField(controller: _taxUrl, decoration: _dec('رابط صورة البطاقة الضريبية (Drive/Link)')),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('ملحوظة: يمكنك رفع الملفات على Google Drive وإرسال الروابط للمراجعة.'),
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
