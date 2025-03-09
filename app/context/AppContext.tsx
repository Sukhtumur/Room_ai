import React, { createContext, useState, useEffect, useContext } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

type AppContextType = {
  deviceId: string;
  image: string | null;
  roomType: string | null;
  buildingType: string | null;
  style: string | null;
  colorPalette: string | null;
  featureType: string | null;
  prompt: string | null;
  generatedImageUrl: string | null;
  savedDesigns: any[];
  setImage: (image: string) => void;
  setRoomType: (roomType: string) => void;
  setBuildingType: (buildingType: string) => void;
  setStyle: (style: string) => void;
  setColorPalette: (colorPalette: string) => void;
  setFeatureType: (featureType: string) => void;
  setPrompt: (prompt: string) => void;
  setGeneratedImageUrl: (url: string) => void;
  setSavedDesigns: (designs: any[]) => void;
  reset: () => void;
};

const AppContext = createContext<AppContextType | undefined>(undefined);

// Simple function to generate a random ID without using uuid
const generateId = () => {
  return Math.random().toString(36).substring(2, 15) + 
         Math.random().toString(36).substring(2, 15);
};

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [deviceId, setDeviceId] = useState('');
  const [image, setImage] = useState<string | null>(null);
  const [roomType, setRoomType] = useState<string | null>(null);
  const [buildingType, setBuildingType] = useState<string | null>(null);
  const [style, setStyle] = useState<string | null>(null);
  const [colorPalette, setColorPalette] = useState<string | null>(null);
  const [featureType, setFeatureType] = useState<string | null>(null);
  const [prompt, setPrompt] = useState<string | null>(null);
  const [generatedImageUrl, setGeneratedImageUrl] = useState<string | null>(null);
  const [savedDesigns, setSavedDesigns] = useState<any[]>([]);
  
  // Initialize device ID
  useEffect(() => {
    initializeDeviceId();
  }, []);
  
  const initializeDeviceId = async () => {
    try {
      let storedId = await AsyncStorage.getItem('device_id');
      
      if (!storedId) {
        storedId = generateId(); // Use our simple ID generator instead of uuid
        await AsyncStorage.setItem('device_id', storedId);
      }
      
      setDeviceId(storedId);
      console.log("Device ID initialized:", storedId);
    } catch (e) {
      console.error("Error initializing device ID:", e);
      // Fallback to a simple ID if there's an error
      const fallbackId = generateId();
      setDeviceId(fallbackId);
    }
  };
  
  const reset = () => {
    setImage(null);
    setRoomType(null);
    setBuildingType(null);
    setStyle(null);
    setColorPalette(null);
    setFeatureType(null);
    setPrompt(null);
    setGeneratedImageUrl(null);
  };
  
  return (
    <AppContext.Provider value={{
      deviceId,
      image, setImage,
      roomType, setRoomType,
      buildingType, setBuildingType,
      style, setStyle,
      colorPalette, setColorPalette,
      featureType, setFeatureType,
      prompt, setPrompt,
      generatedImageUrl, setGeneratedImageUrl,
      savedDesigns, setSavedDesigns,
      reset
    }}>
      {children}
    </AppContext.Provider>
  );
};

export const useAppContext = () => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useAppContext must be used within an AppProvider');
  }
  return context;
};

// Add a default export to fix the warning
export default AppContext; 