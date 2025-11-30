import 'package:auto_spare/model/order.dart';
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
import 'package:auto_spare/services/orders.dart';
import 'package:auto_spare/services/coupons_repo.dart';

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

  double _discount = 0.0;
  String? _couponCode;
  String? _orderNote;

  bool _isSubmittingOrder = false;

  @override
  void initState() {
    super.initState();
    final u = UserStore().currentUser;
    _nameCtrl.text = u?.name ?? '';
    _addrCtrl.text = u?.address ?? '';
    _phoneCtrl.text = u?.phone ?? '';
    _cart.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    setState(() {
      if (_cart.items.isEmpty) {
        _discount = 0.0;
        _couponCode = null;
        _orderNote = null;
      }
    });
  }

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

  double get _subtotal => _cart.subtotal;
  double get _shipping => 15.0;

  double get _grandTotal {
    final total = _subtotal + _shipping - _discount;
    return total < 0 ? 0 : total;
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
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return;
    }

    final p = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (!mounted) return;
    setState(() {
      _pos = p;
      _delLat = p.latitude;
      _delLng = p.longitude;
      _deliveryCtrl.text =
          '(${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)})';
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
    final item = _cart.items.firstWhere((e) => e.id == itemId);
    final next = item.quantity + (increase ? 1 : -1);

    if (!increase && next <= 0) {
      _cart.setQuantity(itemId, next);
      return;
    }

    if (increase && next > item.maxQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يمكنك طلب أكثر من المتاح في المخزون (${item.maxQty})',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
      return;
    }

    _cart.setQuantity(itemId, next);
  }

  void _removeItem(String itemId) => _cart.remove(itemId);

  Future<void> _handleApplyCoupon(String code) async {
    final upper = code.trim().toUpperCase();
    if (upper.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'من فضلك أدخل كود الخصم',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
      return;
    }

    try {
      final coupon = await couponsRepo.getByCode(upper);
      if (coupon == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كود خصم غير صالح', textDirection: TextDirection.rtl),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _discount = 0.0;
          _couponCode = null;
        });
        return;
      }

      if (!coupon.isUsable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'هذا الكود غير مفعّل أو منتهي الصلاحية',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _discount = 0.0;
          _couponCode = null;
        });
        return;
      }

      final sellerItems = _cart.items
          .where((e) => e.sellerId == coupon.sellerId)
          .toList();

      if (sellerItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لا توجد منتجات في السلة من البائع صاحب هذا الكود',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _discount = 0.0;
          _couponCode = null;
        });
        return;
      }

      double sellerSubtotal = 0.0;
      for (final item in sellerItems) {
        sellerSubtotal += item.price * item.quantity;
      }

      double newDiscount = sellerSubtotal * (coupon.discountPercent / 100.0);

      final maxAllowed = _subtotal + _shipping;
      if (newDiscount > maxAllowed) newDiscount = maxAllowed;

      setState(() {
        _discount = newDiscount;
        _couponCode = upper;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تطبيق كود الخصم: $upper',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حصل خطأ أثناء تطبيق الكود: $e',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleProceedToOrder() async {
    if (_isSubmittingOrder) return;

    if (_cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('السلة فارغة')));
      return;
    }

    final buyer = UserStore().currentUser;
    if (buyer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك قم بتسجيل الدخول أولاً')),
      );
      return;
    }

    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('من فضلك أدخل اسم العميل')));
      return;
    }
    if (_addrCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('من فضلك أدخل العنوان')));
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك أدخل رقم التليفون')),
      );
      return;
    }

    final buyerId = buyer.id;

    final orderItems = _cart.items.map((ci) {
      return OrderItem(
        productId: ci.id,
        sellerId: ci.sellerId,
        titleSnap: ci.name,
        price: ci.price,
        qty: ci.quantity,
      );
    }).toList();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الطلب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('العميل: ${_nameCtrl.text}'),
              Text('العنوان: ${_addrCtrl.text}'),
              Text('رقم التليفون: ${_phoneCtrl.text}'),
              if (_deliveryCtrl.text.trim().isNotEmpty)
                Text('موقع التسليم: ${_deliveryCtrl.text}'),
              const SizedBox(height: 8),
              Text('عدد العناصر: ${_cart.totalItems}'),
              Text('إجمالي المنتجات: ${_subtotal.toStringAsFixed(2)} ج'),
              Text('الشحن: ${_shipping.toStringAsFixed(2)} ج'),
              if (_discount > 0)
                Text('الخصم: - ${_discount.toStringAsFixed(2)} ج'),
              const Divider(),
              Text(
                'الإجمالي النهائي: ${_grandTotal.toStringAsFixed(2)} ج',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_orderNote != null && _orderNote!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('ملاحظة: ${_orderNote!}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('رجوع'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmittingOrder = true);

    try {
      final (orderId, code) = await ordersRepo.createOrder(
        buyerId: buyerId,
        items: orderItems,
        itemsTotal: _subtotal,
        shipping: _shipping,
        discount: _discount,
        couponCode: _couponCode,
        note: _orderNote,
        lat: _delLat,
        lng: _delLng,
      );

      _cart.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إنشاء الطلب ($code) • #$orderId',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(milliseconds: 1400),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), textDirection: TextDirection.rtl),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingOrder = false);
      }
    }
  }

  void _handleCancelOrder() {
    _cart.clear();
    setState(() {
      _discount = 0.0;
      _couponCode = null;
      _orderNote = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم إلغاء جميع العناصر في السلة',
          textDirection: TextDirection.rtl,
        ),
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
              Row(
                children: const [
                  Icon(Icons.person_outline),
                  SizedBox(width: 8),
                  Text('بيانات العميل'),
                ],
              ),
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
                    onPressed: () =>
                        setState(() => _editAddress = !_editAddress),
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
              Row(
                children: const [
                  Icon(Icons.place_outlined),
                  SizedBox(width: 8),
                  Text('موقع التسليم (اختياري)'),
                ],
              ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: cartItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: Text(
                            'عربة التسوق فارغة',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.grey),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      )
                    : Column(
                        children: cartItems.map((item) {
                          return CartItemCard(
                            item: item,
                            onQuantityChanged: (increase) =>
                                _updateQuantity(item.id, increase),
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
                shipping: _shipping,
                grandTotal: _grandTotal,
                discount: _discount,
                itemCount: cartItems.length,
                onProceedToOrder: _handleProceedToOrder,
                onCancel: _handleCancelOrder,
                onApplyCoupon: _handleApplyCoupon,
                onNoteChanged: (note) {
                  _orderNote = note;
                },
                isSubmitting: _isSubmittingOrder,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
