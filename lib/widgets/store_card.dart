import 'package:flutter/material.dart';

class StoreCard extends StatelessWidget {
  final String name;
  final String category;
  final String address;
  final VoidCallback? onTap;

  const StoreCard({
    super.key,
    required this.name,
    required this.category,
    required this.address,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text('$category • $address'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}