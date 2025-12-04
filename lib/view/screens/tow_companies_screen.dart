import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:auto_spare/services/tow_directory.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

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
    final dir = TowDirectory();
    final loc = AppLocalizations.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: dir,
        builder: (_, __) {
          final list = dir.onlineOnly;

          final sorted = [...list]
            ..sort((a, b) {
              final da = _distanceKm(
                fromLat: userLat,
                fromLng: userLng,
                toLat: a.lat,
                toLng: a.lng,
              );
              final db = _distanceKm(
                fromLat: userLat,
                fromLng: userLng,
                toLat: b.lat,
                toLng: b.lng,
              );
              return da.compareTo(db);
            });

          return Scaffold(
            appBar: AppBar(
              title: Text(loc.towCompaniesAppBarTitle),
              centerTitle: true,
            ),
            body: sorted.isEmpty
                ? Center(child: Text(loc.towCompaniesEmptyMessage))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final c = sorted[i];
                      final d = _distanceKm(
                        fromLat: userLat,
                        fromLng: userLng,
                        toLat: c.lat,
                        toLng: c.lng,
                      );
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.local_shipping_outlined),
                          title: Row(
                            children: [
                              Expanded(child: Text('${c.name} • ${c.area}')),
                              Chip(
                                avatar: Icon(
                                  c.isOnline
                                      ? Icons.circle
                                      : Icons.circle_outlined,
                                  size: 16,
                                  color: c.isOnline
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                label: Text(
                                  c.isOnline
                                      ? loc.towCompaniesStatusAvailable
                                      : loc.towCompaniesStatusUnavailable,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${loc.towCompaniesDistancePrefix} '
                            '${d.toStringAsFixed(1)} ${loc.towCompaniesKmSuffix}\n'
                            '${loc.towCompaniesBaseCostPrefix} '
                            '${c.baseCost.toStringAsFixed(0)} '
                            '${loc.currencyEgp} • '
                            '${loc.towCompaniesPricePerKmPrefix} '
                            '${c.pricePerKm.toStringAsFixed(0)} '
                            '${loc.currencyEgp}\n'
                            '${loc.towCompaniesCoordsPrefix} '
                            '(${c.lat.toStringAsFixed(5)}, '
                            '${c.lng.toStringAsFixed(5)})',
                          ),
                          trailing: const Icon(Icons.chevron_left),
                          onTap: () => Navigator.pop(context, c),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
