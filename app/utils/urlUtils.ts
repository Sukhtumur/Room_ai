import * as Linking from 'expo-linking';
import { Alert } from 'react-native';

export const openURL = async (url: string) => {
  try {
    const supported = await Linking.canOpenURL(url);
    
    if (supported) {
      await Linking.openURL(url);
    } else {
      Alert.alert('Error', `Cannot open URL: ${url}`);
    }
  } catch (error) {
    console.error('Error opening URL:', error);
    Alert.alert('Error', 'An error occurred while trying to open the URL');
  }
};

// Add a dummy component as default export to satisfy Expo Router
const UrlUtils = () => null;
export default UrlUtils; 