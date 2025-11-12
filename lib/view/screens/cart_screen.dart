import 'package:auto_spare/view/widgets/cart_screen_widgets/cart_app_bar_title.dart';
import 'package:auto_spare/view/widgets/cart_screen_widgets/cart_item_card.dart';
import 'package:auto_spare/view/widgets/cart_screen_widgets/order_summary.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../controller/navigation/navigation.dart';
import '../themes/app_colors.dart';
import 'map_picker_screen.dart';

class CartItem {
  final String id;
  final String name;
  final String details;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.details,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // بيانات البروفايل المحفوظة (بدّلها بمصدر بياناتك)
  final String _profileName = 'محمد أمين';
  final String _profileAddress = 'القاهرة، مدينة نصر، شارع الطيران';
  final String _profilePhone = '01000000000';

  // كونترولرز
  final _nameCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _altPhoneCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();

  // حالة التعديل
  bool _editAddress = false;
  bool _editPhone = false;

  // موقع التسليم (اختياري)
  Position? _pos;
  double? _delLat, _delLng;

  List<CartItem> cartItems = [
    CartItem(id: '1', name: 'فلتر زيت محرك', details: 'تويوتا كامري 2018', price: 25.00, quantity: 1),
    CartItem(id: '2', name: 'فرامل خلفية', details: 'هوندا أكورد', price: 120.50, quantity: 2),
    CartItem(id: '3', name: 'شمعات احتراق', details: 'طقم 4 قطع', price: 45.99, quantity: 3),
    CartItem(id: '4', name: 'إطار احتياطي', details: 'مقاس 17 بوصة', price: 99.99, quantity: 1),
    CartItem(id: '5', name: 'مضخة ماء', details: 'نيسان صني', price: 75.00, quantity: 1),
    CartItem(id: '6', name: 'بطارية سيارة', details: '12 فولت، 60 أمبير', price: 150.00, quantity: 1),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = _profileName;
    _addrCtrl.text = _profileAddress;
    _phoneCtrl.text = _profilePhone;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _phoneCtrl.dispose();
    _altPhoneCtrl.dispose();
    _deliveryCtrl.dispose();
    super.dispose();
  }

  double get _subtotal {
    final total = cartItems.fold(0.0, (sum, item) => sum + item.total);
    return total * 1.05;
  }

  Future<void> _useCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;

    final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (!mounted) return;
    setState(() {
      _pos = p;
      _delLat = p.latitude;
      _delLng = p.longitude;
      _deliveryCtrl.text = '(${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)})';
    });
  }

  Future<void> _pickOnMap() async {
    final baseLat = _pos?.latitude ?? 30.0444;
    final baseLng = _pos?.longitude ?? 31.2357;
    final res = await Navigator.push<MapPickResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initLat: baseLat, initLng: baseLng),
      ),
    );
    if (res != null && mounted) {
      setState(() {
        _delLat = res.lat;
        _delLng = res.lng;
        _deliveryCtrl.text = res.address.isNotEmpty
            ? res.address
            : '(${res.lat.toStringAsFixed(5)}, ${res.lng.toStringAsFixed(5)})';
      });
    }
  }

  void _updateQuantity(String itemId, bool increase) {
    setState(() {
      final index = cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        if (increase) {
          cartItems[index].quantity++;
        } else if (cartItems[index].quantity > 1) {
          cartItems[index].quantity--;
        }
      }
    });
  }

  void _removeItem(String itemId) {
    setState(() {
      cartItems.removeWhere((item) => item.id == itemId);
    });
  }

  void _handleProceedToOrder() {
    final info = [
      'الاسم: ${_nameCtrl.text.trim()}',
      'العنوان: ${_addrCtrl.text.trim()}',
      'رقم التليفون: ${_phoneCtrl.text.trim()}',
      'رقم آخر: ${_altPhoneCtrl.text.trim().isEmpty ? '—' : _altPhoneCtrl.text.trim()}',
      'موقع التسليم: ${_deliveryCtrl.text.trim().isEmpty ? 'اختياري (غير محدد)' : _deliveryCtrl.text.trim()}',
    ].join(' | ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تنفيذ طلبك • $info', textDirection: TextDirection.rtl),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleCancelOrder() {
    setState(() {
      cartItems = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إلغاء جميع العناصر في السلة', textDirection: TextDirection.rtl),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget _customerCard() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: const [Icon(Icons.person_outline), SizedBox(width: 8), Text('بيانات العميل')]),
              const SizedBox(height: 10),
              TextField(
                controller: _nameCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addrCtrl,
                readOnly: !_editAddress,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _editAddress = !_editAddress),
                    icon: Icon(_editAddress ? Icons.check : Icons.edit),
                    tooltip: _editAddress ? 'حفظ' : 'تعديل',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                readOnly: !_editPhone,
                decoration: InputDecoration(
                  labelText: 'رقم التليفون',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _editPhone = !_editPhone),
                    icon: Icon(_editPhone ? Icons.check : Icons.edit),
                    tooltip: _editPhone ? 'حفظ' : 'تعديل',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _altPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم آخر للتواصل',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Widget _deliveryCard() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: const [Icon(Icons.place_outlined), SizedBox(width: 8), Text('موقع التسليم (اختياري)')]),
              const SizedBox(height: 10),
              TextField(
                controller: _deliveryCtrl,
                decoration: const InputDecoration(
                  labelText: 'العنوان أو الإحداثيات',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _useCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('موقعي الحالي'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _pickOnMap,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('اختيار من الخريطة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return AppNavigationScaffold(
      currentIndex: 3,
      title: 'عربة التسوق',
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CartAppTitle(itemCount: cartItems.length),
              const SizedBox(height: 10.0),

              // عناصر السلة أولًا
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: cartItems.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50.0),
                    child: Text(
                      'عربة التسوق فارغة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                )
                    : Column(
                  children: cartItems.map((item) {
                    return CartItemCard(
                      item: item as dynamic,
                      onQuantityChanged: (increase) => _updateQuantity(item.id, increase),
                      onRemove: () => _removeItem(item.id),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),
              Divider(indent: 16, endIndent: 16, color: cs.outlineVariant),
              const SizedBox(height: 8),

              // بعدين بيانات العميل
              _customerCard(),
              const SizedBox(height: 12),

              // وبعدين موقع التسليم الاختياري
              _deliveryCard(),
              const SizedBox(height: 12),

              // الملخص في الآخر
              OrderSummary(
                subtotal: _subtotal,
                itemCount: cartItems.length,
                onProceedToOrder: _handleProceedToOrder,
                onCancel: _handleCancelOrder,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
