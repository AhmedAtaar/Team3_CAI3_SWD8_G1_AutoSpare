import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class CategoryTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final int itemCount;
  final VoidCallback onTap;

  const CategoryTile({
    required this.imageUrl,
    required this.title,
    required this.itemCount,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryGreenShade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(20, 0, 0, 0),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(

                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen, width: 2),
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,

                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },

                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.directions_car,
                      color: AppColors.primaryGreen,
                      size: 28,
                    );
                  },
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$itemCountأغراض ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkText.withAlpha(200),
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
