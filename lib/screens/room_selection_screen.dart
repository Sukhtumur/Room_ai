import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class RoomSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> rooms = [
    {'name': 'Kitchen', 'icon': Icons.kitchen},
    {'name': 'Living Room', 'icon': Icons.weekend},
    {'name': 'Bedroom', 'icon': Icons.bed},
    {'name': 'Bathroom', 'icon': Icons.bathtub},
    {'name': 'Office', 'icon': Icons.computer},
    {'name': 'Dining Room', 'icon': Icons.dinner_dining},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Select Room')),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        itemCount: rooms.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return InkWell(
            onTap: () {
              appState.setRoomType(room['name']);
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
                  Icon(room['icon'], size: 48, color: Theme.of(context).primaryColor),
                  SizedBox(height: 12),
                  Text(
                    room['name'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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