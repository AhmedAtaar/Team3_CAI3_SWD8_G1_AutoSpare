import 'package:auto_spare/controller/navigation/navigation.dart';
import 'package:auto_spare/view/themes/app_colors.dart';
import 'package:auto_spare/view/widgets/categories_screen_widgets/category_tile_widget.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static final List<Map<String, dynamic>> _categories = [
    {
      'title': 'BMW',
      'count': 245,
      'imageUrl':
          'https://www.citypng.com/public/uploads/preview/bmw-white-logo-hd-png-701751694708574rsodsw0tk5.png',
    },
    {
      'title': 'Mercedes',
      'count': 189,
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Mercedes-Logo.svg/1024px-Mercedes-Logo.svg.png',
    },
    {
      'title': 'Nissan',
      'count': 89,
      'imageUrl':
          'https://wallpapers.com/images/featured/nissan-logo-png-a7lsvs9uwvtc6piq.jpg',
    },
    {
      'title': 'Renault',
      'count': 78,
      'imageUrl':
          'https://www.citypng.com/public/uploads/preview/hd-renault-emblem-logo-png-701751694707695cclpdd6qho.png?v=2025082815',
    },
    {
      'title': 'BYD',
      'count': 156,
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/BYD_Auto_Logo.svg/2560px-BYD_Auto_Logo.svg.png',
    },
    {
      'title': 'Peugeot',
      'count': 110,
      'imageUrl': 'https://logowik.com/content/uploads/images/196_peugeot1.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppNavigationScaffold(
        title: "التصنيفات",

        currentIndex: 1,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //MARK: Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن قطع، علامات تجارية، موديلات...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primaryGreen,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'التصنيفات',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'تصفح القطع حسب الماركة',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),

              //MARK: GridView Builder
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.2,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];

                  return CategoryTile(
                    imageUrl: (category['imageUrl'] as String?) ?? '',
                    title: (category['title'] as String?) ?? 'Unknown Brand',
                    itemCount: (category['count'] as int?) ?? 0,
                    onTap: () {},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
