import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// موديل الشركة (زودنا السعر الأساسي وسعر الكيلو)
class TowCompany {
  final String name;
  final String area;
  final double lat;
  final double lng;
  final double baseCost;   // تكلفة زيارة/فتح
  final double pricePerKm; // سعر الكيلو
  const TowCompany({
    required this.name,
    required this.area,
    required this.lat,
    required this.lng,
    required this.baseCost,
    required this.pricePerKm,
  });
}

/// بيانات حوالين القاهرة + الأسعار
const List<TowCompany> kTowCompanies = [
  TowCompany(name: 'شركة الفضل للأوناش', area: 'المعادي',        lat: 29.9600, lng: 31.2610, baseCost: 300, pricePerKm: 50),
  TowCompany(name: 'السفير للأوناش',     area: 'المهندسين',      lat: 30.0480, lng: 31.2030, baseCost: 270, pricePerKm: 44),
  TowCompany(name: 'هليوبليس سيرفز لخدمات الاوناش', area: 'مصر الجديدة', lat: 30.0870, lng: 31.3440, baseCost: 400, pricePerKm: 38),
  TowCompany(name: 'اريزونا لأعطال السيارات وسحب السيارات', area: 'التحرير', lat: 30.0444, lng: 31.2357, baseCost: 300, pricePerKm: 50),
  TowCompany(name: 'النسر – لخدمات الأعطال', area: 'القاهرة الجديدة',  lat: 30.0074, lng: 31.4913, baseCost: 300, pricePerKm: 45),
  TowCompany(name: 'الأمل لخدمات الأوناش', area: 'القاهرة الجديدة',    lat: 30.0230, lng: 31.4350, baseCost: 300, pricePerKm: 70),
  TowCompany(name: 'الحرية للأعطال وسحب السيارات', area: '٦ أكتوبر',  lat: 29.9389, lng: 30.9138, baseCost: 250, pricePerKm: 55),
];

double _distanceKm({
  required double fromLat,
  required double fromLng,
  required double toLat,
  required double toLng,
}) {
  final meters = Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
  return meters / 1000.0;
}

class TowCompaniesScreen extends StatelessWidget {
  final double userLat;
  final double userLng;
  const TowCompaniesScreen({
    super.key,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sorted = [...kTowCompanies]..sort((a, b) {
      final da = _distanceKm(fromLat: userLat, fromLng: userLng, toLat: a.lat, toLng: a.lng);
      final db = _distanceKm(fromLat: userLat, fromLng: userLng, toLat: b.lat, toLng: b.lng);
      return da.compareTo(db);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('شركات السحب القريبة'), centerTitle: true),
        body: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: sorted.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final c = sorted[i];
            final d = _distanceKm(fromLat: userLat, fromLng: userLng, toLat: c.lat, toLng: c.lng);
            return Card(
              child: ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(
                  '${c.name} • ${c.area}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'المسافة التقريبية: ${d.toStringAsFixed(1)} كم\n'
                      'سعر الخدمة: ${c.baseCost.toStringAsFixed(0)} جنيه • سعر الكيلو: ${c.pricePerKm.toStringAsFixed(0)} جنيه\n'
                      '(${c.lat.toStringAsFixed(5)}, ${c.lng.toStringAsFixed(5)})',
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.pop(context, c), // رجّع الشركة المختارة
              ),
            );
          },
        ),
      ),
    );
  }
}
