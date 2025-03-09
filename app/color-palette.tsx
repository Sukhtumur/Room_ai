import React from 'react';
import { StyleSheet, View, Text, TouchableOpacity, FlatList } from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext } from '@/app/context/AppContext';
import { StatusBar } from 'expo-status-bar';

const colorPalettes = [
  {
    name: 'Neutral',
    colors: ['#F5F5F5', '#E0E0E0', '#BDBDBD', '#9E9E9E'],
  },
  {
    name: 'Warm',
    colors: ['#FFF8E1', '#FFE0B2', '#FFB74D', '#FF9800'],
  },
  {
    name: 'Cool',
    colors: ['#E1F5FE', '#B3E5FC', '#4FC3F7', '#03A9F4'],
  },
  {
    name: 'Earthy',
    colors: ['#F1F8E9', '#DCEDC8', '#AED581', '#8BC34A'],
  },
  {
    name: 'Bold',
    colors: ['#E8EAF6', '#C5CAE9', '#7986CB', '#3F51B5'],
  },
  {
    name: 'Monochrome',
    colors: ['#EEEEEE', '#BDBDBD', '#757575', '#212121'],
  },
];

export default function ColorPaletteScreen() {
  const { setColorPalette, roomType, buildingType, featureType } = useAppContext();

  const handleColorPaletteSelect = (palette: string) => {
    setColorPalette(palette);
    router.push('/prompt-input');
  };

  let title = 'Select Color Palette';
  if (featureType === 'Interior Design' && roomType) {
    title = `Color Palette for ${roomType}`;
  } else if (featureType === 'Exterior Design' && buildingType) {
    title = `Color Palette for ${buildingType}`;
  }

  return (
    <View style={styles.container}>
      <StatusBar style="auto" />
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Ionicons name="arrow-back" size={24} color="#333" />
        </TouchableOpacity>
        <Text style={styles.title}>{title}</Text>
        <View style={{ width: 24 }} />
      </View>

      <FlatList
        data={colorPalettes}
        numColumns={2}
        contentContainerStyle={styles.grid}
        keyExtractor={(item) => item.name}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styles.paletteCard}
            onPress={() => handleColorPaletteSelect(item.name)}
          >
            <View style={styles.colorsContainer}>
              {item.colors.map((color, index) => (
                <View
                  key={index}
                  style={[styles.colorSwatch, { backgroundColor: color }]}
                />
              ))}
            </View>
            <View style={styles.paletteNameContainer}>
              <Text style={styles.paletteName}>{item.name}</Text>
            </View>
          </TouchableOpacity>
        )}
      />
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
  grid: {
    padding: 16,
  },
  paletteCard: {
    flex: 1,
    margin: 8,
    height: 150,
    backgroundColor: '#fff',
    borderRadius: 12,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  colorsContainer: {
    flex: 1,
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  colorSwatch: {
    width: '50%',
    height: '50%',
  },
  paletteNameContainer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'rgba(0,0,0,0.6)',
    padding: 8,
  },
  paletteName: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
}); 