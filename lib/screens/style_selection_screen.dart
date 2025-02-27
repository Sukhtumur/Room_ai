import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class StyleSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> styles = [
    {'name': 'Modern', 'image': 'assets/images/modern.jpg'},
    {'name': 'Minimalistic', 'image': 'assets/images/minimalistic.jpg'},
    {'name': 'Bohemian', 'image': 'assets/images/bohemian.jpg'},
    {'name': 'Industrial', 'image': 'assets/images/modern.jpg'}, // Reusing image as placeholder
    {'name': 'Scandinavian', 'image': 'assets/images/minimalistic.jpg'}, // Reusing image as placeholder
    {'name': 'Rustic', 'image': 'assets/images/bohemian.jpg'}, // Reusing image as placeholder
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final selectedRoom = appState.roomType ?? 'Room';
    
    return Scaffold(
      appBar: AppBar(title: Text('Select Style for $selectedRoom')),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        itemCount: styles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final style = styles[index];
          return GestureDetector(
            onTap: () {
              appState.setStyle(style['name']);
              
              // If we have an image, room type, and style, we can proceed to generate
              if (appState.image != null && appState.roomType != null && appState.style != null) {
                Navigator.pushNamed(context, '/results');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select an image, room type, and style')),
                );
              }
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    style['image'],
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        style['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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