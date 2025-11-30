const double kAppFeePercent = 0.05;

double applyAppFee(double basePrice) {
  return basePrice * (1 + kAppFeePercent);
}
