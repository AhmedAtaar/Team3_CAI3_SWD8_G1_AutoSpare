import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomToggleSwitch extends StatelessWidget {
  final bool isArabicSelected;
  final ValueChanged<bool> onChanged;

  const CustomToggleSwitch({
    super.key,
    required this.isArabicSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const double switchWidth = 70.0;
    const double switchHeight = 35.0;
    const double borderRadius = 20.0;
    const double sliderWidth = (switchWidth / 2) - 2.0;

    final TextStyle selectedStyle = TextStyle(
      color: AppColors.primaryGreen,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    final TextStyle unselectedStyle = const TextStyle(
      color: AppColors.lightText,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return GestureDetector(
      onTap: () => onChanged(!isArabicSelected),
      child: Container(
        width: switchWidth,
        height: switchHeight,

        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.white54, width: 1.0),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              alignment: isArabicSelected
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: Container(
                width: sliderWidth,
                height: switchHeight - 4,
                decoration: BoxDecoration(
                  color: AppColors.lightText,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: sliderWidth,
                  child: Center(
                    child: Text(
                      'EN',
                      style: isArabicSelected ? unselectedStyle : selectedStyle,
                    ),
                  ),
                ),
                SizedBox(
                  width: sliderWidth,
                  child: Center(
                    child: Text(
                      'AR',
                      style: isArabicSelected ? selectedStyle : unselectedStyle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
