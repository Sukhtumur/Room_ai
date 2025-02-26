import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class StyleSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> styles = [
    {'name': 'Modern', 'image': 'assets/images/modern.jpg'},
    {'name': 'Minimalistic', 'image': 'assets/images/minimalistic.jpg'},
    {'name': 'Bohemian', 'image': 'assets/images/bohemian.jpg'},
    // Add more styles as needed
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Select Style')),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        itemCount: styles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final style = styles[index];
          return GestureDetector(
            onTap: () {
              appState.setStyle(style['name']);
              Navigator.pushNamed(context, '/results');
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(style['image']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.black54,
                  padding: EdgeInsets.all(4),
                  child: Text(
                    style['name'],
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 