import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/auth_service.dart';

class PhotoUploadScreen extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Provider.of<AppState>(context, listen: false).setImage(File(image.path));
      Navigator.pushNamed(context, '/room-selection');
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      Provider.of<AppState>(context, listen: false).setImage(File(photo.path));
      Navigator.pushNamed(context, '/room-selection');
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService.instance.signOut();
      // Reset to anonymous user
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setAnonymous(true);
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isSignedIn = !appState.isAnonymous;
    final user = AuthService.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Room AI'),
        actions: [
          if (isSignedIn)
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              tooltip: 'View Profile',
            ),
          if (!isSignedIn)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text('Sign In', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // User greeting
            if (isSignedIn && user?.email != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Text(
                  'Welcome, ${user!.email!.split('@')[0]}!',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            
            Text(
              'Upload a photo of your room',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'We\'ll transform it with AI',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(context),
                  icon: Icon(Icons.photo_library),
                  label: Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => _takePhoto(context),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 