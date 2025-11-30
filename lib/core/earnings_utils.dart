import 'package:auto_spare/core/app_fees.dart';
import 'package:auto_spare/model/order.dart';

double computeAppFeeOnLine(double lineTotalWithFee) {
  final factor = 1 + kAppFeePercent;
  final base = lineTotalWithFee / factor;
  final appFee = base * kAppFeePercent;
  return appFee;
}

double computeOrderAppFee(OrderDoc o) {
  double total = 0;
  for (final it in o.items) {
    final lineTotal = it.price * it.qty;
    total += computeAppFeeOnLine(lineTotal);
  }
  return total;
}

double computeSellerNetForOrder(OrderDoc o, String sellerId) {
  if (o.items.isEmpty) return 0;

  double sellerLinesTotal = 0;
  double sellerBaseBeforeFee = 0;
  double allItemsTotal = 0;

  for (final it in o.items) {
    final lineTotal = it.price * it.qty;
    allItemsTotal += lineTotal;

    if (it.sellerId == sellerId) {
      sellerLinesTotal += lineTotal;
      final base = lineTotal / (1 + kAppFeePercent);
      sellerBaseBeforeFee += base;
    }
  }

  if (sellerLinesTotal <= 0 || allItemsTotal <= 0) {
    return sellerBaseBeforeFee;
  }

  final sellerShareOfDiscount = o.discount * (sellerLinesTotal / allItemsTotal);

  final sellerNet = sellerBaseBeforeFee - sellerShareOfDiscount;
  return sellerNet < 0 ? 0 : sellerNet;
}
