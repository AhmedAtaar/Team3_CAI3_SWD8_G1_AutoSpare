import 'package:auto_spare/model/catalog.dart';
import 'package:auto_spare/services/cart_service.dart';
import 'package:auto_spare/services/user_store.dart';
import 'package:auto_spare/view/screens/home_screen.dart';
import 'package:auto_spare/view/widgets/cart_screen_widgets/cart_app_bar_title.dart';
import 'package:auto_spare/view/widgets/cart_screen_widgets/cart_item_card.dart';
import 'package:auto_spare/view/widgets/cart_screen_widgets/order_summary.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../controller/navigation/navigation.dart';
import '../themes/app_colors.dart';
import 'map_picker_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cart = CartService();

  final _nameCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _altPhoneCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();

  bool _editAddress = false;
  bool _editPhone = false;

  Position? _pos;
  double? _delLat, _delLng;

  @override
  void initState() {
    super.initState();
    final u = UserStore().currentUser;
    _nameCtrl.text = u?.name ?? '';
    _addrCtrl.text = u?.address ?? '';
    _phoneCtrl.text = u?.phone ?? '';
    _cart.addListener(_onCartChanged);
  }

  void _onCartChanged() => setState(() {});

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _phoneCtrl.dispose();
    _altPhoneCtrl.dispose();
    _deliveryCtrl.dispose();
    super.dispose();
  }

  double get _subtotal => _cart.subtotal * 1.05;

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
      MaterialPageRoute(builder: (_) => MapPickerScreen(initLat: baseLat, initLng: baseLng)),
    );
    if (res != null && mounted) {
      setState(() {
        _delLat = res.lat;
        _delLng = res.lng;
        _deliveryCtrl.text =
        res.address.isNotEmpty ? res.address : '(${res.lat.toStringAsFixed(5)}, ${res.lng.toStringAsFixed(5)})';
      });
    }
  }

  void _updateQuantity(String itemId, bool increase) {
    final item = _cart.items.firstWhere((e) => e.id == itemId);
    final next = item.quantity + (increase ? 1 : -1);
    _cart.setQuantity(itemId, next);
  }

  void _removeItem(String itemId) => _cart.remove(itemId);

  void _handleProceedToOrder() {
    if (_cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة')),
      );
      return;
    }

    final checkList = _cart.items
        .map<({String id, String name, int qty})>((e) => (id: e.id, name: e.name, qty: e.quantity))
        .toList();

    final err = Catalog().canFulfillItems(checkList);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err, textDirection: TextDirection.rtl), backgroundColor: Colors.red),
      );
      return;
    }

    final ok = Catalog().deductStockFor(
      checkList.map<({String id, int qty})>((e) => (id: e.id, qty: e.qty)).toList(),
    );
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث تغيير في المخزون. حاول مرة أخرى.', textDirection: TextDirection.rtl),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    _cart.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم تنفيذ الطلب بنجاح', textDirection: TextDirection.rtl),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(milliseconds: 1200),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
    );
  }

  void _handleCancelOrder() {
    _cart.clear();
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
    final cartItems = _cart.items;

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
                  decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder())),
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
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _altPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                const InputDecoration(labelText: 'رقم آخر للتواصل', border: OutlineInputBorder()),
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
                  decoration:
                  const InputDecoration(labelText: 'العنوان أو الإحداثيات', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: FilledButton.icon(
                          onPressed: _useCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('موقعي الحالي'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: FilledButton.tonalIcon(
                          onPressed: _pickOnMap,
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('اختيار من الخريطة'))),
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
                      item: item,
                      onQuantityChanged: (increase) => _updateQuantity(item.id, increase),
                      onRemove: () => _removeItem(item.id),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Divider(indent: 16, endIndent: 16, color: cs.outlineVariant),
              const SizedBox(height: 8),
              _customerCard(),
              const SizedBox(height: 12),
              _deliveryCard(),
              const SizedBox(height: 12),
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
