import 'package:flutter/material.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class OrderSummary extends StatefulWidget {
  final double subtotal;
  final double shipping;
  final double grandTotal;
  final double discount;
  final int itemCount;

  final VoidCallback onProceedToOrder;
  final VoidCallback onCancel;

  final void Function(String code) onApplyCoupon;
  final ValueChanged<String>? onNoteChanged;

  final bool isSubmitting;

  const OrderSummary({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.grandTotal,
    required this.discount,
    required this.itemCount,
    required this.onProceedToOrder,
    required this.onCancel,
    required this.onApplyCoupon,
    this.onNoteChanged,
    this.isSubmitting = false,
  });

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  final _couponCtrl = TextEditingController();

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.orderSummaryTitle,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _row(
                label:
                    '${loc.orderSummarySubtotalPrefix} '
                    '(${widget.itemCount} ${loc.orderSummaryItemsSuffix})',
                value:
                    '${widget.subtotal.toStringAsFixed(2)} '
                    '${loc.currencyEgp}',
                isBold: false,
              ),
              const SizedBox(height: 4),

              _row(
                label: loc.orderSummaryShippingLabel,
                value:
                    '${widget.shipping.toStringAsFixed(2)} '
                    '${loc.currencyEgp}',
                isBold: false,
              ),
              const SizedBox(height: 4),

              if (widget.discount > 0)
                _row(
                  label: loc.orderSummaryDiscountLabel,
                  value:
                      '- ${widget.discount.toStringAsFixed(2)} '
                      '${loc.currencyEgp}',
                  isBold: false,
                ),

              const SizedBox(height: 8),
              Divider(color: cs.outlineVariant),
              const SizedBox(height: 8),

              _row(
                label: loc.orderSummaryGrandTotalLabel,
                value:
                    '${widget.grandTotal.toStringAsFixed(2)} '
                    '${loc.currencyEgp}',
                isBold: true,
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  loc.orderSummaryCouponSectionTitle,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponCtrl,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: loc.orderSummaryCouponFieldLabel,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (v) {
                        if (v.trim().isEmpty) return;
                        widget.onApplyCoupon(v.trim());
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final code = _couponCtrl.text.trim();
                      if (code.isEmpty) return;
                      widget.onApplyCoupon(code);
                    },
                    child: Text(loc.orderSummaryCouponApplyButton),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextField(
                maxLines: 2,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: loc.orderSummaryNoteFieldLabel,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => widget.onNoteChanged?.call(v.trim()),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.isSubmitting ? null : widget.onCancel,
                      child: Text(loc.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.isSubmitting
                          ? null
                          : widget.onProceedToOrder,
                      icon: widget.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        widget.isSubmitting
                            ? loc.orderSummarySubmittingLabel
                            : loc.orderSummarySubmitButton,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    final style = isBold
        ? const TextStyle(fontWeight: FontWeight.w700)
        : const TextStyle();

    return Row(
      children: [
        Expanded(
          child: Text(label, textAlign: TextAlign.right, style: style),
        ),
        const SizedBox(width: 8),
        Text(value, style: style),
      ],
    );
  }
}
