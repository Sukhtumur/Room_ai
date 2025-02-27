import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Create an anonymous user
  Future<void> createAnonymousUser(String userId) async {
    try {
      // Check if user already exists
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      if (response == null) {
        // User doesn't exist, create a new one
        await _supabaseClient.from('users').upsert({
          'id': userId,
          'created_at': DateTime.now().toIso8601String(),
          'is_anonymous': true,
        });
      }
    } catch (e) {
      // If the user doesn't exist, insert a new record
      if (e is PostgrestException) {
        await _supabaseClient.from('users').upsert({
          'id': userId,
          'created_at': DateTime.now().toIso8601String(),
          'is_anonymous': true,
        });
      } else {
        print("Error creating anonymous user: $e");
        rethrow;
      }
    }
  }

  // Save a design
  Future<void> saveDesign({
    required String userId,
    required String roomType,
    required String style,
    required String imageUrl,
  }) async {
    await _supabaseClient.from('designs').insert({
      'user_id': userId,
      'room_type': roomType,
      'style': style,
      'image_url': imageUrl,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Get user's designs
  Future<List<Map<String, dynamic>>> getUserDesigns(String userId) async {
    final response = await _supabaseClient
        .from('designs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
} 