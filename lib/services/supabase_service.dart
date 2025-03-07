import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/design_model.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;
  
  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      debug: true, // Set to false in production
    );
    print("Supabase initialized successfully");
  }
  
  // Check connection
  static Future<bool> checkConnection() async {
    try {
      // Simple query to check if connection works
      final response = await supabase.from('users').select('id').limit(1).execute();
      print("Supabase connection test: ${response.status}");
      return response.status == 200;
    } catch (e) {
      print("Supabase connection error: $e");
      return false;
    }
  }
  
  // Register a device
  Future<void> registerDevice(String deviceId) async {
    try {
      // Check if device already exists
      final response = await supabase
          .from('devices')
          .select()
          .eq('device_id', deviceId)
          .maybeSingle();
      
      if (response == null) {
        // Device doesn't exist, create a new one
        await supabase.from('devices').insert({
          'device_id': deviceId,
          'created_at': DateTime.now().toIso8601String(),
          'last_active': DateTime.now().toIso8601String(),
        });
      } else {
        // Update last active timestamp
        await supabase
            .from('devices')
            .update({'last_active': DateTime.now().toIso8601String()})
            .eq('device_id', deviceId);
      }
    } catch (e) {
      print("Error registering device: $e");
    }
  }

  // Save a design
  Future<void> saveDesign({
    required String deviceId,
    required String? roomType,
    required String? style,
    required String imageUrl,
    required String? featureType,
    required String? prompt,
  }) async {
    await supabase.from('designs').insert({
      'device_id': deviceId,
      'room_type': roomType ?? 'Not specified',
      'style': style ?? 'Not specified',
      'image_url': imageUrl,
      'feature_type': featureType ?? 'Interior Design',
      'prompt': prompt,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Get user's designs
  Future<List<Map<String, dynamic>>> getUserDesigns(String deviceId) async {
    final response = await supabase
        .from('designs')
        .select()
        .eq('device_id', deviceId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
} 