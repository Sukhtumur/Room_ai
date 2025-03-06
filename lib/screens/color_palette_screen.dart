import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class ColorPaletteScreen extends StatelessWidget {
  final List<Map<String, dynamic>> colorPalettes = const [
    {
      'name': 'Neutral',
      'colors': [Color(0xFFF5F5F5), Color(0xFFE0E0E0), Color(0xFFBDBDBD), Color(0xFF9E9E9E)],
    },
    {
      'name': 'Warm',
      'colors': [Color(0xFFFFF8E1), Color(0xFFFFE0B2), Color(0xFFFFB74D), Color(0xFFFF9800)],
    },
    {
      'name': 'Cool',
      'colors': [Color(0xFFE1F5FE), Color(0xFFB3E5FC), Color(0xFF4FC3F7), Color(0xFF03A9F4)],
    },
    {
      'name': 'Earthy',
      'colors': [Color(0xFFF1F8E9), Color(0xFFDCEDC8), Color(0xFFAED581), Color(0xFF8BC34A)],
    },
    {
      'name': 'Bold',
      'colors': [Color(0xFFE8EAF6), Color(0xFFC5CAE9), Color(0xFF7986CB), Color(0xFF3F51B5)],
    },
    {
      'name': 'Monochrome',
      'colors': [Color(0xFFEEEEEE), Color(0xFFBDBDBD), Color(0xFF757575), Color(0xFF212121)],
    },
  ];

  const ColorPaletteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final featureType = appState.featureType;
    final roomType = appState.roomType;
    final buildingType = appState.buildingType;
    final style = appState.style;
    
    String title = 'Select Color Palette';
    if (featureType == 'Interior Design' && roomType != null) {
      title = 'Color Palette for $roomType';
    } else if (featureType == 'Exterior Design' && buildingType != null) {
      title = 'Color Palette for $buildingType';
    }
    
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: colorPalettes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final palette = colorPalettes[index];
          return GestureDetector(
            onTap: () {
              appState.setColorPalette(palette['name']);
              Navigator.pushNamed(context, '/results');
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (Color color in palette['colors'])
                            Container(
                              height: 30,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      palette['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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