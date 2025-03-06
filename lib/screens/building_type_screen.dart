import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class BuildingTypeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> buildingTypes = const [
    {'name': 'House', 'icon': Icons.home},
    {'name': 'Villa', 'icon': Icons.villa},
    {'name': 'Apartment', 'icon': Icons.apartment},
    {'name': 'Office', 'icon': Icons.business},
    {'name': 'Backyard', 'icon': Icons.deck},
    {'name': 'Patio', 'icon': Icons.balcony},
  ];

  const BuildingTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Select Building Type')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: buildingTypes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final buildingType = buildingTypes[index];
          return InkWell(
            onTap: () {
              appState.setBuildingType(buildingType['name']);
              Navigator.pushNamed(context, '/style-selection');
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(buildingType['icon'], size: 48, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    buildingType['name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 