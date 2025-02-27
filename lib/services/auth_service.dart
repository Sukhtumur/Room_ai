import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:gotrue/src/types/provider.dart' show Provider;
import 'dart:io' show Platform;

class AuthService {
  final SupabaseClient _supabaseClient;
  
  AuthService(this._supabaseClient);
  
  // Singleton pattern
  static final AuthService _instance = AuthService(Supabase.instance.client);
  static AuthService get instance => _instance;
  
  // Check if user is signed in
  bool get isSignedIn => _supabaseClient.auth.currentUser != null;
  
  // Get current user
  User? get currentUser => _supabaseClient.auth.currentUser;
  
  // Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  // Sign in with Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // Start the Google sign-in flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in flow
        return null;
      }
      
      // Get authentication details from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Use the Google credentials to sign in with Supabase
      return await _supabaseClient.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: googleAuth.idToken!,
      );
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }
  
  // Sign in with Apple
  Future<AuthResponse?> signInWithApple() async {
    try {
      // Check if Apple Sign In is available (mainly for iOS)
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable && !Platform.isIOS) {
        throw Exception('Sign in with Apple is not available on this device');
      }
      
      // Get Apple credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // Use the Apple credentials to sign in with Supabase
      return await _supabaseClient.auth.signInWithIdToken(
        provider: Provider.apple,
        idToken: appleCredential.identityToken!,
      );
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }
} 