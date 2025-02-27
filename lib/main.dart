import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/photo_upload_screen.dart';
import 'screens/room_selection_screen.dart';
import 'screens/style_selection_screen.dart';
import 'screens/results_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'state/app_state.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'utils/constants.dart';

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
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the user when the app starts.
    _initFuture = _initUser();
  }
  Future<void> _initUser() async {
    final appState = provider_pkg.Provider.of<AppState>(context, listen: false);
    try {
      // Check if user is already authenticated
      if (AuthService.instance.isSignedIn) {
        // User is already signed in, use their Supabase ID
        appState.setUserId(AuthService.instance.currentUser!.id);
        appState.setAnonymous(false);
      } else {
        // Use anonymous ID
        await SupabaseService().createAnonymousUser(appState.userId);
        appState.setAnonymous(true);
      }
    } catch (e) {
      print("Failed to initialize user: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
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
              case '/login':
                page = LoginScreen();
                break;
              case '/room-selection':
                page = RoomSelectionScreen();
                break;
              case '/style-selection':
                page = StyleSelectionScreen();
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
                  appBar: AppBar(title: Text('Page Not Found')),
                  body: Center(
                    child: Text('The requested page does not exist.'),
                  ),
                );
            }
            return MaterialPageRoute(builder: (_) => page);
          },
          home: AuthService.instance.isSignedIn ? PhotoUploadScreen() : LoginScreen(),
        );
      },
    );
  }
}
