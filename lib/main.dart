import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/photo_upload_screen.dart';
import 'screens/room_selection_screen.dart';
import 'screens/style_selection_screen.dart';
import 'screens/results_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/prompt_input_screen.dart';
import 'state/app_state.dart';
import 'services/supabase_service.dart';
import 'utils/constants.dart';
import 'screens/building_type_screen.dart';
import 'screens/color_palette_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  runApp(
    provider_pkg.ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _registerDeviceIfNeeded();
  }

  Future<void> _registerDeviceIfNeeded() async {
    // Wait for AppState to initialize deviceId
    await Future.delayed(const Duration(milliseconds: 100));
    final appState = provider_pkg.Provider.of<AppState>(context, listen: false);
    
    // Register device in Supabase if needed
    await SupabaseService().registerDevice(appState.deviceId);
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        return MaterialApp(
          title: AppConstants.appTitle,
          theme: ThemeData(
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          // Use onGenerateRoute to handle routes
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/':
                page = PhotoUploadScreen();
                break;
              case '/room-selection':
                page = RoomSelectionScreen();
                break;
              case '/building-type':
                page = BuildingTypeScreen();
                break;
              case '/style-selection':
                page = StyleSelectionScreen();
                break;
              case '/color-palette':
                page = ColorPaletteScreen();
                break;
              case '/prompt-input':
                page = PromptInputScreen();
                break;
              case '/results':
                page = ResultsScreen();
                break;
              case '/profile':
                page = ProfileScreen();
                break;
              default:
                // Fallback for unknown routes
                page = Scaffold(
                  appBar: AppBar(title: const Text('Page Not Found')),
                  body: const Center(
                    child: Text('The requested page does not exist.'),
                  ),
                );
            }
            return MaterialPageRoute(builder: (_) => page);
          },
          home: PhotoUploadScreen(),
        );
      },
    );
  }
}
