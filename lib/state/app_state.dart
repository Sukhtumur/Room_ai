import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  String _deviceId = '';
  String get deviceId => _deviceId;
  
  File? _image;
  File? get image => _image;
  
  String? _roomType;
  String? get roomType => _roomType;
  
  String? _buildingType;
  String? get buildingType => _buildingType;
  
  String? _style;
  String? get style => _style;
  
  String? _colorPalette;
  String? get colorPalette => _colorPalette;
  
  String? _featureType;
  String? get featureType => _featureType;
  
  String? _prompt;
  String? get prompt => _prompt;
  
  String? _generatedImageUrl;
  String? get generatedImageUrl => _generatedImageUrl;
  
  List<Map<String, dynamic>> _savedDesigns = [];
  List<Map<String, dynamic>> get savedDesigns => _savedDesigns;
  
  AppState() {
    _initDeviceId();
  }
  
  Future<void> _initDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('device_id');
    
    if (storedId == null || storedId.isEmpty) {
      storedId = const Uuid().v4();
      await prefs.setString('device_id', storedId);
    }
    
    _deviceId = storedId;
    print("Device ID initialized: $_deviceId");
    notifyListeners();
  }
  
  void setImage(File image) {
    _image = image;
    notifyListeners();
  }
  
  void setRoomType(String roomType) {
    _roomType = roomType;
    notifyListeners();
  }
  
  void setBuildingType(String buildingType) {
    _buildingType = buildingType;
    notifyListeners();
  }
  
  void setStyle(String style) {
    _style = style;
    notifyListeners();
  }
  
  void setColorPalette(String colorPalette) {
    _colorPalette = colorPalette;
    notifyListeners();
  }
  
  void setFeatureType(String featureType) {
    _featureType = featureType;
    notifyListeners();
  }
  
  void setPrompt(String prompt) {
    _prompt = prompt;
    notifyListeners();
  }
  
  void setGeneratedImageUrl(String url) {
    _generatedImageUrl = url;
    notifyListeners();
  }
  
  void setSavedDesigns(List<Map<String, dynamic>> designs) {
    _savedDesigns = designs;
    notifyListeners();
  }
  
  void reset() {
    _image = null;
    _roomType = null;
    _buildingType = null;
    _style = null;
    _colorPalette = null;
    _featureType = null;
    _prompt = null;
    _generatedImageUrl = null;
    notifyListeners();
  }
  
  Future<void> initializeDeviceId() async {
    await _initDeviceId();
    // Wait until device ID is set
    while (_deviceId.isEmpty) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    print("Device ID initialized and ready: $_deviceId");
  }
} 