import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class OrderSummary extends StatelessWidget {
  final double subtotal;
  final int itemCount;
  final VoidCallback onProceedToOrder;
  final VoidCallback onCancel;

  const OrderSummary({
    required this.subtotal,
    required this.itemCount,
    required this.onProceedToOrder,
    required this.onCancel,
    super.key,
  });

  static const double _shippingCost = 15.00;
  double get _total => subtotal + _shippingCost;

  Widget _buildSummaryRow({
    required String title,
    required String value,
    bool isTotal = false,
  }) {
    final TextStyle style = isTotal
        ? const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primaryGreen,
          )
        : const TextStyle(fontSize: 16, color: AppColors.darkText);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الطلب ($itemCount عناصر)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            title: 'المجموع الفرعي',
            value: 'EGP ${subtotal.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            title: 'الشحن والتوصيل',
            value: 'EGP ${_shippingCost.toStringAsFixed(2)}',
          ),
          const Divider(height: 24, thickness: 1.5),
          _buildSummaryRow(
            title: 'المجموع الكلي',
            value: 'EGP ${_total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 24),
          // MARK:Order button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
                  itemCount >
                      0 //TODO: Ask for location
                  ? onProceedToOrder
                  : null,
              icon: const Icon(
                Icons.local_shipping,
                color: AppColors.lightText,
              ),
              label: Text(
                'طلب ونقل (${_total.toStringAsFixed(0)} EGP)',
                style: const TextStyle(
                  color: AppColors.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // MARK: Cancel button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'الغاء',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
