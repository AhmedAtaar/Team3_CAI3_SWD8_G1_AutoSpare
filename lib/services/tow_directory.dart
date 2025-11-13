// lib/services/tow_directory.dart
import 'package:flutter/foundation.dart';

class TowCompany {
  final String id;
  final String name;
  final String area;
  final double lat;
  final double lng;
  final double baseCost;
  final double pricePerKm;

  const TowCompany({
    required this.id,
    required this.name,
    required this.area,
    required this.lat,
    required this.lng,
    required this.baseCost,
    required this.pricePerKm,
  });

  TowCompany copyWith({
    String? name,
    String? area,
    double? lat,
    double? lng,
    double? baseCost,
    double? pricePerKm,
  }) {
    return TowCompany(
      id: id,
      name: name ?? this.name,
      area: area ?? this.area,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      baseCost: baseCost ?? this.baseCost,
      pricePerKm: pricePerKm ?? this.pricePerKm,
    );
  }
}

class TowDirectory extends ChangeNotifier {
  TowDirectory._internal() {
    _approved.addAll(const [
      TowCompany(id: 'c1', name: 'شركة الفضل للأوناش', area: 'المعادي',        lat: 29.9600, lng: 31.2610, baseCost: 300, pricePerKm: 50),
      TowCompany(id: 'c2', name: 'السفير للأوناش',     area: 'المهندسين',      lat: 30.0480, lng: 31.2030, baseCost: 270, pricePerKm: 44),
      TowCompany(id: 'c3', name: 'هليوبليس سيرفز لخدمات الاوناش', area: 'مصر الجديدة', lat: 30.0870, lng: 31.3440, baseCost: 400, pricePerKm: 38),
      TowCompany(id: 'c4', name: 'اريزونا لأعطال السيارات وسحب السيارات', area: 'التحرير', lat: 30.0444, lng: 31.2357, baseCost: 300, pricePerKm: 50),
      TowCompany(id: 'c5', name: 'النسر – لخدمات الأعطال', area: 'القاهرة الجديدة',  lat: 30.0074, lng: 31.4913, baseCost: 300, pricePerKm: 45),
      TowCompany(id: 'c6', name: 'الأمل لخدمات الأوناش', area: 'القاهرة الجديدة',    lat: 30.0230, lng: 31.4350, baseCost: 300, pricePerKm: 70),
      TowCompany(id: 'c7', name: 'الحرية للأعطال وسحب السيارات', area: '٦ أكتوبر',  lat: 29.9389, lng: 30.9138, baseCost: 250, pricePerKm: 55),
    ]);
  }
  static final TowDirectory _i = TowDirectory._internal();
  factory TowDirectory() => _i;

  final List<TowCompany> _approved = [];
  List<TowCompany> get all => List.unmodifiable(_approved);

  void addApproved(TowCompany c) {
    final idx = _approved.indexWhere((x) => x.id == c.id);
    if (idx == -1) {
      _approved.add(c);
    } else {
      _approved[idx] = c;
    }
    notifyListeners();
  }
}
