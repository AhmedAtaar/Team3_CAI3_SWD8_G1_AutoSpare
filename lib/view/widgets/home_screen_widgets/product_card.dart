import 'package:auto_spare/model/product.dart';
import 'package:flutter/material.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class ProductCard extends StatelessWidget {
  final Product item;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;
    final loc = AppLocalizations.of(context);

    final parsedPrice = double.tryParse(item.price);
    final priceText = parsedPrice != null
        ? parsedPrice.toStringAsFixed(2)
        : item.price;

    Widget image() {
      if (item.imageUrl == null || item.imageUrl!.isEmpty) {
        return const Center(child: Icon(Icons.image_outlined, size: 40));
      }
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: Image.network(
          item.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
        ),
      );
    }

    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: .35),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      child: image(),
                    ),
                    if (item.badge != null)
                      PositionedDirectional(
                        top: 8,
                        start: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$priceText ${loc.currencyEgp}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      onPressed: () {},
                      tooltip: loc.productCardAddToCartTooltip,
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
