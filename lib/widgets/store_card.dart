import 'package:flutter/material.dart';

class StoreCard extends StatelessWidget {
  final String name;
  final String category;

  const StoreCard({
    super.key,
    required this.name,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(category),
      ),
    );
  }
}
