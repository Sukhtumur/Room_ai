import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client;

  // Singleton pattern to initialize the Supabase client once.
  SupabaseService._internal(this.client);
  static final SupabaseService _instance = SupabaseService._internal(
    SupabaseClient(
      'https://nvykwvnsvrugujwchftz.supabase.co', 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im52eWt3dm5zdnJ1Z3Vqd2NoZnR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA1NDA2MjgsImV4cCI6MjA1NjExNjYyOH0.BFfCfTOSgNz4pBRtxCuee-8fKbzO640fotnEF_x49AU'
    ),
  );
  factory SupabaseService() => _instance;

  // Example method to save a design record.
  Future<void> saveDesign({
    required String userId,
    required String originalImageUrl,
    required String generatedImageUrl,
    required String roomType,
    required String style,
  }) async {
    final response = await client.from('designs').insert({
      'user_id': userId,
      'original_image_url': originalImageUrl,
      'generated_image_url': generatedImageUrl,
      'room_type': roomType,
      'style': style,
    }).execute();

    if (response.error != null) {
      throw Exception('Error saving design: ${response.error!.message}');
    }
  }
} 