import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Register a device
  Future<void> registerDevice(String deviceId) async {
    try {
      // Check if device already exists
      final response = await _supabaseClient
          .from('devices')
          .select()
          .eq('device_id', deviceId)
          .maybeSingle();
      
      if (response == null) {
        // Device doesn't exist, create a new one
        await _supabaseClient.from('devices').insert({
          'device_id': deviceId,
          'created_at': DateTime.now().toIso8601String(),
          'last_active': DateTime.now().toIso8601String(),
        });
      } else {
        // Update last active timestamp
        await _supabaseClient
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
    await _supabaseClient.from('designs').insert({
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
    final response = await _supabaseClient
        .from('designs')
        .select()
        .eq('device_id', deviceId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
} 