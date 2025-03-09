import { useEffect, useState } from 'react';
import { Stack } from 'expo-router';
import { useFonts } from 'expo-font';
import * as SplashScreen from 'expo-splash-screen';
import { AppProvider } from '@/app/context/AppContext';
import SupabaseService from '@/app/services/supabaseService';

// Prevent the splash screen from auto-hiding before asset loading is complete.
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const [isReady, setIsReady] = useState(false);
  const [loaded] = useFonts({
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
  });

  useEffect(() => {
    const initialize = async () => {
      try {
        // Test connection
        const supabaseService = SupabaseService.getInstance();
        const isConnected = await supabaseService.checkConnection();
        console.log("Database connected:", isConnected);
        
        setIsReady(true);
      } catch (e) {
        console.error("Initialization error:", e);
        setIsReady(true); // Still set ready to avoid blocking the app
      }
    };
    
    initialize();
  }, []);

  useEffect(() => {
    if (loaded && isReady) {
      SplashScreen.hideAsync();
    }
  }, [loaded, isReady]);

  if (!loaded || !isReady) {
    return null;
  }

  return (
    <AppProvider>
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="index" />
        <Stack.Screen name="room-selection" />
        <Stack.Screen name="building-type" />
        <Stack.Screen name="style-selection" />
        <Stack.Screen name="color-palette" />
        <Stack.Screen name="prompt-input" />
        <Stack.Screen name="results" />
        <Stack.Screen name="profile" />
      </Stack>
    </AppProvider>
  );
}
