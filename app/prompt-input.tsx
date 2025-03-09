import React, { useState, useEffect } from 'react';
import { StyleSheet, View, Text, TextInput, TouchableOpacity, ScrollView, KeyboardAvoidingView, Platform } from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext } from '@/app/context/AppContext';
import { StatusBar } from 'expo-status-bar';

export default function PromptInputScreen() {
  const { setPrompt, roomType, buildingType, style, colorPalette, featureType } = useAppContext();
  const [promptText, setPromptText] = useState('');
  const [isValid, setIsValid] = useState(false);

  useEffect(() => {
    setIsValid(promptText.trim().length >= 5);
  }, [promptText]);

  const handleSubmit = () => {
    if (isValid) {
      setPrompt(promptText.trim());
      router.push('/results');
    }
  };

  // Generate a default prompt based on selected options
  const generateDefaultPrompt = () => {
    let defaultPrompt = '';
    
    if (featureType === 'Interior Design' && roomType && style && colorPalette) {
      defaultPrompt = `Redesign this ${roomType} in a ${style} style with a ${colorPalette} color palette.`;
    } else if (featureType === 'Exterior Design' && buildingType && style && colorPalette) {
      defaultPrompt = `Redesign this ${buildingType} exterior in a ${style} style with a ${colorPalette} color palette.`;
    } else if (featureType === 'Object Editing') {
      defaultPrompt = 'Remove or replace objects in this image.';
    } else if (featureType === 'Paint & Color') {
      defaultPrompt = 'Change the colors in this image.';
    }
    
    return defaultPrompt;
  };

  const handleUseDefaultPrompt = () => {
    const defaultPrompt = generateDefaultPrompt();
    setPromptText(defaultPrompt);
  };

  return (
    <KeyboardAvoidingView 
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      keyboardVerticalOffset={100}
    >
      <StatusBar style="auto" />
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Ionicons name="arrow-back" size={24} color="#333" />
        </TouchableOpacity>
        <Text style={styles.title}>Customize Your Prompt</Text>
        <View style={{ width: 24 }} />
      </View>

      <ScrollView style={styles.content} contentContainerStyle={styles.contentContainer}>
        <Text style={styles.label}>Describe what you want to change:</Text>
        <TextInput
          style={styles.input}
          placeholder="E.g., Make the walls blue, add more plants..."
          placeholderTextColor="#999"
          value={promptText}
          onChangeText={setPromptText}
          multiline
          numberOfLines={5}
          textAlignVertical="top"
        />
        
        <TouchableOpacity 
          style={styles.defaultPromptButton}
          onPress={handleUseDefaultPrompt}
        >
          <Text style={styles.defaultPromptText}>Use Default Prompt</Text>
        </TouchableOpacity>
        
        <Text style={styles.tip}>
          Be specific about what you want to change in the image. The more details you provide, the better the results.
        </Text>
        
        <TouchableOpacity
          style={[styles.generateButton, !isValid && styles.disabledButton]}
          onPress={handleSubmit}
          disabled={!isValid}
        >
          <Text style={styles.generateButtonText}>Generate Result</Text>
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
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
  contentContainer: {
    padding: 16,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    minHeight: 120,
    marginBottom: 16,
  },
  defaultPromptButton: {
    alignSelf: 'flex-start',
    marginBottom: 16,
  },
  defaultPromptText: {
    color: '#4285F4',
    fontSize: 16,
    fontWeight: '500',
  },
  tip: {
    fontSize: 14,
    color: '#666',
    marginBottom: 24,
    fontStyle: 'italic',
  },
  generateButton: {
    backgroundColor: '#4285F4',
    borderRadius: 8,
    padding: 16,
    alignItems: 'center',
  },
  disabledButton: {
    backgroundColor: '#ccc',
  },
  generateButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
}); 