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

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _towDir = TowDirectory();
    _towDir.addListener(_onTowDirectoryChanged);

    final u = UserStore().currentUser;
    if (u != null && u.phone.isNotEmpty) {
      _phoneCtrl.text = u.phone;
    }

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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('من فضلك فعّل خدمة الموقع (GPS) من الإعدادات'),
          ),
        );
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

  Future<void> _pickCurrentLocationOnMap() async {
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
        _pos = Position(
          latitude: res.lat,
          longitude: res.lng,
          accuracy: 1.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 1.0,
          timestamp: DateTime.now(),
          isMocked: false,
          headingAccuracy: 0.0,
          altitudeAccuracy: 0.0,
        );

        _addressCtrl.text = res.address.isNotEmpty
            ? res.address
            : '(${res.lat.toStringAsFixed(5)}, ${res.lng.toStringAsFixed(5)})';
      });

      _pickNearestAsSelected();
      _recalcCosts();
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

      if (UserStore().currentUser == null ||
          UserStore().currentUser!.phone.isEmpty) {
        _phoneCtrl.clear();
      }

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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('الشركة: ${_selectedCompany?.name ?? '—'}'),
              Text('موقعي: ${_addressCtrl.text}'),
              Text(
                'مكان الوصول: ${_destCtrl.text.isEmpty ? '—' : _destCtrl.text}',
              ),
              const SizedBox(height: 8),
              Text('التكلفة الأساسية: ${baseCost.toStringAsFixed(0)} جنيه'),
              Text('إجمالي الكيلومترات: ${kmTotal.toStringAsFixed(1)} كم'),
              Text('سعر الكيلو: ${pricePerKm.toStringAsFixed(0)} جنيه/كم'),
              Text('تكلفة الكيلومترات: ${kmCost.toStringAsFixed(0)} جنيه'),
              Text('إجمالي الخدمة: ${total.toStringAsFixed(0)} جنيه'),
              const SizedBox(height: 12),
              Text('المركبة: ${_vehicleCtrl.text}'),
              Text('اللوحة: ${_plateCtrl.text}'),
              Text(
                'الوصف: ${_problemCtrl.text.isEmpty ? '—' : _problemCtrl.text}',
              ),
              Text('رقم التليفون: ${_phoneCtrl.text}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    Navigator.pop(context);

                    if (!mounted) return;
                    setState(() => _isSubmitting = true);

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

                      await showDialog(
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'تعذّر فتح شاشة الاتصال',
                                          ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تعذر إرسال الطلب: $e')),
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isSubmitting = false);
                      }
                    }
                  },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsHeader(ThemeData theme) {
    Widget step(int n, String label, {bool active = true}) {
      final cs = theme.colorScheme;
      final bg = active ? cs.primary : cs.surfaceVariant;
      final fg = active ? cs.onPrimary : cs.onSurfaceVariant;

      return Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: bg,
            child: Text(
              '$n',
              style: TextStyle(
                color: fg,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          step(1, 'تحديد موقعي'),
          step(2, 'اختيار شركة'),
          step(3, 'بيانات المركبة'),
          step(4, 'تأكيد الطلب'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final canSubmit =
        !_isSubmitting && _pos != null && _selectedCompany != null;

    final content = SafeArea(
      child: Form(
        key: _formKey,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                _buildStepsHeader(theme),

                if (_pos == null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'لم يتم تحديد موقعك بعد، استخدم زر "موقعي الحالي" أو اختر من الخريطة.',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تم تحديد موقعك بنجاح.',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      'موقعي الحالي',
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

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
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
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: FilledButton.tonalIcon(
                          onPressed: _pickCurrentLocationOnMap,
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('اختيار من الخريطة'),
                        ),
                      ),
                    ),
                  ],
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
                        const Icon(Icons.local_shipping_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'الشركة المختارة: ${_selectedCompany!.name} (${_selectedCompany!.area})\n'
                            'المسافة للشركة: ${(_companyDistKm ?? 0).toStringAsFixed(1)} كم • '
                            'خدمة أساسية: ${_selectedCompany!.baseCost.toStringAsFixed(0)}ج • '
                            'سعر الكيلو: ${_selectedCompany!.pricePerKm.toStringAsFixed(0)}ج',
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: _pos == null ? null : _openCompanies,
                          child: const Text('تغيير'),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _pos == null
                                ? 'بعد تحديد موقعك، سنقترح أقرب شركة سحب تلقائياً.'
                                : 'اختر شركة السحب المناسبة لك من قائمة الشركات.',
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: _pos == null ? null : _openCompanies,
                          child: const Text('عرض الشركات'),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(Icons.flag_outlined, color: cs.primary),
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
                          labelText: 'العنوان (اختياري)',
                          hintText: 'اكتب العنوان أو اختاره من الخريطة',
                          border: OutlineInputBorder(),
                        ),

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

                const SizedBox(height: 4),
                const Text(
                  'يمكن ترك مكان الوصول فارغًا والتنسيق مع السائق تليفونيًا.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(Icons.request_quote_outlined, color: cs.primary),
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
                      color: cs.primary,
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
                    hintText: 'اكتب باختصار المشكلة… (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(Icons.call_outlined, color: cs.primary),
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
                    color: cs.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.primary.withOpacity(.25)),
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
                            Text('من 15 إلى 25 دقيقة بعد تأكيد الطلب'),
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
                    onPressed: canSubmit ? _submit : null,
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('جارٍ إرسال الطلب...'),
                            ],
                          )
                        : const Text('إرسال الطلب'),
                  ),
                ),
                if (!canSubmit)
                  const Padding(
                    padding: EdgeInsets.only(top: 6.0),
                    child: Text(
                      'تأكّد من تحديد موقعك واختيار شركة السحب قبل إرسال الطلب.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
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
      body: Directionality(textDirection: TextDirection.rtl, child: content),
    );
  }
}
