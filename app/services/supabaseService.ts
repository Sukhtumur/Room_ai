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
    await this.supabase.from('designs').insert({
      device_id: deviceId,
      room_type: roomType || 'Not specified',
      building_type: buildingType || 'Not specified',
      style: style || 'Not specified',
      image_url: imageUrl,
      feature_type: featureType || 'Interior Design',
      prompt,
      created_at: new Date().toISOString(),
    });
  }

  // Get user's designs
  async getUserDesigns(deviceId: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('designs')
      .select()
      .eq('device_id', deviceId)
      .order('created_at', { ascending: false });
    
    if (error) {
      console.error("Error fetching designs:", error);
      return [];
    }
    
    return data || [];
  }
}

export default SupabaseService; 