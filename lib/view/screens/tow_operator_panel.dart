// lib/view/screens/tow_operator_panel.dart
import 'package:flutter/material.dart';
import 'package:auto_spare/services/tow_directory.dart';

class TowOperatorPanel extends StatelessWidget {
  final String companyId;
  const TowOperatorPanel({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    final dir = TowDirectory();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: dir,
        builder: (_, __) {
          final c = dir.all.firstWhere(
                (x) => x.id == companyId,
            orElse: () => throw Exception('Company not found: $companyId'),
          );

          return Scaffold(
            appBar: AppBar(
              title: Text('لوحة ${c.name}'),
              actions: [
                IconButton(
                  tooltip: 'تبديل الحالة',
                  onPressed: () => dir.toggleOnline(c.id),
                  icon: const Icon(Icons.power_settings_new),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_shipping_outlined),
                      title: Text('${c.name} • ${c.area}'),
                      subtitle: Text('(${c.lat.toStringAsFixed(5)}, ${c.lng.toStringAsFixed(5)})'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('متاح الآن (Online)'),
                    subtitle: const Text('يمكن للعملاء رؤية شركتك والحجز'),
                    value: c.isOnline,
                    onChanged: (v) => dir.setOnline(c.id, v),
                  ),
                  const SizedBox(height: 8),
                  if (!c.isOnline)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: const Text(
                        'أنت خارج الخدمة حاليًا. فعّل الحالة لتظهر لعملائك القريبين.',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => dir.toggleOnline(c.id),
                    icon: const Icon(Icons.toggle_on),
                    label: Text(c.isOnline ? 'تحويل إلى غير متاح' : 'تحويل إلى متاح'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
