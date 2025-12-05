import 'package:flutter/widgets.dart';
import 'package:auto_spare/model/tow_request.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

String towStatusText(BuildContext context, TowRequestStatus status) {
  final loc = AppLocalizations.of(context);

  switch (status) {
    case TowRequestStatus.pending:
      return loc.towStatusPending;
    case TowRequestStatus.accepted:
      return loc.towStatusAccepted;
    case TowRequestStatus.onTheWay:
      return loc.towStatusOnTheWay;
    case TowRequestStatus.completed:
      return loc.towStatusCompleted;
    case TowRequestStatus.cancelled:
      return loc.towStatusCancelled;
    case TowRequestStatus.rejected:
      return loc.towStatusRejected;
  }
}
