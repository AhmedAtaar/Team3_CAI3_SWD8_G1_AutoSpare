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
import 'package:auto_spare/l10n/app_localizations.dart';
import 'package:auto_spare/model/app_user.dart';
import 'package:auto_spare/services/user_session.dart';

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

  final _baseCostCtrl = TextEditingController(text: '0');
  final _kmSumCtrl = TextEditingController(text: '0.0');
  final _pricePerKmCtrl = TextEditingController(text: '0');
  final _kmCostCtrl = TextEditingController(text: '0');
  final _totalCostCtrl = TextEditingController(text: '0');

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
    if (u != null && (u.phone ?? '').isNotEmpty) {
      _phoneCtrl.text = u.phone!;
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
    final loc = AppLocalizations.of(context);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.towScreenGpsEnableSnack)));
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.towScreenLocationPermissionDeniedSnack)),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.towScreenLocationFetchErrorSnack} $e')),
      );
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
      _baseCostCtrl.text = company.baseCost.toStringAsFixed(0);
      _pricePerKmCtrl.text = company.pricePerKm.toStringAsFixed(0);
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

    _kmSumCtrl.text = kmTotal.toStringAsFixed(1);
    _kmCostCtrl.text = kmCost.toStringAsFixed(0);
    _totalCostCtrl.text = total.toStringAsFixed(0);
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
          (UserStore().currentUser!.phone ?? '').isEmpty) {
        _phoneCtrl.clear();
      }

      _baseCostCtrl.text = '0';
      _kmSumCtrl.text = '0.0';
      _pricePerKmCtrl.text = '0';
      _kmCostCtrl.text = '0';
      _totalCostCtrl.text = '0';
    });
  }

  void _goToProfile() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
      (route) => false,
    );
  }

  void _submit() async {
    final loc = AppLocalizations.of(context);

    if (_formKey.currentState?.validate() != true) return;

    if (_pos == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.towScreenLocationNotSetSnack)));
      return;
    }

    if (_selectedCompany == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.towScreenSelectCompanySnack)));
      return;
    }

    final user = UserStore().currentUser;
    final userId = user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.towScreenLoginRequiredSnack)));
      return;
    }

    final hasActive = await _userHasActiveTowRequest(userId);
    if (hasActive) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(loc.towScreenActiveTowExistsTitle),
          content: Text(
            loc.towScreenActiveTowExistsBody,
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
        title: Text(loc.towScreenConfirmDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${loc.towScreenConfirmCompanyLabel} '
                '${_selectedCompany?.name ?? '—'}',
              ),
              Text(
                '${loc.towScreenConfirmMyLocationLabel} '
                '${_addressCtrl.text}',
              ),
              Text(
                '${loc.towScreenConfirmDestinationLabel} '
                '${_destCtrl.text.isEmpty ? '—' : _destCtrl.text}',
              ),
              const SizedBox(height: 8),
              Text(
                '${loc.towScreenConfirmBaseCostLabel} '
                '${baseCost.toStringAsFixed(0)} ${loc.currencyEgpShort}',
              ),
              Text(
                '${loc.towScreenConfirmKmTotalLabel} '
                '${kmTotal.toStringAsFixed(1)} ${loc.towUnitKm}',
              ),
              Text(
                '${loc.towScreenConfirmKmPriceLabel} '
                '${pricePerKm.toStringAsFixed(0)} '
                '${loc.currencyEgpShort}/${loc.towUnitKm}',
              ),
              Text(
                '${loc.towScreenConfirmKmCostLabel} '
                '${kmCost.toStringAsFixed(0)} ${loc.currencyEgpShort}',
              ),
              Text(
                '${loc.towScreenConfirmTotalLabel} '
                '${total.toStringAsFixed(0)} ${loc.currencyEgpShort}',
              ),
              const SizedBox(height: 12),
              Text(
                '${loc.towScreenConfirmVehicleLabel} '
                '${_vehicleCtrl.text}',
              ),
              Text(
                '${loc.towScreenConfirmPlateLabel} '
                '${_plateCtrl.text}',
              ),
              Text(
                '${loc.towScreenConfirmProblemLabel} '
                '${_problemCtrl.text.isNotEmpty ? _problemCtrl.text : '—'}',
              ),
              Text(
                '${loc.towScreenConfirmPhoneLabel} '
                '${_phoneCtrl.text}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.towScreenDialogCancelButton),
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
                          title: Text(loc.towScreenRequestSentTitle),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '${loc.towScreenRequestSentBodyPrefix} '
                                '${_selectedCompany!.name}',
                              ),
                              const SizedBox(height: 8),
                              if (companyPhone.isNotEmpty) ...[
                                Text(
                                  loc.towScreenCompanyPhoneLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
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
                                        SnackBar(
                                          content: Text(
                                            loc.towScreenCallErrorSnack,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.call),
                                  label: Text(loc.towScreenCallCompanyButton),
                                ),
                              ] else ...[
                                Text(
                                  loc.towScreenNoCompanyPhoneHint,
                                  style: const TextStyle(fontSize: 12),
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
                              child: Text(loc.towScreenCloseButton),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${loc.towScreenSendErrorSnack} $e'),
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isSubmitting = false);
                      }
                    }
                  },
            child: Text(loc.towScreenDialogConfirmButton),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsHeader(BuildContext context, ThemeData theme) {
    final loc = AppLocalizations.of(context);

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
          step(1, loc.towScreenStepsStep1),
          step(2, loc.towScreenStepsStep2),
          step(3, loc.towScreenStepsStep3),
          step(4, loc.towScreenStepsStep4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final user = UserStore().currentUser;
    final baseRole = user?.role;

    final bool isAdminAccount = baseRole == AppUserRole.admin;
    final bool isSellerAccount = baseRole == AppUserRole.seller;
    final bool isWinchAccount = baseRole == AppUserRole.winch;

    final bool isInSellerMode = UserSession.isSellerNow;

    final bool shouldBlockForAdmin = isAdminAccount;

    final bool shouldBlockForSellerMode = isSellerAccount && isInSellerMode;

    final bool shouldBlock = shouldBlockForAdmin || shouldBlockForSellerMode;

    if (shouldBlock) {
      final bool isAdmin = isAdminAccount;

      final blockedBody = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                loc.towScreenRoleNotAllowedTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAdmin
                    ? loc.towScreenAdminNotAllowedBody
                    : loc.towScreenSellerNotAllowedBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _goToProfile,
                child: Text(loc.towScreenRoleNotAllowedGoProfileButton),
              ),
            ],
          ),
        ),
      );

      return AppNavigationScaffold(
        currentIndex: 2,
        title: loc.towScreenTitle,
        body: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SafeArea(child: blockedBody),
        ),
      );
    }

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
                _buildStepsHeader(context, theme),

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
                      children: [
                        const Icon(Icons.warning_amber_rounded),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc.towScreenLocationPendingWarning,
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
                      children: [
                        const Icon(Icons.check_circle_outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc.towScreenLocationReadyMessage,
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
                      loc.towScreenCurrentLocationSectionTitle,
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
                  decoration: InputDecoration(
                    labelText: loc.towScreenCurrentCoordsLabel,
                    border: const OutlineInputBorder(),
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
                          label: Text(loc.towScreenUseMyLocationButton),
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
                          label: Text(loc.towScreenPickFromMapButton),
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
                            '${loc.towScreenSelectedCompanyPrefix} '
                            '${_selectedCompany!.name} '
                            '(${_selectedCompany!.area})\n'
                            '${loc.towScreenSelectedCompanyDistancePrefix} '
                            '${(_companyDistKm ?? 0).toStringAsFixed(1)} '
                            '${loc.towUnitKm} • '
                            '${loc.towScreenSelectedCompanyBaseCostPrefix} '
                            '${_selectedCompany!.baseCost.toStringAsFixed(0)} '
                            '${loc.currencyEgpShort} • '
                            '${loc.towScreenSelectedCompanyKmPricePrefix} '
                            '${_selectedCompany!.pricePerKm.toStringAsFixed(0)} '
                            '${loc.currencyEgpShort}/${loc.towUnitKm}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: _pos == null ? null : _openCompanies,
                          child: Text(loc.towScreenSelectedCompanyChangeButton),
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
                                ? loc.towScreenSelectedCompanyHintNoLocation
                                : loc.towScreenSelectedCompanyHintChoose,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: _pos == null ? null : _openCompanies,
                          child: Text(
                            loc.towScreenSelectedCompanyShowCompaniesButton,
                          ),
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
                      loc.towScreenDestinationSectionTitle,
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
                        decoration: InputDecoration(
                          labelText: loc.towScreenDestinationAddressLabel,
                          hintText: loc.towScreenDestinationAddressHint,
                          border: const OutlineInputBorder(),
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
                        label: Text(loc.towScreenDestinationMapButton),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Text(
                  loc.towScreenDestinationOptionalHint,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(Icons.request_quote_outlined, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      loc.towScreenCostsSectionTitle,
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
                  decoration: InputDecoration(
                    labelText: loc.towScreenCostsBaseLabel,
                    suffixText: loc.currencyEgpShort,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _kmSumCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: loc.towScreenCostsKmTotalLabel,
                    suffixText: loc.towUnitKm,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _pricePerKmCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: loc.towScreenCostsKmPriceLabel,
                    suffixText: '${loc.currencyEgpShort}/${loc.towUnitKm}',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _kmCostCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: loc.towScreenCostsKmCostLabel,
                    suffixText: loc.currencyEgpShort,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _totalCostCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: loc.towScreenCostsTotalLabel,
                    suffixText: loc.currencyEgpShort,
                    border: const OutlineInputBorder(),
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
                      loc.towScreenVehicleSectionTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _vehicleCtrl,
                  decoration: InputDecoration(
                    labelText: loc.towScreenVehicleTypeLabel,
                    hintText: loc.towScreenVehicleTypeHint,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? loc.towScreenRequiredFieldError
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _plateCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: loc.towScreenPlateLabel,
                    hintText: loc.towScreenPlateHint,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? loc.towScreenRequiredFieldError
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _problemCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: loc.towScreenProblemLabel,
                    hintText: loc.towScreenProblemHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(Icons.call_outlined, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      loc.towScreenContactSectionTitle,
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
                  decoration: InputDecoration(
                    labelText: loc.towScreenPhoneLabel,
                    hintText: loc.towScreenPhoneHint,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return loc.towScreenRequiredFieldError;
                    }
                    if (v.replaceAll(RegExp(r'[\s\-\+]'), '').length < 9) {
                      return loc.towScreenPhoneInvalidError;
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
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.towScreenEtaTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(loc.towScreenEtaValue),
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
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(loc.towScreenSubmitButtonSending),
                            ],
                          )
                        : Text(loc.towScreenSubmitButtonLabel),
                  ),
                ),
                if (!canSubmit)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      loc.towScreenSubmitHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
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
                  label: Text(loc.towScreenFloatingNearestCompanies),
                ),
              ),
          ],
        ),
      ),
    );

    return AppNavigationScaffold(
      currentIndex: 2,
      title: loc.towScreenTitle,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: content,
      ),
    );
  }
}
