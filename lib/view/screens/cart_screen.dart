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
import 'package:auto_spare/l10n/app_localizations.dart';

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

  double get _shipping => 45.0;

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
    final loc = AppLocalizations.of(context);
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
            '${loc.cart_quantity_exceeds_stock_prefix} (${item.maxQty})',
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
    final loc = AppLocalizations.of(context);
    final upper = code.trim().toUpperCase();
    if (upper.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.cart_coupon_enter_code_message,
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
          SnackBar(
            content: Text(
              loc.cart_coupon_invalid_message,
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

      if (!coupon.isUsable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.cart_coupon_not_usable_message,
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
          SnackBar(
            content: Text(
              loc.cart_coupon_seller_mismatch_message,
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
            '${loc.cart_coupon_applied_prefix} $upper',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${loc.cart_coupon_apply_error_prefix} $e',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleProceedToOrder() async {
    final loc = AppLocalizations.of(context);
    if (_isSubmittingOrder) return;

    if (_cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.cart_empty_message)));
      return;
    }

    final buyer = UserStore().currentUser;
    if (buyer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.cart_login_required_message)));
      return;
    }

    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.cart_enter_name_message)));
      return;
    }
    if (_addrCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.cart_enter_address_message)));
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.cart_enter_phone_message)));
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
          title: Text(loc.cart_confirm_dialog_title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${loc.cart_confirm_customer_label} ${_nameCtrl.text}'),
              Text('${loc.cart_confirm_address_label} ${_addrCtrl.text}'),
              Text('${loc.cart_confirm_phone_label} ${_phoneCtrl.text}'),
              if (_deliveryCtrl.text.trim().isNotEmpty)
                Text(
                  '${loc.cart_confirm_delivery_location_label} ${_deliveryCtrl.text}',
                ),
              const SizedBox(height: 8),
              Text('${loc.cart_confirm_items_count_label} ${_cart.totalItems}'),
              Text(
                '${loc.cart_confirm_items_total_label} ${_subtotal.toStringAsFixed(2)} ${loc.currency_egp}',
              ),
              Text(
                '${loc.cart_confirm_shipping_label} ${_shipping.toStringAsFixed(2)} ${loc.currency_egp}',
              ),
              if (_discount > 0)
                Text(
                  '${loc.cart_confirm_discount_label} ${_discount.toStringAsFixed(2)} ${loc.currency_egp}',
                ),
              const Divider(),
              Text(
                '${loc.cart_confirm_grand_total_label} ${_grandTotal.toStringAsFixed(2)} ${loc.currency_egp}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_orderNote != null && _orderNote!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('${loc.cart_confirm_note_label} ${_orderNote!}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(loc.admin_common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(loc.cart_confirm_button),
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
            '${loc.cart_order_created_prefix} ($code) • #$orderId',
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
    final loc = AppLocalizations.of(context);
    _cart.clear();
    setState(() {
      _discount = 0.0;
      _couponCode = null;
      _orderNote = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.cart_cancel_all_items_message,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _customerCard(AppLocalizations loc, ColorScheme cs, bool isArabic) {
    final labelStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: cs.onSurface.withOpacity(.8),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(.18),
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: isArabic
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_outline, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.cart_customer_section_title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.verified_user_outlined,
                    size: 20,
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: loc.cart_customer_name_label,
                  labelStyle: labelStyle,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addrCtrl,
                readOnly: !_editAddress,
                decoration: InputDecoration(
                  labelText: loc.cart_customer_address_label,
                  labelStyle: labelStyle,
                  prefixIcon: const Icon(Icons.home_work_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _editAddress = !_editAddress),
                    icon: Icon(
                      _editAddress ? Icons.check_circle : Icons.edit_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                readOnly: !_editPhone,
                decoration: InputDecoration(
                  labelText: loc.cart_customer_phone_label,
                  labelStyle: labelStyle,
                  prefixIcon: const Icon(Icons.phone_iphone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _editPhone = !_editPhone),
                    icon: Icon(
                      _editPhone ? Icons.check_circle : Icons.edit_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _altPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: loc.cart_customer_alt_phone_label,
                  labelStyle: labelStyle,
                  prefixIcon: const Icon(Icons.phone_enabled_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deliveryCard(AppLocalizations loc, ColorScheme cs, bool isArabic) {
    final noteColor = cs.onSurface.withOpacity(.65);

    final deliveryNote = loc.cart_delivery_fees_note;
    final cashNote = loc.cart_delivery_payment_note;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(.18),
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: isArabic
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.place_outlined, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.cart_delivery_section_title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _deliveryCtrl,
                decoration: InputDecoration(
                  labelText: loc.cart_delivery_input_label,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _useCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: Text(loc.cart_delivery_current_location_button),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _pickOnMap,
                      icon: const Icon(Icons.map_outlined),
                      label: Text(loc.cart_delivery_pick_on_map_button),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: noteColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      deliveryNote,
                      style: TextStyle(fontSize: 12, color: noteColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.payments_outlined, size: 18, color: noteColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      cashNote,
                      style: TextStyle(fontSize: 12, color: noteColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _electronicPaymentSoonCard(BuildContext context, bool isArabic) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    final title = loc.cart_electronic_payment_title;
    final subtitle = loc.cart_electronic_payment_subtitle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.96, end: 1.0),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: GestureDetector(
          onTap: () {
            final msg = loc.cart_electronic_payment_soon_message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  msg,
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGreen, cs.primary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(.35),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.credit_card_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.86),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    loc.cart_electronic_payment_soon_chip,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cartItems = _cart.items;
    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return AppNavigationScaffold(
      currentIndex: 3,
      title: loc.cart_title,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
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
                            loc.cart_empty_title,
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
              _customerCard(loc, cs, isArabic),
              const SizedBox(height: 12),
              _deliveryCard(loc, cs, isArabic),
              const SizedBox(height: 12),
              _electronicPaymentSoonCard(context, isArabic),
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
