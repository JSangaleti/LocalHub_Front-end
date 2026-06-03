import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_decorations.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool showClear;
  final bool autofocus;
  final Widget? trailing;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.showClear = false,
    this.autofocus = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.searchBar,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
            size: 22,
          ),
          suffixIcon: showClear
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.textTertiary,
                  onPressed: onClear,
                )
              : trailing,
        ),
      ),
    );
  }
}
