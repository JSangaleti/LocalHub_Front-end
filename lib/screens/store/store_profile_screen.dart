import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../widgets/store_card.dart';

class StoreProfileScreen extends StatelessWidget {
  const StoreProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil da Loja')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StoreCard(
              name: mockStore['name']!,
              category: mockStore['category']!,
              address: mockStore['address']!,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                mockStore['description']!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Horário: ${mockStore['openingHours']}'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Contato: ${mockStore['contact']}'),
            ),
          ],
        ),
      ),
    );
  }
}