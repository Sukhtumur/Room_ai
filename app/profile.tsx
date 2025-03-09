import React, { useEffect, useState } from 'react';
import { StyleSheet, View, Text, TouchableOpacity, FlatList, Image, Alert, ActivityIndicator } from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext } from '@/app/context/AppContext';
import { StatusBar } from 'expo-status-bar';
import SupabaseService from '@/app/services/supabaseService';

export default function ProfileScreen() {
  const { deviceId } = useAppContext();
  const [savedDesigns, setSavedDesigns] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadSavedDesigns();
  }, []);

  const loadSavedDesigns = async () => {
    try {
      setIsLoading(true);
      const supabaseService = SupabaseService.getInstance();
      const designs = await supabaseService.getUserDesigns(deviceId);
      setSavedDesigns(designs);
    } catch (error) {
      console.error('Error loading saved designs:', error);
      Alert.alert('Error', 'Failed to load your saved designs');
    } finally {
      setIsLoading(false);
    }
  };

  const handleDeleteDesign = (designId: string) => {
    Alert.alert(
      'Delete Design',
      'Are you sure you want to delete this design?',
      [
        {
          text: 'Cancel',
          style: 'cancel',
        },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              const supabaseService = SupabaseService.getInstance();
              // In a real app, you would delete from Supabase here
              // await supabaseService.deleteDesign(designId);
              
              // For demo, just remove from local state
              setSavedDesigns(savedDesigns.filter(design => design.id !== designId));
              Alert.alert('Success', 'Design deleted successfully');
            } catch (error) {
              console.error('Error deleting design:', error);
              Alert.alert('Error', 'Failed to delete design');
            }
          },
        },
      ]
    );
  };

  return (
    <View style={styles.container}>
      <StatusBar style="auto" />
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Ionicons name="arrow-back" size={24} color="#333" />
        </TouchableOpacity>
        <Text style={styles.title}>Your Designs</Text>
        <TouchableOpacity onPress={() => router.replace('/')}>
          <Ionicons name="add-circle-outline" size={24} color="#333" />
        </TouchableOpacity>
      </View>

      {isLoading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#4285F4" />
          <Text style={styles.loadingText}>Loading your designs...</Text>
        </View>
      ) : savedDesigns.length === 0 ? (
        <View style={styles.emptyContainer}>
          <Ionicons name="images-outline" size={64} color="#ccc" />
          <Text style={styles.emptyText}>You haven't saved any designs yet</Text>
          <TouchableOpacity 
            style={styles.createButton}
            onPress={() => router.replace('/')}
          >
            <Text style={styles.createButtonText}>Create Your First Design</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <FlatList
          data={savedDesigns}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          renderItem={({ item }) => (
            <View style={styles.designCard}>
              <Image 
                source={{ uri: item.image_url }} 
                style={styles.designImage}
              />
              <View style={styles.designInfo}>
                <Text style={styles.designType}>
                  {item.feature_type || 'Interior Design'}
                </Text>
                <Text style={styles.designDetails}>
                  {item.room_type || item.building_type || 'Room'} • {item.style || 'Style'}
                </Text>
                <Text style={styles.designDate}>
                  {new Date(item.created_at).toLocaleDateString()}
                </Text>
              </View>
              <TouchableOpacity 
                style={styles.deleteButton}
                onPress={() => handleDeleteDesign(item.id)}
              >
                <Ionicons name="trash-outline" size={20} color="#ff4d4d" />
              </TouchableOpacity>
            </View>
          )}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 60,
    paddingBottom: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 32,
  },
  emptyText: {
    fontSize: 16,
    color: '#666',
    marginTop: 16,
    marginBottom: 24,
    textAlign: 'center',
  },
  createButton: {
    backgroundColor: '#4285F4',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  createButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  list: {
    padding: 16,
  },
  designCard: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    borderRadius: 12,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
    overflow: 'hidden',
  },
  designImage: {
    width: 100,
    height: 100,
  },
  designInfo: {
    flex: 1,
    padding: 12,
    justifyContent: 'center',
  },
  designType: {
    fontSize: 16,
    fontWeight: '600',
  },
  designDetails: {
    fontSize: 14,
    color: '#666',
    marginVertical: 4,
  },
  designDate: {
    fontSize: 12,
    color: '#999',
  },
  deleteButton: {
    padding: 16,
    justifyContent: 'center',
  },
}); 