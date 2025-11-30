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

  LatLng _pin = LatLng(0, 0);
  String _addr = '';

  final TextEditingController _searchCtrl = TextEditingController();

  bool _isLoading = false;
  List<_PlaceSuggestion> _suggestions = [];
  Timer? _debounce;

  bool _ignoreSearchChange = false;

  int _lastRequestId = 0;

  @override
  void initState() {
    super.initState();
    _pin = LatLng(widget.initLat, widget.initLng);
    _reverseFromPin();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _reverseFromPin() async {
    try {
      final list = await placemarkFromCoordinates(
        _pin.latitude,
        _pin.longitude,
      );
      if (list.isNotEmpty) {
        final p = list.first;
        final addr = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((e) => (e ?? '').trim().isNotEmpty).join('، ');

        if (!mounted) return;
        setState(() {
          _addr = addr;
        });

        _ignoreSearchChange = true;
        _searchCtrl.text = addr;
        _ignoreSearchChange = false;
      }
    } catch (_) {}
  }

  Future<void> _goToLatLng(LatLng target, {String? displayName}) async {
    setState(() {
      _pin = target;
      if (displayName != null && displayName.trim().isNotEmpty) {
        _addr = displayName;
      }
    });

    _map.move(target, 15);

    if (displayName == null) {
      await _reverseFromPin();
    } else {
      _ignoreSearchChange = true;
      _searchCtrl.text = displayName;
      _ignoreSearchChange = false;
    }
  }

  void _onQueryChanged(String q) {
    if (_ignoreSearchChange) return;

    setState(() {});

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(q);
    });
  }

  Future<void> _fetchSuggestions(String q, {bool moveToFirst = false}) async {
    q = q.trim();
    if (q.length < 3) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    final int requestId = ++_lastRequestId;

    setState(() {
      _isLoading = true;
      if (!moveToFirst) {
        _suggestions = [];
      }
    });

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeQueryComponent(q)}'
        '&format=json&addressdetails=1&limit=5&accept-language=ar,en',
      );

      final res = await http.get(
        uri,
        headers: const {
          'User-Agent': 'auto_spare_app/1.0 (your-email@example.com)',
        },
      );

      if (!mounted || requestId != _lastRequestId) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        final list = data
            .map<_PlaceSuggestion?>((e) {
              final latStr = e['lat'] as String?;
              final lonStr = e['lon'] as String?;
              final name = e['display_name'] as String? ?? '';

              final lat = double.tryParse(latStr ?? '');
              final lon = double.tryParse(lonStr ?? '');
              if (lat == null || lon == null) return null;

              return _PlaceSuggestion(name: name, point: LatLng(lat, lon));
            })
            .whereType<_PlaceSuggestion>()
            .toList();

        if (moveToFirst && list.isNotEmpty) {
          final first = list.first;
          setState(() {
            _suggestions = list;
          });
          await _goToLatLng(first.point, displayName: first.name);
        } else {
          setState(() {
            _suggestions = list;
          });
        }
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    } catch (_) {
      if (!mounted || requestId != _lastRequestId) return;
      setState(() {
        _suggestions = [];
      });
    } finally {
      if (!mounted || requestId != _lastRequestId) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchByAddressSubmit() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;

    _debounce?.cancel();
    await _fetchSuggestions(q, moveToFirst: true);
  }

  void _onSuggestionTap(_PlaceSuggestion s) {
    FocusScope.of(context).unfocus();

    _ignoreSearchChange = true;
    _searchCtrl.text = s.name;
    _ignoreSearchChange = false;

    setState(() => _suggestions = []);
    _goToLatLng(s.point, displayName: s.name);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _ignoreSearchChange = true;
    _searchCtrl.clear();
    _ignoreSearchChange = false;

    setState(() {
      _suggestions = [];
      _isLoading = false;
    });
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

    final hasQuery = _searchCtrl.text.trim().length >= 3;

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
                  setState(() {
                    _pin = latlng;
                    _suggestions = [];
                  });
                  _reverseFromPin();
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
              top: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchByAddressSubmit(),
                      onChanged: _onQueryChanged,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن عنوان أو مكان...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        suffixIcon: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_searchCtrl.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: _clearSearch,
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: _searchByAddressSubmit,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  if (_isLoading && _suggestions.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(blurRadius: 4, color: Colors.black12),
                        ],
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (_suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(blurRadius: 6, color: Colors.black12),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final s = _suggestions[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.place_outlined),
                            title: Text(
                              s.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                            onTap: () => _onSuggestionTap(s),
                          );
                        },
                      ),
                    )
                  else if (hasQuery && !_isLoading)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(blurRadius: 4, color: Colors.black12),
                        ],
                      ),
                      child: const Text(
                        'لا توجد نتائج لهذا البحث حاليًا.\n'
                        'جرّب تعديل العنوان أو التأكد من اتصال الإنترنت.',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
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

class _PlaceSuggestion {
  final String name;
  final LatLng point;
  _PlaceSuggestion({required this.name, required this.point});
}
