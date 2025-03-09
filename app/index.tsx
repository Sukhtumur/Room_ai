import React from 'react';
import { StyleSheet, View, Text, TouchableOpacity, Alert } from 'react-native';
import { router } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as ImagePicker from 'expo-image-picker';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext } from '@/app/context/AppContext';

export default function PhotoUploadScreen() {
  const { setImage, setFeatureType } = useAppContext();

  const pickImage = async (featureType: string) => {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [4, 3],
      quality: 1,
    });

    if (!result.canceled) {
      setImage(result.assets[0].uri);
      setFeatureType(featureType);
      
      // Different navigation flows based on feature type
      switch (featureType) {
        case 'Interior Design':
          router.push('/room-selection');
          break;
        case 'Exterior Design':
          router.push('/building-type');
          break;
        case 'Object Editing':
        case 'Paint & Color':
          router.push('/prompt-input');
          break;
      }
    }
  };

  const takePhoto = async (featureType: string) => {
    const { status } = await ImagePicker.requestCameraPermissionsAsync();
    
    if (status !== 'granted') {
      Alert.alert('Permission needed', 'Camera permission is required to take photos');
      return;
    }
    
    const result = await ImagePicker.launchCameraAsync({
      allowsEditing: true,
      aspect: [4, 3],
      quality: 1,
    });

    if (!result.canceled) {
      setImage(result.assets[0].uri);
      setFeatureType(featureType);
      
      // Different navigation flows based on feature type
      switch (featureType) {
        case 'Interior Design':
          router.push('/room-selection');
          break;
        case 'Exterior Design':
          router.push('/building-type');
          break;
        case 'Object Editing':
        case 'Paint & Color':
          router.push('/prompt-input');
          break;
      }
    }
  };

  const showImageSourceDialog = (featureType: string) => {
    Alert.alert(
      `Choose Image Source for ${featureType}`,
      'Select where you want to get the image from',
      [
        {
          text: 'Camera',
          onPress: () => takePhoto(featureType),
        },
        {
          text: 'Gallery',
          onPress: () => pickImage(featureType),
        },
        {
          text: 'Cancel',
          style: 'cancel',
        },
      ]
    );
  };

  return (
    <View style={styles.container}>
      <StatusBar style="auto" />
      <View style={styles.header}>
        <Text style={styles.title}>Room AI</Text>
        <TouchableOpacity onPress={() => router.push('/profile')}>
          <Ionicons name="person-circle-outline" size={32} color="#333" />
        </TouchableOpacity>
      </View>
      
      <View style={styles.content}>
        <Text style={styles.heading}>Transform your space with AI</Text>
        <Text style={styles.subheading}>Select a feature to get started</Text>
        
        <FeatureCard
          title="Interior Design"
          description="Redesign your indoor spaces with various styles"
          icon="home"
          color="#4285F4"
          onPress={() => showImageSourceDialog('Interior Design')}
        />
        
        <FeatureCard
          title="Exterior Design"
          description="Transform the outside of your home"
          icon="business"
          color="#34A853"
          onPress={() => showImageSourceDialog('Exterior Design')}
        />
        
        <FeatureCard
          title="Object Editing"
          description="Remove or add furniture to your space"
          icon="create"
          color="#FBBC05"
          onPress={() => showImageSourceDialog('Object Editing')}
        />
        
        <FeatureCard
          title="Paint & Color"
          description="Change colors of walls, furniture and more"
          icon="color-palette"
          color="#EA4335"
          onPress={() => showImageSourceDialog('Paint & Color')}
        />
      </View>
    </View>
  );
}

interface FeatureCardProps {
  title: string;
  description: string;
  icon: string;
  color: string;
  onPress: () => void;
}

const FeatureCard: React.FC<FeatureCardProps> = ({ title, description, icon, color, onPress }) => {
  return (
    <TouchableOpacity style={styles.card} onPress={onPress}>
      <View style={[styles.iconContainer, { backgroundColor: `${color}20` }]}>
        <Ionicons name={icon as any} size={28} color={color} />
      </View>
      <View style={styles.cardContent}>
        <Text style={styles.cardTitle}>{title}</Text>
        <Text style={styles.cardDescription}>{description}</Text>
      </View>
      <Ionicons name="chevron-forward" size={24} color="#ccc" />
    </TouchableOpacity>
  );
};

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
    fontSize: 24,
    fontWeight: 'bold',
  },
  content: {
    flex: 1,
    padding: 16,
  },
  heading: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginTop: 20,
  },
  subheading: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
  },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#fff',
    borderRadius: 12,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  iconContainer: {
    width: 50,
    height: 50,
    borderRadius: 25,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  cardContent: {
    flex: 1,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 4,
  },
  cardDescription: {
    fontSize: 14,
    color: '#666',
  },
}); 