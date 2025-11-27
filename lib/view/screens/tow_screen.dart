import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../controller/navigation/navigation.dart';
import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/services/tow_requests.dart';
import 'package:auto_spare/model/tow_request.dart';
import 'package:auto_spare/services/tow_directory.dart'
    show TowCompany, TowDirectory;
import 'tow_companies_screen.dart';
import 'map_picker_screen.dart';
import 'package:auto_spare/model/app_user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_screen.dart';

class TowScreen extends StatefulWidget {
  const TowScreen({super.key});

  @override
  State<TowScreen> createState() => _TowScreenState();
}

class _TowScreenState extends State<TowScreen> {
  final _formKey = GlobalKey<FormState>();

  final _addressCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _vehicleCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _problemCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _baseCostCtrl = TextEditingController(text: '0 جنيه');
  final _kmSumCtrl = TextEditingController(text: '0.0 كم');
  final _pricePerKmCtrl = TextEditingController(text: '0 جنيه/كم');
  final _kmCostCtrl = TextEditingController(text: '0 جنيه');
  final _totalCostCtrl = TextEditingController(text: '0 جنيه');

  Position? _pos;
  TowCompany? _selectedCompany;
  double? _companyDistKm;
  double? _destLat;
  double? _destLng;

  late final TowDirectory _towDir;

  @override
  void initState() {
    super.initState();
    _towDir = TowDirectory();

    _towDir.addListener(_onTowDirectoryChanged);
    _initLocation();
  }

  void _onTowDirectoryChanged() {
    if (!mounted) return;

    if (_pos != null && _selectedCompany == null) {
      _pickNearestAsSelected();
    }
  }

  @override
  void dispose() {
    _towDir.removeListener(_onTowDirectoryChanged);

    _addressCtrl.dispose();
    _destCtrl.dispose();
    _vehicleCtrl.dispose();
    _plateCtrl.dispose();
    _problemCtrl.dispose();
    _phoneCtrl.dispose();
    _baseCostCtrl.dispose();
    _kmSumCtrl.dispose();
    _pricePerKmCtrl.dispose();
    _kmCostCtrl.dispose();
    _totalCostCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم رفض صلاحية الموقع')));
        return;
      }

      final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      setState(() {
        _pos = p;
        _addressCtrl.text =
            '(${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)})';
      });

      _pickNearestAsSelected();
      _recalcCosts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذّر جلب الموقع: $e')));
    }
  }

  void _pickNearestAsSelected() {
    if (_pos == null) return;

    final userLat = _pos!.latitude;
    final userLng = _pos!.longitude;

    final nearest = _towDir.nearestOnline(userLat, userLng);
    if (nearest == null) return;

    final km =
        Geolocator.distanceBetween(userLat, userLng, nearest.lat, nearest.lng) /
        1000.0;

    _applySelectedCompany(nearest, km);
  }

  void _applySelectedCompany(TowCompany company, double distKm) {
    setState(() {
      _selectedCompany = company;
      _companyDistKm = distKm;
      _baseCostCtrl.text = '${company.baseCost.toStringAsFixed(0)} جنيه';
      _pricePerKmCtrl.text = '${company.pricePerKm.toStringAsFixed(0)} جنيه/كم';
    });
    _recalcCosts();
  }

  Future<void> _openCompanies() async {
    if (_pos == null) return;
    final picked = await Navigator.push<TowCompany>(
      context,
      MaterialPageRoute(
        builder: (_) => TowCompaniesScreen(
          userLat: _pos!.latitude,
          userLng: _pos!.longitude,
        ),
      ),
    );
    if (picked != null) {
      final km =
          Geolocator.distanceBetween(
            _pos!.latitude,
            _pos!.longitude,
            picked.lat,
            picked.lng,
          ) /
          1000.0;
      _applySelectedCompany(picked, km);
    }
  }

  Future<void> _pickDestinationOnMap() async {
    final baseLat = _pos?.latitude ?? 30.0444;
    final baseLng = _pos?.longitude ?? 31.2357;

    final res = await Navigator.push<MapPickResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initLat: baseLat, initLng: baseLng),
      ),
    );

    if (res != null) {
      setState(() {
        _destLat = res.lat;
        _destLng = res.lng;
        _destCtrl.text = res.address.isNotEmpty
            ? res.address
            : '(${res.lat.toStringAsFixed(5)}, ${res.lng.toStringAsFixed(5)})';
      });
      _recalcCosts();
    }
  }

  void _recalcCosts() {
    final baseCost = _selectedCompany?.baseCost ?? 0.0;
    final pricePerKm = _selectedCompany?.pricePerKm ?? 0.0;

    final kmToCompany = _companyDistKm ?? 0.0;

    double kmToDest = 0.0;
    if (_pos != null && _destLat != null && _destLng != null) {
      kmToDest =
          Geolocator.distanceBetween(
            _pos!.latitude,
            _pos!.longitude,
            _destLat!,
            _destLng!,
          ) /
          1000.0;
    }

    final kmTotal = kmToCompany + kmToDest;
    final kmCost = kmTotal * pricePerKm;
    final total = baseCost + kmCost;

    _kmSumCtrl.text = '${kmTotal.toStringAsFixed(1)} كم';
    _kmCostCtrl.text = '${kmCost.toStringAsFixed(0)} جنيه';
    _totalCostCtrl.text = '${total.toStringAsFixed(0)} جنيه';
  }

  Future<bool> _userHasActiveTowRequest(String userId) async {
    try {
      final list = await towRequestsRepo.watchUserRequests(userId).first;

      return list.any(
        (r) =>
            r.status == TowRequestStatus.pending ||
            r.status == TowRequestStatus.accepted ||
            r.status == TowRequestStatus.onTheWay,
      );
    } catch (_) {
      return false;
    }
  }

  void _resetForm() {
    setState(() {
      _pos = null;
      _selectedCompany = null;
      _companyDistKm = null;
      _destLat = null;
      _destLng = null;

      _addressCtrl.clear();
      _destCtrl.clear();
      _vehicleCtrl.clear();
      _plateCtrl.clear();
      _problemCtrl.clear();
      _phoneCtrl.clear();

      _baseCostCtrl.text = '0 جنيه';
      _kmSumCtrl.text = '0.0 كم';
      _pricePerKmCtrl.text = '0 جنيه/كم';
      _kmCostCtrl.text = '0 جنيه';
      _totalCostCtrl.text = '0 جنيه';
    });
  }

  void _goToProfile() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
      (route) => false,
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    if (_pos == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لم يتم تحديد موقعك بعد')));
      return;
    }

    if (_selectedCompany == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('من فضلك اختر شركة سحب')));
      return;
    }

    final user = UserStore().currentUser;
    final userId = user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول قبل طلب الونش')),
      );
      return;
    }

    final hasActive = await _userHasActiveTowRequest(userId);
    if (hasActive) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('يوجد طلب سحب مفتوح'),
          content: Text(
            'يوجد لديك طلب سحب جارٍ حالياً.\n'
            'لا يمكنك إنشاء طلب جديد قبل إنهاء أو إلغاء الطلب الحالي من صفحة حسابك (قسم طلبات الونش).',
            textAlign: TextAlign.right,
          ),
        ),
      );
      return;
    }

    final baseCost = _selectedCompany!.baseCost;
    final pricePerKm = _selectedCompany!.pricePerKm;

    final kmToCompany = _companyDistKm ?? 0.0;

    double kmToDest = 0.0;
    if (_pos != null && _destLat != null && _destLng != null) {
      kmToDest =
          Geolocator.distanceBetween(
            _pos!.latitude,
            _pos!.longitude,
            _destLat!,
            _destLng!,
          ) /
          1000.0;
    }

    final kmTotal = kmToCompany + kmToDest;
    final kmCost = kmTotal * pricePerKm;
    final total = baseCost + kmCost;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('الشركة: ${_selectedCompany?.name ?? '—'}'),
            Text('موقعي: ${_addressCtrl.text}'),
            Text('مكان الوصول: ${_destCtrl.text}'),
            const SizedBox(height: 8),
            Text('التكلفة الأساسية: ${baseCost.toStringAsFixed(0)} جنيه'),
            Text('إجمالي الكيلومترات: ${kmTotal.toStringAsFixed(1)} كم'),
            Text('سعر الكيلو: ${pricePerKm.toStringAsFixed(0)} جنيه/كم'),
            Text('تكلفة الكيلومترات: ${kmCost.toStringAsFixed(0)} جنيه'),
            Text('إجمالي الخدمة: ${total.toStringAsFixed(0)} جنيه'),
            const SizedBox(height: 12),
            Text('المركبة: ${_vehicleCtrl.text}'),
            Text('اللوحة: ${_plateCtrl.text}'),
            Text('الوصف: ${_problemCtrl.text}'),
            Text('رقم التليفون: ${_phoneCtrl.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await towRequestsRepo.createRequest(
                  companyId: _selectedCompany!.id,
                  companyNameSnapshot: _selectedCompany!.name,
                  userId: userId,
                  fromLat: _pos!.latitude,
                  fromLng: _pos!.longitude,
                  destLat: _destLat,
                  destLng: _destLng,
                  baseCost: baseCost,
                  kmTotal: kmTotal,
                  kmPrice: pricePerKm,
                  kmCost: kmCost,
                  totalCost: total,
                  vehicle: _vehicleCtrl.text.trim(),
                  plate: _plateCtrl.text.trim(),
                  problem: _problemCtrl.text.trim(),
                  contactPhone: _phoneCtrl.text.trim(),
                );

                if (!mounted) return;

                final String companyPhone = _selectedCompany!.phone ?? '';

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('تم إرسال طلب السحب'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'تم إرسال طلبك إلى شركة: ${_selectedCompany!.name}',
                        ),
                        const SizedBox(height: 8),
                        if (companyPhone.isNotEmpty) ...[
                          const Text(
                            'رقم التواصل مع الشركة:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            companyPhone,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: () async {
                              final uri = Uri(
                                scheme: 'tel',
                                path: companyPhone,
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تعذّر فتح شاشة الاتصال'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.call),
                            label: const Text('اتصال بالشركة'),
                          ),
                        ] else ...[
                          const Text(
                            'لم يتم تسجيل رقم هاتف للشركة، رجاءً تواصل معهم من خلال التطبيق لاحقاً.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetForm();
                          _goToProfile();
                        },
                        child: const Text('إغلاق'),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('تعذر إرسال الطلب: $e')));
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final body = SafeArea(
      child: Form(
        key: _formKey,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'موقعك',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'الإحداثيات الحالية',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 46,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await _initLocation();
                      _recalcCosts();
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('استخدم موقعي الحالي'),
                  ),
                ),
                const SizedBox(height: 12),

                if (_selectedCompany != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.near_me_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'أقرب/مختارة: ${_selectedCompany!.name} (${_selectedCompany!.area})\n'
                            'المسافة للشركة: ${(_companyDistKm ?? 0).toStringAsFixed(1)} كم • '
                            'خدمة: ${_selectedCompany!.baseCost.toStringAsFixed(0)}ج • '
                            'الكيلو: ${_selectedCompany!.pricePerKm.toStringAsFixed(0)}ج',
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: _pos == null ? null : _openCompanies,
                          child: const Text('عرض الكل'),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'مكان الوصول',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _destCtrl,
                        decoration: const InputDecoration(
                          labelText: 'العنوان',
                          hintText: 'اكتب العنوان أو اختاره من الخريطة',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                        onChanged: (_) => _recalcCosts(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 52,
                      child: FilledButton.tonalIcon(
                        onPressed: _pickDestinationOnMap,
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('خريطة'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(
                      Icons.request_quote_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تكاليف الخدمة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _baseCostCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'التكلفة الأساسية',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _kmSumCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'إجمالي الكيلومترات (للشركة + للوصول)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _pricePerKmCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'سعر الكيلو',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _kmCostCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'تكلفة الكيلومترات',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _totalCostCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'إجمالي الخدمة',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(
                      Icons.directions_car_filled_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'معلومات المركبة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _vehicleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'النوع والطراز',
                    hintText: 'مثال: هوندا سيفيك',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'هذا الحقل مطلوب'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _plateCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'رقم اللوحة',
                    hintText: 'مثال: ABC-1234',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'هذا الحقل مطلوب'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _problemCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'وصف المشكلة',
                    hintText: 'اكتب باختصار المشكلة…',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(Icons.call_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'معلومات التواصل',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم التليفون',
                    hintText: '+20 1xxxxxxxxx',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'هذا الحقل مطلوب';
                    }
                    if (v.replaceAll(RegExp(r'[\s\-\+]'), '').length < 9) {
                      return 'رجاءً أدخل رقمًا صحيحًا';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(.25),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الوقت المتوقع للوصول',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 2),
                            Text('15–25 دقيقة بعد التأكيد'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('إرسال الطلب'),
                  ),
                ),
              ],
            ),

            if (_pos != null)
              Positioned(
                right: 16,
                bottom: 16,
                child: FilledButton.tonalIcon(
                  onPressed: _openCompanies,
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('أقرب الشركات'),
                ),
              ),
          ],
        ),
      ),
    );

    return AppNavigationScaffold(
      currentIndex: 2,
      title: 'خدمة سحب عاجلة',
      body: body,
    );
  }
}
