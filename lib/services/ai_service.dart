import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class AIService {
  // Main method to handle all design types
  static Future<String?> generateDesign({
    required File image,
    required String? roomType,
    required String? style,
    required String? featureType,
    required String? prompt,
    String? colorPalette,
    String? buildingType,
  }) async {
    print("Starting image generation for feature: $featureType");
    
    if (!image.existsSync()) {
      print("Error: Image file does not exist at path: ${image.path}");
      return null;
    }
    
    // Convert image to PNG format first
    final pngImage = await _convertToPng(image);
    
    switch (featureType) {
      case 'Interior Design':
        return _generateInteriorDesign(pngImage, roomType, style, colorPalette);
      case 'Exterior Design':
        return _generateExteriorDesign(pngImage, buildingType, style, colorPalette);
      case 'Object Editing':
        return _generateObjectEdit(pngImage, prompt);
      case 'Paint & Color':
        return _generatePaintColor(pngImage, prompt);
      default:
        print("Unknown feature type: $featureType");
        return null;
    }
  }
  
  // Convert any image to PNG format with alpha channel and resize to 1024x1024
  static Future<File> _convertToPng(File inputFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final pngPath = '${tempDir.path}/converted_image.png';
      final bytes = await inputFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        print("Failed to decode image");
        return inputFile;
      }

      // Resize to 1024x1024 (DALL-E 2 requirement)
      final resizedImage = img.copyResize(decodedImage, width: 1024, height: 1024);
      
      // Ensure alpha channel by creating a new RGBA image
      final rgbaImage = img.Image(width: 1024, height: 1024);
      
      // Copy the image data
      for (var y = 0; y < resizedImage.height; y++) {
        for (var x = 0; x < resizedImage.width; x++) {
          final pixel = resizedImage.getPixel(x, y);
          rgbaImage.setPixel(x, y, pixel);
        }
      }
      
      // Add a single transparent pixel to force RGBA format
      if (rgbaImage.width > 0 && rgbaImage.height > 0) {
        rgbaImage.setPixel(0, 0, img.ColorRgba8(255, 255, 255, 254));
      }
      
      final pngBytes = img.encodePng(rgbaImage);
      final pngFile = File(pngPath);
      await pngFile.writeAsBytes(pngBytes);
      
      print("Converted and resized image to 1024x1024 PNG with alpha channel");
      return pngFile;
    } catch (e) {
      print("Error converting image to PNG: $e");
      return inputFile;
    }
  }
  
  // Interior design generation
  static Future<String?> _generateInteriorDesign(
    File image, 
    String? roomType, 
    String? style,
    String? colorPalette
  ) async {
    final uri = Uri.parse("https://api.openai.com/v1/images/edits");
    
    // Create a mask specific to interior design
    final maskFile = await _createTransparentMask(image, featureType: 'Interior Design');
    
    // Build a detailed prompt
    String detailedPrompt = "Transform this $roomType into a $style style";
    if (colorPalette != null && colorPalette.isNotEmpty) {
      detailedPrompt += " with a $colorPalette color palette";
    }
    detailedPrompt += ". Keep the same layout but completely redesign the furniture, decor, and finishes.";
    
    // Create multipart request for DALL-E 2 edits
    var request = http.MultipartRequest('POST', uri);
    
    request.headers.addAll({
      "Authorization": "Bearer ${AppConstants.daliApiKey}"
    });
    
    request.fields['prompt'] = detailedPrompt;
    request.fields['n'] = '1';
    request.fields['size'] = '1024x1024';
    request.fields['model'] = 'dall-e-2';
    
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.files.add(await http.MultipartFile.fromPath('mask', maskFile.path));
    
    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 180));
      final response = await http.Response.fromStream(streamedResponse);
      
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0]['url'];
        }
      }
      
      print("Error: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Request failed: $e");
      return null;
    }
  }
  
  // Exterior design generation
  static Future<String?> _generateExteriorDesign(
    File image, 
    String? buildingType, 
    String? style,
    String? colorPalette
  ) async {
    final uri = Uri.parse("https://api.openai.com/v1/images/edits");
    
    // Create a mask specific to exterior design
    final maskFile = await _createTransparentMask(image, featureType: 'Exterior Design');
    
    // Build a detailed prompt
    String detailedPrompt = "Transform this $buildingType exterior into a $style style";
    if (colorPalette != null && colorPalette.isNotEmpty) {
      detailedPrompt += " with a $colorPalette color palette";
    }
    detailedPrompt += ". Keep the same structure but redesign the exterior appearance.";
    
    // Create multipart request for DALL-E 2 edits
    var request = http.MultipartRequest('POST', uri);
    
    request.headers.addAll({
      "Authorization": "Bearer ${AppConstants.daliApiKey}"
    });
    
    request.fields['prompt'] = detailedPrompt;
    request.fields['n'] = '1';
    request.fields['size'] = '1024x1024';
    request.fields['model'] = 'dall-e-2';
    
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.files.add(await http.MultipartFile.fromPath('mask', maskFile.path));
    
    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 180));
      final response = await http.Response.fromStream(streamedResponse);
      
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0]['url'];
        }
      }
      
      print("Error: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Request failed: $e");
      return null;
    }
  }
  
  // Object editing with masking
  static Future<String?> _generateObjectEdit(
    File image, 
    String? prompt
  ) async {
    final uri = Uri.parse("https://api.openai.com/v1/images/edits");
    
    // Create a mask specific to object editing
    final maskFile = await _createTransparentMask(image, featureType: 'Object Editing');
    
    // Create multipart request for DALL-E 2 edits
    var request = http.MultipartRequest('POST', uri);
    
    request.headers.addAll({
      "Authorization": "Bearer ${AppConstants.daliApiKey}"
    });
    
    String enhancedPrompt = prompt ?? "Edit this room";
    // Make the prompt more specific for object editing
    enhancedPrompt = "Replace or modify objects in the image: $enhancedPrompt. Keep everything else exactly the same.";
    
    request.fields['prompt'] = enhancedPrompt;
    request.fields['n'] = '1';
    request.fields['size'] = '1024x1024';
    request.fields['model'] = 'dall-e-2';
    
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.files.add(await http.MultipartFile.fromPath('mask', maskFile.path));
    
    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 180));
      final response = await http.Response.fromStream(streamedResponse);
      
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0]['url'];
        }
      }
      
      print("Error: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Request failed: $e");
      return null;
    }
  }
  
  // Paint and color changes with masking
  static Future<String?> _generatePaintColor(
    File image, 
    String? prompt
  ) async {
    final uri = Uri.parse("https://api.openai.com/v1/images/edits");
    
    // Create a mask specific to paint and color changes
    final maskFile = await _createTransparentMask(image, featureType: 'Paint & Color');
    
    // Create multipart request for DALL-E 2 edits
    var request = http.MultipartRequest('POST', uri);
    
    request.headers.addAll({
      "Authorization": "Bearer ${AppConstants.daliApiKey}"
    });
    
    String enhancedPrompt = prompt ?? "Change the colors";
    // Make the prompt more specific for color changes
    enhancedPrompt = "Change only the colors in the image: $enhancedPrompt. Keep all objects and layout exactly the same.";
    
    request.fields['prompt'] = enhancedPrompt;
    request.fields['n'] = '1';
    request.fields['size'] = '1024x1024';
    request.fields['model'] = 'dall-e-2';
    
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.files.add(await http.MultipartFile.fromPath('mask', maskFile.path));
    
    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 180));
      final response = await http.Response.fromStream(streamedResponse);
      
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0]['url'];
        }
      }
      
      print("Error: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Request failed: $e");
      return null;
    }
  }
  
  // Helper method to create a mask for DALL-E 2 edits based on feature type
  static Future<File> _createTransparentMask(File originalImage, {String? featureType, String? prompt}) async {
    final tempDir = await getTemporaryDirectory();
    final maskPath = '${tempDir.path}/mask.png';
    
    try {
      // Get image dimensions
      final bytes = await originalImage.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) throw Exception("Failed to decode image for mask");
      
      // Create a mask with alpha channel (1024x1024 required by DALL-E)
      final mask = img.Image(width: 1024, height: 1024);
      
      // Default: fully opaque mask (preserves original image)
      for (var y = 0; y < mask.height; y++) {
        for (var x = 0; x < mask.width; x++) {
          mask.setPixel(x, y, img.ColorRgba8(255, 255, 255, 255)); // Opaque white
        }
      }
      
      // Customize mask based on feature type
      if (featureType == 'Interior Design') {
        // For interior design, make furniture and decor areas transparent
        // This is a simplified approach - in a real app, use ML to detect furniture
        for (var y = 300; y < 800; y++) {
          for (var x = 200; x < 800; x++) {
            mask.setPixel(x, y, img.ColorRgba8(255, 255, 255, 0)); // Transparent
          }
        }
      } else if (featureType == 'Exterior Design') {
      // Save the mask
      final maskFile = File(maskPath);
      await maskFile.writeAsBytes(img.encodePng(mask));
      
      print("Created transparent mask with alpha channel");
      return maskFile;
    } catch (e) {
      print("Error creating mask: $e");
      
      // Create a fallback mask with alpha channel
      final mask = img.Image(width: 1024, height: 1024);
      
      // Fill with white, fully transparent
      for (var y = 0; y < mask.height; y++) {
        for (var x = 0; x < mask.width; x++) {
          mask.setPixel(x, y, img.ColorRgba8(255, 255, 255, 0));
        }
      }
      
      final maskFile = File(maskPath);
      await maskFile.writeAsBytes(img.encodePng(mask));
      
      print("Created fallback transparent mask with alpha channel");
      return maskFile;
    }
  }
} 