import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String storeName;
  final String title;
  final String description;
  final String category;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.storeName,
    required this.title,
    required this.description,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              storeName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Text(
              category,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      ),
    );
  }
}