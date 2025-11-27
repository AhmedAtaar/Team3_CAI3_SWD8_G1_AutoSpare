import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TowCompany {
  final String id;
  final String name;
  final String area;
  final double lat;
  final double lng;
  final double baseCost;
  final double pricePerKm;
  final bool isOnline;

  final String? phone;

  const TowCompany({
    required this.id,
    required this.name,
    required this.area,
    required this.lat,
    required this.lng,
    required this.baseCost,
    required this.pricePerKm,
    this.isOnline = true,
    this.phone,
  });

  TowCompany copyWith({
    String? name,
    String? area,
    double? lat,
    double? lng,
    double? baseCost,
    double? pricePerKm,
    bool? isOnline,
    String? phone,
  }) {
    return TowCompany(
      id: id,
      name: name ?? this.name,
      area: area ?? this.area,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      baseCost: baseCost ?? this.baseCost,
      pricePerKm: pricePerKm ?? this.pricePerKm,
      isOnline: isOnline ?? this.isOnline,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'area': area,
      'lat': lat,
      'lng': lng,
      'baseCost': baseCost,
      'pricePerKm': pricePerKm,
      'isOnline': isOnline,
      'phone': phone,
    };
  }

  factory TowCompany.fromMap(String id, Map<String, dynamic> data) {
    return TowCompany(
      id: id,
      name: (data['name'] ?? '') as String,
      area: (data['area'] ?? '') as String,
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      baseCost: (data['baseCost'] as num).toDouble(),
      pricePerKm: (data['pricePerKm'] as num).toDouble(),
      isOnline: (data['isOnline'] as bool?) ?? true,
      phone: data['phone'] as String?,
    );
  }
}

class TowDirectory extends ChangeNotifier {
  TowDirectory._internal() {
    _subscribeFirestore();
  }

  static final TowDirectory _i = TowDirectory._internal();
  factory TowDirectory() => _i;

  final List<TowCompany> _approved = [];

  final _col = FirebaseFirestore.instance.collection('tow_companies');

  void _subscribeFirestore() {
    _col.snapshots().listen((snapshot) {
      _approved.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        try {
          final company = TowCompany.fromMap(doc.id, data);
          _approved.add(company);
        } catch (_) {}
      }
      notifyListeners();
    });
  }

  List<TowCompany> get all => List.unmodifiable(_approved);

  List<TowCompany> get onlineOnly =>
      _approved.where((c) => c.isOnline).toList(growable: false);

  bool isOnline(String id) => _approved.any((c) => c.id == id && c.isOnline);

  void setOnline(String id, bool online) {
    final i = _approved.indexWhere((c) => c.id == id);
    if (i == -1) return;
    final updated = _approved[i].copyWith(isOnline: online);
    _approved[i] = updated;

    _col.doc(id).set(updated.toMap(), SetOptions(merge: true));
    notifyListeners();
  }

  void toggleOnline(String id) {
    final i = _approved.indexWhere((c) => c.id == id);
    if (i == -1) return;
    final cur = _approved[i].isOnline;
    setOnline(id, !cur);
  }

  void addApproved(TowCompany c) {
    final idx = _approved.indexWhere((x) => x.id == c.id);
    if (idx == -1) {
      _approved.add(c);
    } else {
      _approved[idx] = c;
    }

    _col.doc(c.id).set(c.toMap(), SetOptions(merge: true));
    notifyListeners();
  }

  TowCompany? nearestOnline(double userLat, double userLng) {
    final online = _approved.where((c) => c.isOnline).toList();
    if (online.isEmpty) return null;

    online.sort((a, b) {
      final da = Geolocator.distanceBetween(userLat, userLng, a.lat, a.lng);
      final db = Geolocator.distanceBetween(userLat, userLng, b.lat, b.lng);
      return da.compareTo(db);
    });

    return online.first;
  }

  TowCompany? nearestAny(double userLat, double userLng) {
    if (_approved.isEmpty) return null;

    final list = List<TowCompany>.from(_approved);
    list.sort((a, b) {
      final da = Geolocator.distanceBetween(userLat, userLng, a.lat, a.lng);
      final db = Geolocator.distanceBetween(userLat, userLng, b.lat, b.lng);
      return da.compareTo(db);
    });

    return list.first;
  }
}
