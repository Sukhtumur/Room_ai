import 'dart:io';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  File? _image;
  String? _roomType;
  String? _style;
  String? _generatedImageUrl;

  File? get image => _image;
  String? get roomType => _roomType;
  String? get style => _style;
  String? get generatedImageUrl => _generatedImageUrl;

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