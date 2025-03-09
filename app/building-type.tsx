import React from 'react';
import { StyleSheet, View, Text, TouchableOpacity, FlatList } from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext } from '@/app/context/AppContext';
import { StatusBar } from 'expo-status-bar';

const buildingTypes = [
  { name: 'House', icon: 'home' },
  { name: 'Villa', icon: 'business' },
  { name: 'Apartment', icon: 'apartment' },
  { name: 'Office', icon: 'business-outline' },
  { name: 'Backyard', icon: 'leaf' },
  { name: 'Patio', icon: 'sunny' },
];

export default function BuildingTypeScreen() {
  const { setBuildingType } = useAppContext();

  const handleBuildingSelect = (buildingType: string) => {
    setBuildingType(buildingType);
    router.push('/style-selection');
  };

  return (
    <View style={styles.container}>
      <StatusBar style="auto" />
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Ionicons name="arrow-back" size={24} color="#333" />
        </TouchableOpacity>
        <Text style={styles.title}>Select Building Type</Text>
        <View style={{ width: 24 }} />
      </View>

      <FlatList
        data={buildingTypes}
        numColumns={2}
        contentContainerStyle={styles.grid}
        keyExtractor={(item) => item.name}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styles.buildingCard}
            onPress={() => handleBuildingSelect(item.name)}
          >
            <View style={styles.iconContainer}>
              <Ionicons name={item.icon as any} size={40} color="#34A853" />
            </View>
            <Text style={styles.buildingName}>{item.name}</Text>
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
  buildingCard: {
    flex: 1,
    margin: 8,
    height: 150,
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  iconContainer: {
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: '#f0fff0',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  buildingName: {
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
}); 