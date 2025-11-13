// lib/view/screens/tow_location_picker.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

class TowPickedLocation {
  final double lat;
  final double lng;
  const TowPickedLocation(this.lat, this.lng);
}

class TowLocationPickerScreen extends StatefulWidget {
  const TowLocationPickerScreen({super.key});
  @override
  State<TowLocationPickerScreen> createState() => _TowLocationPickerScreenState();
}

class _TowLocationPickerScreenState extends State<TowLocationPickerScreen> {
  final _lat = TextEditingController();
  final _lng = TextEditingController();

  @override
  void dispose() {
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فعّل خدمات الموقع أولًا')));
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض إذن الموقع')));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('إذن الموقع مرفوض دائمًا')));
      return;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _lat.text = pos.latitude.toStringAsFixed(6);
    _lng.text = pos.longitude.toStringAsFixed(6);
    setState(() {});
  }

  ll.LatLng? _currentLatLng() {
    final la = double.tryParse(_lat.text.trim());
    final ln = double.tryParse(_lng.text.trim());
    if (la == null || ln == null) return null;
    return ll.LatLng(la, ln);
  }

  Future<void> _openMap() async {
    final initial = _currentLatLng() ?? const ll.LatLng(30.044420, 31.235712); // Cairo fallback
    final picked = await Navigator.push<ll.LatLng>(
      context,
      MaterialPageRoute(builder: (_) => _TowMapPickerFlutterMap(initial: initial)),
    );
    if (picked != null) {
      _lat.text = picked.latitude.toStringAsFixed(6);
      _lng.text = picked.longitude.toStringAsFixed(6);
      setState(() {});
    }
  }

  void _save() {
    final la = double.tryParse(_lat.text.trim());
    final ln = double.tryParse(_lng.text.trim());
    if (la == null || ln == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل إحداثيات صحيحة')));
      return;
    }
    Navigator.pop(context, TowPickedLocation(la, ln));
  }

  InputDecoration _dec(String label) =>
      InputDecoration(labelText: label, border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اختيار اللوكيشن')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _useMyLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('استخدام موقعي الآن'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openMap,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('اختيار من الخريطة'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _lat,
                      keyboardType: TextInputType.number,
                      decoration: _dec('Latitude'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _lng,
                      keyboardType: TextInputType.number,
                      decoration: _dec('Longitude'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('حفظ'),
                ),
              ),
              const SizedBox(height: 8),
              const Text('اختر موقعك الحالي أو افتح الخريطة لتحديد النقطة.'),
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة الخريطة باستخدام flutter_map + OpenStreetMap
class _TowMapPickerFlutterMap extends StatefulWidget {
  final ll.LatLng initial;
  const _TowMapPickerFlutterMap({required this.initial});

  @override
  State<_TowMapPickerFlutterMap> createState() => _TowMapPickerFlutterMapState();
}

class _TowMapPickerFlutterMapState extends State<_TowMapPickerFlutterMap> {
  late ll.LatLng _picked;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
  }

  void _onMapTap(TapPosition tapPos, ll.LatLng point) {
    setState(() => _picked = point);
  }

  Future<void> _gotoMyLocation() async {
    final ok = await Geolocator.isLocationServiceEnabled();
    if (!ok) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final here = ll.LatLng(pos.latitude, pos.longitude);
    _mapController.move(here, 15);
    setState(() => _picked = here);
  }

  void _done() => Navigator.pop(context, _picked);

  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      point: _picked,
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on, size: 40, color: Colors.red),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اختيار من الخريطة'),
          actions: [
            IconButton(onPressed: _gotoMyLocation, icon: const Icon(Icons.my_location)),
            TextButton.icon(
              onPressed: _done,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('تم', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initial,
            initialZoom: 14,
            onTap: _onMapTap,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.autospare',
            ),
            MarkerLayer(markers: [marker]),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '(${_picked.latitude.toStringAsFixed(6)}, ${_picked.longitude.toStringAsFixed(6)})',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _done,
                  icon: const Icon(Icons.save),
                  label: const Text('اختيار هذه النقطة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
