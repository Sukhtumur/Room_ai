import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../services/chatgpt_service.dart';

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
    
    try {
      // First, generate a detailed description using ChatGPT
      String basePrompt = "Describe in detail a $style style ";
      
      if (featureType == 'Interior Design') {
        basePrompt += "$roomType with $colorPalette colors";
      } else if (featureType == 'Exterior Design') {
        basePrompt += "$buildingType exterior with $colorPalette colors";
      }
      
      if (prompt != null && prompt.isNotEmpty) {
        basePrompt += ". Include these details: $prompt";
      }
      
      basePrompt += ". Make it detailed enough for an AI image generator to create a photorealistic image.";
      
      print("Generating detailed description with prompt: $basePrompt");
      
      // Get detailed description from ChatGPT
      final detailedDescription = await ChatGPTService.getDetailedDescription(basePrompt);
      
      if (detailedDescription == null || detailedDescription.isEmpty) {
        print("Failed to generate detailed description");
        return null;
      }
      
      print("Generated description: $detailedDescription");
      
      // Now use DALL-E 3 to generate the image based on the detailed description
      final uri = Uri.parse("https://api.openai.com/v1/images/generations");
      
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AppConstants.daliApiKey}"
        },
        body: jsonEncode({
          "prompt": detailedDescription,
          "n": 1,
          "size": "1024x1024",
          "model": "dall-e-3",
          "quality": "hd"
        })
      );
      
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0]['url'];
        }
      }
      
      return null;
    } catch (e) {
      print("Error in generateDesign: $e");
      return null;
    }
  }
  
  // Convert any image to PNG format with alpha channel and resize to 1024x1024
  static Future<File> _convertToPng(File inputFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final pngPath = '${tempDir.path}/converted_image.png';
      
      // Create a blank RGBA image
      final rgbaImage = img.Image(width: 1024, height: 1024);
      
      // Fill with white background
      for (var y = 0; y < rgbaImage.height; y++) {
        for (var x = 0; x < rgbaImage.width; x++) {
          rgbaImage.setPixelRgba(x, y, 255, 255, 255, 255);
        }
      }
      
      // Save as PNG
      final pngBytes = img.encodePng(rgbaImage);
      final pngFile = File(pngPath);
      await pngFile.writeAsBytes(pngBytes);
      
      print("Created blank RGBA image");
      return pngFile;
    } catch (e) {
      print("Error creating RGBA image: $e");
      throw Exception("Failed to create RGBA image");
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
    
    final maskFile = await _createTransparentMask(image, featureType: 'Interior Design');
    
    // Enhanced prompt with more specific color instructions
    String detailedPrompt = "Transform this $roomType into a $style style interior";
    if (colorPalette != null && colorPalette.isNotEmpty) {
      detailedPrompt += ", using predominantly $colorPalette colors for walls, furniture, and decor";
    }
    detailedPrompt += ". Keep the same layout but redesign with new furniture, decor, and finishes that match this color scheme. Make it look realistic and professionally designed.";
    
    print("Generated prompt: $detailedPrompt"); // Debug print
    
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
        // For exterior, make facade areas transparent
        for (var y = 200; y < 900; y++) {
          for (var x = 200; x < 800; x++) {
            mask.setPixel(x, y, img.ColorRgba8(255, 255, 255, 0));
          }
        }
      } else if (featureType == 'Object Editing') {
        // For object editing, create a smaller targeted area
        for (var y = 400; y < 600; y++) {
          for (var x = 400; x < 600; x++) {
            mask.setPixel(x, y, img.ColorRgba8(255, 255, 255, 0));
          }
        }
      } else if (featureType == 'Paint & Color') {
        // For paint & color, target wall areas
        for (var y = 0; y < 1024; y++) {
          for (var x = 0; x < 1024; x++) {
            // Skip center area (furniture)
            if (!(x > 300 && x < 700 && y > 300 && y < 700)) {
              mask.setPixel(x, y, img.ColorRgba8(255, 255, 255, 0));
            }
          }
        }
      } else {
        // Default: make entire image transparent for full edit
        for (var y = 0; y < mask.height; y++) {
          for (var x = 0; x < mask.width; x++) {
            mask.setPixel(x, y, img.ColorRgba8(255, 255, 255, 0));
          }
        }
      }
      
      // Save the mask
      final maskFile = File(maskPath);
      await maskFile.writeAsBytes(img.encodePng(mask));
      
      print("Created custom mask for $featureType");
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