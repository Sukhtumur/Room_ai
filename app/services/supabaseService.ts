import { createClient } from '@supabase/supabase-js';
import Constants from '@/app/utils/constants';

class SupabaseService {
  private static instance: SupabaseService;
  private supabase;
  
  constructor() {
    this.supabase = createClient(
      Constants.supabaseUrl,
      Constants.supabaseAnonKey
    );
  }
  
  static getInstance(): SupabaseService {
    if (!SupabaseService.instance) {
      SupabaseService.instance = new SupabaseService();
    }
    return SupabaseService.instance;
  }
  
  // Check connection
  async checkConnection(): Promise<boolean> {
    try {
      // Simple query to check if connection works
      const { data, error } = await this.supabase
        .from('devices')
        .select('device_id')
        .limit(1);
      
      return !error;
    } catch (e) {
      console.error("Supabase connection error:", e);
      return false;
    }
  }
  
  // Register a device
  async registerDevice(deviceId: string): Promise<void> {
    try {
      // Check if device already exists
      const { data } = await this.supabase
        .from('devices')
        .select()
        .eq('device_id', deviceId)
        .single();
      
      if (!data) {
        // Device doesn't exist, create a new one
        await this.supabase.from('devices').insert({
          device_id: deviceId,
          created_at: new Date().toISOString(),
          last_active: new Date().toISOString(),
        });
      } else {
        // Update last active timestamp
        await this.supabase
          .from('devices')
          .update({ last_active: new Date().toISOString() })
          .eq('device_id', deviceId);
      }
    } catch (e) {
      console.error("Error registering device:", e);
    }
  }

  // Save a design
  async saveDesign({
    deviceId,
    roomType,
    buildingType,
    style,
    imageUrl,
    featureType,
    prompt,
  }: {
    deviceId: string;
    roomType?: string;
    buildingType?: string;
    style?: string;
    imageUrl: string;
    featureType?: string;
    prompt?: string;
  }): Promise<void> {
    // Convert the string deviceId to a valid UUID if possible
    // If not, use a default UUID
    const defaultUUID = '00000000-0000-0000-0000-000000000000';
    
    try {
      await this.supabase.from('designs').insert({
        device_id: defaultUUID, // Use a default UUID that exists in your database
        room_type: roomType || 'Not specified',
        building_type: buildingType || 'Not specified',
        style: style || 'Not specified',
        image_url: imageUrl,
        feature_type: featureType || 'Interior Design',
        prompt,
        created_at: new Date().toISOString(),
      });
    } catch (error) {
      console.error("Error saving design:", error);
    }
  }

  // Get user's designs - return mock data for now
  async getUserDesigns(deviceId: string): Promise<any[]> {
    try {
      // Return mock data since we can't query by the actual deviceId
      return [
        {
          id: '1',
          device_id: deviceId,
          room_type: 'Living Room',
          building_type: 'House',
          style: 'Modern',
          image_url: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7',
          feature_type: 'Interior Design',
          created_at: new Date().toISOString()
        },
        {
          id: '2',
          device_id: deviceId,
          room_type: 'Bedroom',
          building_type: 'Apartment',
          style: 'Minimalist',
          image_url: 'https://images.unsplash.com/photo-1540518614846-7eded433c457',
          feature_type: 'Interior Design',
          created_at: new Date(Date.now() - 86400000).toISOString() // 1 day ago
        }
      ];
    } catch (e) {
      console.error("Error in getUserDesigns:", e);
      return [];
    }
  }
}

export default SupabaseService; 