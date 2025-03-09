import React from 'react';
import { StyleSheet, View, Text, TouchableOpacity, FlatList, Image } from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext } from '@/app/context/AppContext';
import { StatusBar } from 'expo-status-bar';

const styles = [
  { name: 'Modern', image: require('@/assets/images/modern.jpg') },
  { name: 'Minimalistic', image: require('@/assets/images/minimalistic.jpg') },
  { name: 'Industrial', image: require('@/assets/images/minimalistic.jpg') },
  { name: 'Scandinavian', image: require('@/assets/images/bohemian.jpg') },
  { name: 'Bohemian', image: require('@/assets/images/bohemian.jpg') },
  { name: 'Traditional', image: require('@/assets/images/minimalistic.jpg') },
];

export default function StyleSelectionScreen() {
  const { setStyle, roomType, featureType } = useAppContext();

  const handleStyleSelect = (style: string) => {
    setStyle(style);
    router.push('/color-palette');
  };

  return (
    <View style={styleSheet.container}>
      <StatusBar style="auto" />
      <View style={styleSheet.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Ionicons name="arrow-back" size={24} color="#333" />
        </TouchableOpacity>
        <Text style={styleSheet.title}>
          {featureType === 'Interior Design' && roomType
            ? `Select Style for ${roomType}`
            : 'Select Style'}
        </Text>
        <View style={{ width: 24 }} />
      </View>

      <FlatList
        data={styles}
        numColumns={2}
        contentContainerStyle={styleSheet.grid}
        keyExtractor={(item) => item.name}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styleSheet.styleCard}
            onPress={() => handleStyleSelect(item.name)}
          >
            <Image source={item.image} style={styleSheet.styleImage} />
            <View style={styleSheet.styleNameContainer}>
              <Text style={styleSheet.styleName}>{item.name}</Text>
            </View>
          </TouchableOpacity>
        )}
      />
    </View>
  );
}

const styleSheet = StyleSheet.create({
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
  grid: {
    padding: 16,
  },
  styleCard: {
    flex: 1,
    margin: 8,
    height: 180,
    borderRadius: 12,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  styleImage: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
  styleNameContainer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'rgba(0,0,0,0.6)',
    padding: 8,
  },
  styleName: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
}); 