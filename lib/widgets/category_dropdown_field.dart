import 'package:flutter/material.dart';

import '../models/category_model.dart';

class CategoryDropdownField extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? value;
  final ValueChanged<int?> onChanged;
  final String? Function(int?)? validator;

  const CategoryDropdownField({
    super.key,
    required this.categories,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: const InputDecoration(labelText: 'Categoria'),
      items: categories
          .map(
            (c) => DropdownMenuItem(
              value: c.id,
              child: Text(c.name),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator != null
          ? (v) => validator!(v)
          : (v) => v == null ? 'Selecione uma categoria' : null,
    );
  }
}
