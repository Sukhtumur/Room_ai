import React, { useEffect, useState } from 'react';
import { StyleSheet, View, Text, TouchableOpacity, FlatList, Image, Alert, ActivityIndicator, ScrollView, Linking } from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext } from '@/app/context/AppContext';
import { StatusBar } from 'expo-status-bar';
import SupabaseService from '@/app/services/supabaseService';
import { theme } from '@/app/utils/theme';
import Constants from 'expo-constants';
import * as Share from 'expo-sharing';

export default function SettingsScreen() {
  const { deviceId } = useAppContext();
  const [savedDesigns, setSavedDesigns] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const appVersion = Constants.expoConfig?.version || '1.0.0';

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

  const openLink = (url: string) => {
    Linking.openURL(url).catch(err => {
      console.error('Error opening URL:', err);
      Alert.alert('Error', 'Could not open the link');
    });
  };

  const renderSettingItem = (icon: string, title: string, onPress: () => void) => (
    <TouchableOpacity style={styles.settingItem} onPress={onPress}>
      <Ionicons name={icon as any} size={22} color={theme.colors.text} />
      <Text style={styles.settingText}>{title}</Text>
      <Ionicons name="chevron-forward" size={18} color={theme.colors.textSecondary} />
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <StatusBar style="auto" />
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Ionicons name="arrow-back" size={24} color={theme.colors.text} />
        </TouchableOpacity>
        <Text style={styles.title}>Settings</Text>
        <View style={{ width: 24 }} />
      </View>

      <ScrollView style={styles.content}>
        {/* Pro Subscription Banner */}
        <View style={styles.proBanner}>
          <View style={styles.proTextContainer}>
            <Text style={styles.proTitle}>Get AI Remodel Pro</Text>
            <Text style={styles.proDescription}>Unlimited designs, priority processing, and more</Text>
            <TouchableOpacity style={styles.tryButton}>
              <Text style={styles.tryButtonText}>Try Now</Text>
            </TouchableOpacity>
          </View>
          <Image 
            source={{ uri: savedDesigns[0]?.image_url || 'https://via.placeholder.com/100' }} 
            style={styles.proImage}
          />
        </View>

        {/* Recent Designs Section */}
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Recent Designs</Text>
          <TouchableOpacity onPress={() => router.push('/profile')}>
            <Text style={styles.seeAllText}>See All</Text>
          </TouchableOpacity>
        </View>

        {isLoading ? (
          <ActivityIndicator size="small" color={theme.colors.text} style={styles.loader} />
        ) : savedDesigns.length > 0 ? (
          <FlatList
            data={savedDesigns.slice(0, 3)}
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.recentDesignsList}
            keyExtractor={(item) => item.id}
            renderItem={({ item }) => (
              <TouchableOpacity style={styles.recentDesignCard}>
                <Image 
                  source={{ uri: item.image_url }} 
                  style={styles.recentDesignImage}
                />
                <Text style={styles.recentDesignType} numberOfLines={1}>
                  {item.feature_type || 'Interior Design'}
                </Text>
              </TouchableOpacity>
            )}
          />
        ) : (
          <Text style={styles.noDesignsText}>No designs yet</Text>
        )}

        {/* Settings Items */}
        <View style={styles.settingsSection}>
          {renderSettingItem('mail-outline', 'Contact Us', () => openLink('mailto:support@roomai.com'))}
          {renderSettingItem('help-circle-outline', 'FAQ', () => openLink('https://roomai.com/faq'))}
          {renderSettingItem('document-text-outline', 'Terms of Use', () => openLink('https://roomai.com/terms'))}
          {renderSettingItem('shield-outline', 'Privacy Policy', () => openLink('https://roomai.com/privacy'))}
          {renderSettingItem('star-outline', 'Rate the App', () => openLink('https://apps.apple.com'))}
          {renderSettingItem('share-outline', 'Share with Friends', () => {
            Share.shareAsync('https://roomai.com', {
              dialogTitle: 'Check out Room AI - the amazing app for redesigning your space!'
            });
          })}
        </View>

        {/* App Version */}
        <Text style={styles.versionText}>Version {appVersion}</Text>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: theme.spacing.md,
    paddingTop: 60,
    paddingBottom: theme.spacing.md,
    backgroundColor: theme.colors.background,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border,
  },
  title: {
    fontSize: theme.typography.fontSize.xl,
    fontWeight: 'bold',
    color: theme.colors.text,
  },
  content: {
    flex: 1,
  },
  proBanner: {
    flexDirection: 'row',
    backgroundColor: theme.colors.card,
    margin: theme.spacing.md,
    borderRadius: theme.borderRadius.lg,
    overflow: 'hidden',
    shadowColor: theme.colors.shadow,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  proTextContainer: {
    flex: 1,
    padding: theme.spacing.md,
    justifyContent: 'center',
  },
  proTitle: {
    fontSize: theme.typography.fontSize.lg,
    fontWeight: 'bold',
    color: theme.colors.text,
    marginBottom: 4,
  },
  proDescription: {
    fontSize: theme.typography.fontSize.sm,
    color: theme.colors.textSecondary,
    marginBottom: theme.spacing.md,
  },
  tryButton: {
    backgroundColor: theme.colors.text,
    paddingVertical: theme.spacing.sm,
    paddingHorizontal: theme.spacing.md,
    borderRadius: theme.borderRadius.md,
    alignSelf: 'flex-start',
  },
  tryButtonText: {
    color: theme.colors.background,
    fontWeight: '600',
    fontSize: theme.typography.fontSize.sm,
  },
  proImage: {
    width: 100,
    height: '100%',
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: theme.spacing.md,
    marginTop: theme.spacing.lg,
    marginBottom: theme.spacing.sm,
  },
  sectionTitle: {
    fontSize: theme.typography.fontSize.md,
    fontWeight: '600',
    color: theme.colors.text,
  },
  seeAllText: {
    fontSize: theme.typography.fontSize.sm,
    color: theme.colors.text,
  },
  loader: {
    marginVertical: theme.spacing.md,
  },
  recentDesignsList: {
    paddingHorizontal: theme.spacing.md,
  },
  recentDesignCard: {
    width: 120,
    marginRight: theme.spacing.md,
    borderRadius: theme.borderRadius.md,
    overflow: 'hidden',
    backgroundColor: theme.colors.card,
    shadowColor: theme.colors.shadow,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  recentDesignImage: {
    width: '100%',
    height: 100,
  },
  recentDesignType: {
    fontSize: theme.typography.fontSize.xs,
    color: theme.colors.text,
    padding: theme.spacing.sm,
  },
  noDesignsText: {
    textAlign: 'center',
    color: theme.colors.textSecondary,
    padding: theme.spacing.md,
  },
  settingsSection: {
    marginTop: theme.spacing.lg,
    borderTopWidth: 1,
    borderBottomWidth: 1,
    borderColor: theme.colors.border,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: theme.spacing.md,
    paddingHorizontal: theme.spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border,
  },
  settingText: {
    flex: 1,
    marginLeft: theme.spacing.md,
    fontSize: theme.typography.fontSize.md,
    color: theme.colors.text,
  },
  versionText: {
    textAlign: 'center',
    fontSize: theme.typography.fontSize.xs,
    color: theme.colors.textSecondary,
    marginVertical: theme.spacing.xl,
  },
}); 