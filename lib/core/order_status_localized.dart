import 'package:flutter/widgets.dart';
import 'package:auto_spare/l10n/app_localizations.dart';
import 'package:auto_spare/model/order.dart';

String orderStatusText(BuildContext context, OrderStatus s) {
  final loc = AppLocalizations.of(context);
  switch (s) {
    case OrderStatus.processing:
      return loc.orderStatusProcessing;
    case OrderStatus.prepared:
      return loc.orderStatusPrepared;
    case OrderStatus.handedToCourier:
      return loc.orderStatusHandedToCourier;
    case OrderStatus.delivered:
      return loc.orderStatusDelivered;
    case OrderStatus.cancelled:
      return loc.orderStatusCancelled;
  }
}
