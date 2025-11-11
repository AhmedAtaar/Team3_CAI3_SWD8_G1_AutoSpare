import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

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
  LatLng _pin = LatLng(0, 0);
  String _addr = '';

  @override
  void initState() {
    super.initState();
    _pin = LatLng(widget.initLat, widget.initLng);
    _reverse();
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
