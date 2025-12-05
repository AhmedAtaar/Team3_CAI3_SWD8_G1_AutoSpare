import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:auto_spare/l10n/app_localizations.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? leadingIcon;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: const TextStyle(fontSize: 16, color: AppColors.darkText),
            ),
          ],
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Colors.grey, thickness: 1, endIndent: 10),
        ),
        Text(
          loc.authOrDividerLabel,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const Expanded(
          child: Divider(color: Colors.grey, thickness: 1, indent: 10),
        ),
      ],
    );
  }
}
