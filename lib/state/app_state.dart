import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AppState extends ChangeNotifier {
  File? _image;
  String? _roomType;
  String? _style;
  String? _generatedImageUrl;
  late String _userId;
  bool _isAnonymous = true;

  File? get image => _image;
  String? get roomType => _roomType;
  String? get style => _style;
  String? get generatedImageUrl => _generatedImageUrl;
  String get userId => _userId;
  bool get isAnonymous => _isAnonymous;

  AppState() {
    _userId = Uuid().v4();
  }
  
  void setUserId(String id) {
    _userId = id;
    _isAnonymous = false;
    notifyListeners();
  }
  
  void setAnonymous(bool value) {
    _isAnonymous = value;
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

  void setStyle(String style) {
    _style = style;
    notifyListeners();
  }

  void setGeneratedImageUrl(String url) {
    _generatedImageUrl = url;
    notifyListeners();
  }
} 