import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class RoomSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> roomTypes = const [
    {'name': 'Living Room', 'icon': Icons.weekend},
    {'name': 'Bedroom', 'icon': Icons.bed},
    {'name': 'Kitchen', 'icon': Icons.kitchen},
    {'name': 'Bathroom', 'icon': Icons.bathtub},
    {'name': 'Office', 'icon': Icons.computer},
    {'name': 'Dining Room', 'icon': Icons.dining},
  ];

  const RoomSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Select Room Type')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: roomTypes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final roomType = roomTypes[index];
          return InkWell(
            onTap: () {
              appState.setRoomType(roomType['name']);
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
                  Icon(roomType['icon'], size: 48, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    roomType['name'],
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