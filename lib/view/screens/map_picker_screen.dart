import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class MapPickResult {
  final String address;
  final double lat;
  final double lng;
  const MapPickResult({
    required this.address,
    required this.lat,
    required this.lng,
  });
}

class MapPickerScreen extends StatefulWidget {
  final double initLat;
  final double initLng;
  const MapPickerScreen({
    super.key,
    required this.initLat,
    required this.initLng,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _map = MapController();

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  LatLng _pin = LatLng(0, 0);
  String _addr = '';

  List<_PlaceResult> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _pin = LatLng(widget.initLat, widget.initLng);
    _reverse();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _reverse() async {
    try {
      final list = await placemarkFromCoordinates(
        _pin.latitude,
        _pin.longitude,
      );
      if (list.isNotEmpty) {
        final p = list.first;
        setState(() {
          _addr = [
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
            p.country,
          ].where((e) => (e ?? '').trim().isNotEmpty).join('، ');
        });
      }
    } catch (_) {}
  }

  void _confirm() {
    Navigator.pop(
      context,
      MapPickResult(address: _addr, lat: _pin.latitude, lng: _pin.longitude),
    );
  }

  Future<void> _searchPlaces(String q) async {
    q = q.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _results = [];
    });

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': q,
        'format': 'json',
        'addressdetails': '1',
        'limit': '5',
        'accept-language': 'ar,en',
      });

      final res = await http.get(
        uri,
        headers: const {
          'User-Agent': 'autospare-app/1.0 (your_email@example.com)',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;

        final list = data
            .map<_PlaceResult?>((e) {
              final latStr = e['lat'] as String?;
              final lonStr = e['lon'] as String?;
              final name = e['display_name'] as String? ?? '';

              final lat = double.tryParse(latStr ?? '');
              final lon = double.tryParse(lonStr ?? '');
              if (lat == null || lon == null) return null;

              return _PlaceResult(name: name, lat: lat, lng: lon);
            })
            .whereType<_PlaceResult>()
            .toList();

        setState(() {
          _results = list;
        });
      } else {
        debugPrint('Nominatim error: ${res.statusCode} ${res.body}');
        setState(() => _results = []);
      }
    } catch (e) {
      debugPrint('Nominatim exception: $e');
      setState(() => _results = []);
    } finally {
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(value);
    });
  }

  void _selectPlace(_PlaceResult p) {
    FocusScope.of(context).unfocus();
    setState(() {
      _pin = LatLng(p.lat, p.lng);
      _addr = p.name;
      _results = [];
    });
    _map.move(_pin, 16);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اختيار مكان الوصول'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: _pin,
                initialZoom: 14,
                onTap: (tapPos, latlng) {
                  setState(() => _pin = latlng);
                  _reverse();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.auto_spare',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pin,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(24),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'ابحث عن مكان (مسجد – شارع – منطقة...)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            if (_results.isNotEmpty)
              Positioned(
                left: 12,
                right: 12,
                top: 70,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final p = _results[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.place_outlined),
                          title: Text(p.name, textAlign: TextAlign.right),
                          onTap: () => _selectPlace(p),
                        );
                      },
                    ),
                  ),
                ),
              )
            else if (_isSearching)
              Positioned(
                left: 12,
                right: 12,
                top: 70,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              left: 12,
              right: 12,
              bottom: 90,
              child: Card(
                color: theme.colorScheme.surface.withOpacity(.95),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _addr.isEmpty ? 'جارِ تحديد العنوان…' : _addr,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: FilledButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check),
                label: const Text('اختيار هذا المكان'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceResult {
  final String name;
  final double lat;
  final double lng;
  _PlaceResult({required this.name, required this.lat, required this.lng});
}
