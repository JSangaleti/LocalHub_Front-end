import 'package:flutter/material.dart';

class CategoryFilterBar extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: categories.map((category) {
          final bool isSelected = category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) {
                onCategorySelected(category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}