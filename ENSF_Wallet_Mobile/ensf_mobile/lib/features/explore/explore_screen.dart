import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Food & Dining',
      'icon': Icons.restaurant,
      'color': ThemeConstants.primaryColor,
    },
    {
      'title': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': ThemeConstants.accentColor,
    },
    {
      'title': 'Entertainment',
      'icon': Icons.movie,
      'color': ThemeConstants.secondaryColor,
    },
    {
      'title': 'Transport',
      'icon': Icons.directions_car,
      'color': ThemeConstants.successColor,
    },
    {
      'title': 'Bills',
      'icon': Icons.receipt,
      'color': ThemeConstants.warningColor,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore', style: ThemeConstants.subheadingStyle.copyWith(color: Colors.white)),
        backgroundColor: ThemeConstants.primaryColor,
        elevation: ThemeConstants.defaultElevation,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Popular Categories',
                style: ThemeConstants.headingStyle,
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    elevation: ThemeConstants.defaultElevation,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                    ),
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement category selection
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'],
                            size: 48,
                            color: category['color'],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['title'],
                            textAlign: TextAlign.center,
                            style: ThemeConstants.cardTitleStyle,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Offers',
                style: ThemeConstants.headingStyle,
              ),
              const SizedBox(height: 16),
              // TODO: Implement recent offers list
              const Center(
                child: Text('Recent offers will be shown here'),
              ),
            ],
          ),
        ),
      ),
      // TODO: Add bottom navigation bar once the widget is created
    );
  }
}
