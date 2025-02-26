import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/photo_upload_screen.dart';
import 'screens/room_selection_screen.dart';
import 'screens/style_selection_screen.dart';
import 'screens/results_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: HomeAIApp(),
    ),
  );
}

class HomeAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => PhotoUploadScreen(),
        '/room-selection': (context) => RoomSelectionScreen(),
        '/style-selection': (context) => StyleSelectionScreen(),
        '/results': (context) => ResultsScreen(),
      },
    );
  }
}
