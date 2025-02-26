import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class RoomSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> rooms = [
    {'name': 'Kitchen', 'icon': Icons.kitchen},
    {'name': 'Living Room', 'icon': Icons.weekend},
    {'name': 'Bedroom', 'icon': Icons.bed},
    // Add more rooms as needed
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Select Room')),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        itemCount: rooms.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return GestureDetector(
            onTap: () {
              appState.setRoomType(room['name']);
              Navigator.pushNamed(context, '/style-selection');
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(room['icon'], size: 40),
                    SizedBox(height: 10),
                    Text(room['name']),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 