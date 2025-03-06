import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  File? _image;
  String? _roomType;
  String? _style;
  String? _generatedImageUrl;
  late String _deviceId;
  String? _featureType;
  String? _prompt;
  String? _colorPalette;
  String? _buildingType;

  File? get image => _image;
  String? get roomType => _roomType;
  String? get style => _style;
  String? get generatedImageUrl => _generatedImageUrl;
  String get deviceId => _deviceId;
  String? get featureType => _featureType;
  String? get prompt => _prompt;
  String? get colorPalette => _colorPalette;
  String? get buildingType => _buildingType;

  AppState() {
    _initDeviceId();
  }
  
  Future<void> _initDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('device_id');
    
    if (storedId == null) {
      // First time - generate and save a new UUID
      storedId = const Uuid().v4();
      await prefs.setString('device_id', storedId);
    }
    
    _deviceId = storedId;
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

  void setGeneratedImageUrl(String url) {
    _generatedImageUrl = url;
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
  
  void resetState() {
    _image = null;
    _roomType = null;
    _style = null;
    _generatedImageUrl = null;
    _featureType = null;
    _prompt = null;
    _colorPalette = null;
    _buildingType = null;
    notifyListeners();
  }
} 