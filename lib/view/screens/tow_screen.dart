import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../controller/navigation/navigation.dart';

// ✅ استيراد موديل الشركات والدليل المركزي
import 'package:auto_spare/services/tow_directory.dart' show TowCompany, TowDirectory;

// ✅ استيراد شاشة اختيار الشركة فقط (من غير الـ show)
import 'tow_companies_screen.dart';
import 'map_picker_screen.dart';

class TowScreen extends StatefulWidget {
  const TowScreen({super.key});

  @override
  State<TowScreen> createState() => _TowScreenState();
}

class _TowScreenState extends State<TowScreen> {
  final _formKey = GlobalKey<FormState>();

  // إدخالات
  final _addressCtrl = TextEditingController(); // موقعي
  final _destCtrl = TextEditingController();    // مكان الوصول
  final _vehicleCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _problemCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // تكاليف (عرض فقط)
  final _baseCostCtrl = TextEditingController(text: '0 جنيه');
  final _kmSumCtrl = TextEditingController(text: '0.0 كم');
  final _pricePerKmCtrl = TextEditingController(text: '0 جنيه/كم');
  final _kmCostCtrl = TextEditingController(text: '0 جنيه');
  final _totalCostCtrl = TextEditingController(text: '0 جنيه');

  // حالة
  Position? _pos;
  TowCompany? _selectedCompany; // الشركة المعتمدة للحساب
  double? _companyDistKm;       // المسافة من موقعي للشركة
  double? _destLat;
  double? _destLng;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
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

  // GPS
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
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفض صلاحية الموقع')),
        );
        return;
      }

      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;

      setState(() {
        _pos = p;
        _addressCtrl.text = '(${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)})';
      });

      _pickNearestAsSelected(); // اختار الأقرب كبداية
      _recalcCosts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر جلب الموقع: $e')),
      );
    }
  }

  // اختار أقرب شركة وافتح أسعارها
  void _pickNearestAsSelected() {
    if (_pos == null) return;

    final userLat = _pos!.latitude, userLng = _pos!.longitude;
    final list = List<TowCompany>.from(TowDirectory().all);        // ✅ بديل kTowCompanies
    if (list.isEmpty) return;

    list.sort((a, b) {
      final da = Geolocator.distanceBetween(userLat, userLng, a.lat, a.lng);
      final db = Geolocator.distanceBetween(userLat, userLng, b.lat, b.lng);
      return da.compareTo(db);
    });

    final nearest = list.first;
    final km = Geolocator.distanceBetween(userLat, userLng, nearest.lat, nearest.lng) / 1000.0;
    _applySelectedCompany(nearest, km);
  }

  // لما أختار شركة من الليست
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
      final km = Geolocator.distanceBetween(
          _pos!.latitude, _pos!.longitude, picked.lat, picked.lng) /
          1000.0;
      _applySelectedCompany(picked, km);
    }
  }

  // مكان الوصول من الخريطة
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

  // حساب التكاليف
  void _recalcCosts() {
    final baseCost    = _selectedCompany?.baseCost   ?? 0.0;
    final pricePerKm  = _selectedCompany?.pricePerKm ?? 0.0;

    final kmToCompany = _companyDistKm ?? 0.0;

    double kmToDest = 0.0;
    if (_pos != null && _destLat != null && _destLng != null) {
      kmToDest = Geolocator.distanceBetween(
          _pos!.latitude, _pos!.longitude, _destLat!, _destLng!) /
          1000.0;
    }

    final kmTotal = kmToCompany + kmToDest;
    final kmCost  = kmTotal * pricePerKm;
    final total   = baseCost + kmCost;

    _kmSumCtrl .text = '${kmTotal.toStringAsFixed(1)} كم';
    _kmCostCtrl.text = '${kmCost.toStringAsFixed(0)} جنيه';
    _totalCostCtrl.text = '${total.toStringAsFixed(0)} جنيه';
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

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
            Text('التكلفة الأساسية: ${_baseCostCtrl.text}'),
            Text('إجمالي الكيلومترات: ${_kmSumCtrl.text}'),
            Text('سعر الكيلو: ${_pricePerKmCtrl.text}'),
            Text('تكلفة الكيلومترات: ${_kmCostCtrl.text}'),
            Text('إجمالي الخدمة: ${_totalCostCtrl.text}'),
            const SizedBox(height: 12),
            Text('المركبة: ${_vehicleCtrl.text}'),
            Text('اللوحة: ${_plateCtrl.text}'),
            Text('الوصف: ${_problemCtrl.text}'),
            Text('رقم التليفون: ${_phoneCtrl.text}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال الطلب بنجاح')),
              );
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
                // موقعي
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('موقعك', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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

                // الشركة المختارة + المسافة
                if (_selectedCompany != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
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

                // مكان الوصول
                Row(
                  children: [
                    Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('مكان الوصول', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
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

                // تكاليف الخدمة
                Row(
                  children: [
                    Icon(Icons.request_quote_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('تكاليف الخدمة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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

                // معلومات المركبة
                Row(
                  children: [
                    Icon(Icons.directions_car_filled_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('معلومات المركبة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'यह الحقل مطلوب' : null,
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
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
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

                // تواصل
                Row(
                  children: [
                    Icon(Icons.call_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('معلومات التواصل', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
                    if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
                    if (v.replaceAll(RegExp(r'[\\s\\-\\+]'), '').length < 9) {
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
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(.25)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الوقت المتوقع للوصول', style: TextStyle(fontWeight: FontWeight.w700)),
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
