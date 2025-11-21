// lib/services/tow_directory.dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class TowCompany {
  final String id;
  final String name;
  final String area;
  final double lat;
  final double lng;
  final double baseCost;
  final double pricePerKm;


  final bool isOnline;

  const TowCompany({
    required this.id,
    required this.name,
    required this.area,
    required this.lat,
    required this.lng,
    required this.baseCost,
    required this.pricePerKm,
    this.isOnline = true,
  });

  TowCompany copyWith({
    String? name,
    String? area,
    double? lat,
    double? lng,
    double? baseCost,
    double? pricePerKm,
    bool? isOnline,
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
    );
  }
}

class TowDirectory extends ChangeNotifier {
  TowDirectory._internal() {
    _approved.addAll(const [
      TowCompany(
        id: 'c1',
        name: 'شركة الفضل للأوناش',
        area: 'المعادي',
        lat: 29.9600,
        lng: 31.2610,
        baseCost: 300,
        pricePerKm: 50,
        isOnline: true,
      ),
      TowCompany(
        id: 'c2',
        name: 'السفير للأوناش',
        area: 'المهندسين',
        lat: 30.0480,
        lng: 31.2030,
        baseCost: 270,
        pricePerKm: 44,
        isOnline: true,
      ),
      TowCompany(
        id: 'c3',
        name: 'هليوبليس سيرفز لخدمات الاوناش',
        area: 'مصر الجديدة',
        lat: 30.0870,
        lng: 31.3440,
        baseCost: 400,
        pricePerKm: 38,
        isOnline: true,
      ),
      TowCompany(
        id: 'c4',
        name: 'اريزونا لأعطال السيارات وسحب السيارات',
        area: 'التحرير',
        lat: 30.0444,
        lng: 31.2357,
        baseCost: 300,
        pricePerKm: 50,
        isOnline: true,
      ),
      TowCompany(
        id: 'c5',
        name: 'النسر – لخدمات الأعطال',
        area: 'القاهرة الجديدة',
        lat: 30.0074,
        lng: 31.4913,
        baseCost: 300,
        pricePerKm: 45,
        isOnline: true,
      ),
      TowCompany(
        id: 'c6',
        name: 'الأمل لخدمات الأوناش',
        area: 'القاهرة الجديدة',
        lat: 30.0230,
        lng: 31.4350,
        baseCost: 300,
        pricePerKm: 70,
        isOnline: false, // أوفلاين
      ),
      TowCompany(
        id: 'c7',
        name: 'الحرية للأعطال وسحب السيارات',
        area: '٦ أكتوبر',
        lat: 29.9389,
        lng: 30.9138,
        baseCost: 250,
        pricePerKm: 55,
        isOnline: true,
      ),
    ]);
  }

  static final TowDirectory _i = TowDirectory._internal();
  factory TowDirectory() => _i;

  final List<TowCompany> _approved = [];


  List<TowCompany> get all => List.unmodifiable(_approved);


  List<TowCompany> get onlineOnly =>
      _approved.where((c) => c.isOnline).toList(growable: false);

  bool isOnline(String id) =>
      _approved.any((c) => c.id == id && c.isOnline);

  void setOnline(String id, bool online) {
    final i = _approved.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _approved[i] = _approved[i].copyWith(isOnline: online);
    notifyListeners();
  }

  void toggleOnline(String id) {
    final i = _approved.indexWhere((c) => c.id == id);
    if (i == -1) return;
    final cur = _approved[i].isOnline;
    _approved[i] = _approved[i].copyWith(isOnline: !cur);
    notifyListeners();
  }

  void addApproved(TowCompany c) {
    final idx = _approved.indexWhere((x) => x.id == c.id);
    if (idx == -1) {
      _approved.add(c);
    } else {
      _approved[idx] = c;
    }
    notifyListeners();
  }


  TowCompany? nearestOnline(double userLat, double userLng) {
    final online = _approved.where((c) => c.isOnline).toList();
    if (online.isEmpty) return null;

    online.sort((a, b) {
      final da = Geolocator.distanceBetween(
        userLat,
        userLng,
        a.lat,
        a.lng,
      );
      final db = Geolocator.distanceBetween(
        userLat,
        userLng,
        b.lat,
        b.lng,
      );
      return da.compareTo(db);
    });

    return online.first;
  }


  TowCompany? nearestAny(double userLat, double userLng) {
    if (_approved.isEmpty) return null;

    final list = List<TowCompany>.from(_approved);
    list.sort((a, b) {
      final da = Geolocator.distanceBetween(
        userLat,
        userLng,
        a.lat,
        a.lng,
      );
      final db = Geolocator.distanceBetween(
        userLat,
        userLng,
        b.lat,
        b.lng,
      );
      return da.compareTo(db);
    });

    return list.first;
  }
}
