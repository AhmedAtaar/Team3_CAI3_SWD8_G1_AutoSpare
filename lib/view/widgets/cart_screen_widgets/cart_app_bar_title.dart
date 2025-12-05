import 'package:flutter/material.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class CartAppTitle extends StatelessWidget {
  final int itemCount;

  const CartAppTitle({required this.itemCount, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        '${loc.cartAppTitlePrefix} '
        '($itemCount ${loc.cartAppTitleItemsSuffix})',
        textAlign: TextAlign.right,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
