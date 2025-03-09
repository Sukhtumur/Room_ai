import React, { useState, useEffect } from 'react';
import { StyleSheet, View, Text, Image, TouchableOpacity, ActivityIndicator, ScrollView, Alert, Linking } from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext } from '@/app/context/AppContext';
import { StatusBar } from 'expo-status-bar';
import * as FileSystem from 'expo-file-system';
import * as Sharing from 'expo-sharing';
import SupabaseService from '@/app/services/supabaseService';

// Mock data for product recommendations
const mockRecommendations = [
  {
    name: "Modern Accent Chair",
    description: "Comfortable upholstered chair with wooden legs",
    price: "$249.99",
    url: "https://amazon.com"
  },
  {
    name: "Minimalist Coffee Table",
    description: "Sleek design with storage compartment",
    price: "$179.99",
    url: "https://amazon.com"
  },
  {
    name: "LED Floor Lamp",
    description: "Adjustable brightness with modern design",
    price: "$89.99",
    url: "https://amazon.com"
  }
];

export default function ResultsScreen() {
  const { 
    image, 
    roomType, 
    buildingType, 
    style, 
    colorPalette, 
    prompt, 
    featureType, 
    deviceId,
    setGeneratedImageUrl
  } = useAppContext();
  
  const [isLoading, setIsLoading] = useState(true);
  const [generatedImage, setGeneratedImage] = useState<string | null>(null);
  const [recommendations, setRecommendations] = useState(mockRecommendations);

  // In a real app, this would call your AI service
  useEffect(() => {
    if (!image) {
      // If there's no image, go back to the home screen
      Alert.alert("Error", "No image selected. Please start over.");
      router.replace('/');
      return;
    }

    // Simulate API call delay
    const timer = setTimeout(() => {
      // For demo purposes, just use the original image
      setGeneratedImage(image);
      setGeneratedImageUrl(image); // Save to context
      setIsLoading(false);
    }, 3000);

    return () => clearTimeout(timer);
  }, [image]);

  const handleSave = async () => {
    if (!generatedImage) return;
    
    try {
      const supabaseService = SupabaseService.getInstance();
      await supabaseService.saveDesign({
        deviceId,
        roomType: roomType || undefined,
        buildingType: buildingType || undefined,
        style: style || undefined,
        imageUrl: generatedImage,
        featureType: featureType || undefined,
        prompt: prompt || undefined
      });
      
      Alert.alert('Success', 'Design saved successfully!');
    } catch (error) {
      console.error('Error saving design:', error);
      Alert.alert('Error', 'Failed to save design');
    }
  };

  const handleShare = async () => {
    if (!generatedImage) return;
    
    try {
      // Get the file extension
      const extension = generatedImage.split('.').pop() || 'jpg';
      const localUri = FileSystem.documentDirectory + `room-ai-design.${extension}`;
      
      // Download the image to local filesystem
      await FileSystem.downloadAsync(generatedImage, localUri);
      
      // Share the image
      if (await Sharing.isAvailableAsync()) {
        await Sharing.shareAsync(localUri);
      } else {
        Alert.alert('Sharing is not available on this device');
      }
    } catch (error) {
      console.error('Error sharing design:', error);
      Alert.alert('Error', 'Failed to share design');
    }
  };

  const handleNewDesign = () => {
    router.replace('/');
  };

  const openProductLink = (url: string) => {
    Linking.openURL(url).catch(err => {
      console.error('Error opening URL:', err);
      Alert.alert('Error', 'Could not open the product link');
    });
  };

  return (
    <View style={styles.container}>
      <StatusBar style="auto" />
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Ionicons name="arrow-back" size={24} color="#333" />
        </TouchableOpacity>
        <Text style={styles.title}>Your Design</Text>
        <TouchableOpacity onPress={handleNewDesign}>
          <Ionicons name="add-circle-outline" size={24} color="#333" />
        </TouchableOpacity>
      </View>

      <ScrollView style={styles.content}>
        <View style={styles.imageContainer}>
          {isLoading ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color="#4285F4" />
              <Text style={styles.loadingText}>Generating your design...</Text>
            </View>
          ) : (
            <Image 
              source={{ uri: generatedImage || '' }} 
              style={styles.resultImage}
              resizeMode="contain"
            />
          )}
        </View>

        {!isLoading && (
          <>
            <View style={styles.detailsContainer}>
              <Text style={styles.detailsTitle}>Design Details</Text>
              <View style={styles.detailsRow}>
                <Text style={styles.detailsLabel}>Type:</Text>
                <Text style={styles.detailsValue}>{featureType || 'Interior Design'}</Text>
              </View>
              {roomType && (
                <View style={styles.detailsRow}>
                  <Text style={styles.detailsLabel}>Room:</Text>
                  <Text style={styles.detailsValue}>{roomType}</Text>
                </View>
              )}
              {buildingType && (
                <View style={styles.detailsRow}>
                  <Text style={styles.detailsLabel}>Building:</Text>
                  <Text style={styles.detailsValue}>{buildingType}</Text>
                </View>
              )}
              {style && (
                <View style={styles.detailsRow}>
                  <Text style={styles.detailsLabel}>Style:</Text>
                  <Text style={styles.detailsValue}>{style}</Text>
                </View>
              )}
              {colorPalette && (
                <View style={styles.detailsRow}>
                  <Text style={styles.detailsLabel}>Colors:</Text>
                  <Text style={styles.detailsValue}>{colorPalette}</Text>
                </View>
              )}
              {prompt && (
                <View style={styles.detailsRow}>
                  <Text style={styles.detailsLabel}>Prompt:</Text>
                  <Text style={styles.detailsValue}>{prompt}</Text>
                </View>
              )}
            </View>

            <View style={styles.actionsContainer}>
              <TouchableOpacity style={styles.actionButton} onPress={handleSave}>
                <Ionicons name="bookmark-outline" size={24} color="#4285F4" />
                <Text style={styles.actionText}>Save</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.actionButton} onPress={handleShare}>
                <Ionicons name="share-outline" size={24} color="#4285F4" />
                <Text style={styles.actionText}>Share</Text>
              </TouchableOpacity>
              <TouchableOpacity 
                style={styles.actionButton} 
                onPress={() => router.push('/profile')}
              >
                <Ionicons name="folder-outline" size={24} color="#4285F4" />
                <Text style={styles.actionText}>My Designs</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.recommendationsContainer}>
              <Text style={styles.recommendationsTitle}>Recommended Products</Text>
              {recommendations.map((item, index) => (
                <View key={index} style={styles.recommendationCard}>
                  <View style={styles.recommendationContent}>
                    <Text style={styles.recommendationName}>{item.name}</Text>
                    <Text style={styles.recommendationDescription}>{item.description}</Text>
                    <Text style={styles.recommendationPrice}>{item.price}</Text>
                  </View>
                  <TouchableOpacity 
                    style={styles.buyButton}
                    onPress={() => openProductLink(item.url)}
                  >
                    <Text style={styles.buyButtonText}>View</Text>
                  </TouchableOpacity>
                </View>
              ))}
            </View>
          </>
        )}
      </ScrollView>
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
  content: {
    flex: 1,
  },
  imageContainer: {
    width: '100%',
    height: 300,
    backgroundColor: '#f5f5f5',
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingContainer: {
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666',
  },
  resultImage: {
    width: '100%',
    height: '100%',
  },
  detailsContainer: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  detailsTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  detailsRow: {
    flexDirection: 'row',
    marginBottom: 8,
  },
  detailsLabel: {
    width: 80,
    fontSize: 16,
    fontWeight: '600',
    color: '#666',
  },
  detailsValue: {
    flex: 1,
    fontSize: 16,
  },
  actionsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  actionButton: {
    alignItems: 'center',
  },
  actionText: {
    marginTop: 4,
    color: '#4285F4',
    fontWeight: '500',
  },
  recommendationsContainer: {
    padding: 16,
  },
  recommendationsTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  recommendationCard: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    backgroundColor: '#f9f9f9',
    borderRadius: 8,
    marginBottom: 12,
  },
  recommendationContent: {
    flex: 1,
  },
  recommendationName: {
    fontSize: 16,
    fontWeight: '600',
  },
  recommendationDescription: {
    fontSize: 14,
    color: '#666',
    marginVertical: 4,
  },
  recommendationPrice: {
    fontSize: 16,
    fontWeight: '600',
    color: '#4285F4',
  },
  buyButton: {
    backgroundColor: '#4285F4',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 4,
  },
  buyButtonText: {
    color: '#fff',
    fontWeight: '600',
  },
}); 