import 'package:flutter/material.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class CategoryTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final int itemCount;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    Widget logo() {
      if (imagePath.isEmpty) {
        return const Icon(Icons.image_outlined, size: 32);
      }
      return Image.asset(imagePath, fit: BoxFit.contain);
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(child: SizedBox(height: 48, child: logo())),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${loc.categoryTileItemCountPrefix} $itemCount',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
