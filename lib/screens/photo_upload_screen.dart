import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  _PhotoUploadScreenState createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  late AppState _appState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store a reference to the AppState
    _appState = Provider.of<AppState>(context, listen: false);
  }

  Future<void> _pickImage(String featureType) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      _appState.setImage(File(image.path));
      _appState.setFeatureType(featureType);
      
      // Different navigation flows based on feature type
      switch (featureType) {
        case 'Interior Design':
          Navigator.pushNamed(context, '/room-selection');
          break;
        case 'Exterior Design':
          Navigator.pushNamed(context, '/building-type');
          break;
        case 'Object Editing':
        case 'Paint & Color':
          Navigator.pushNamed(context, '/prompt-input');
          break;
      }
    }
  }

  Future<void> _takePhoto(String featureType) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null && mounted) {
      _appState.setImage(File(photo.path));
      _appState.setFeatureType(featureType);
      
      // Different navigation flows based on feature type
      switch (featureType) {
        case 'Interior Design':
          Navigator.pushNamed(context, '/room-selection');
          break;
        case 'Exterior Design':
          Navigator.pushNamed(context, '/building-type');
          break;
        case 'Object Editing':
        case 'Paint & Color':
          Navigator.pushNamed(context, '/prompt-input');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'View Profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const SizedBox(height: 20),
          const Text(
            'Transform your space with AI',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Select a feature to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Feature 1: Interior Design
          _buildFeatureCard(
            'Interior Design',
            'Redesign your indoor spaces with various styles',
            Icons.chair,
            Colors.blue,
          ),
          
          // Feature 2: Exterior Design
          _buildFeatureCard(
            'Exterior Design',
            'Transform the outside of your home',
            Icons.home,
            Colors.green,
          ),
          
          // Feature 3: Object Removal/Addition
          _buildFeatureCard(
            'Object Editing',
            'Remove or add furniture to your space',
            Icons.edit,
            Colors.orange,
          ),
          
          // Feature 4: Paint & Color
          _buildFeatureCard(
            'Paint & Color',
            'Change colors of walls, furniture and more',
            Icons.format_paint,
            Colors.purple,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showImageSourceDialog(title),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                radius: 25,
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showImageSourceDialog(String featureType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image Source for $featureType'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Gallery'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(featureType);
                  },
                ),
                GestureDetector(
                  child: const ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Camera'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePhoto(featureType);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 