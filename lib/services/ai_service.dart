import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class AIService {
  // Sends a request to the AI API and returns the generated image URL.
  static Future<String?> generateDesign({
    required File image,
    required String roomType,
    required String style,
  }) async {
    final startTime = DateTime.now();
    // Use the DALL-E API endpoint
    final uri = Uri.parse("https://api.openai.com/v1/images/generations");
    
    print("Starting image generation for $style $roomType...");
    
    // Ensure the image exists and is readable
    if (!image.existsSync()) {
      print("Error: Image file does not exist at path: ${image.path}");
      return null;
    }
    
    // For DALL-E 3, we don't need to upload the image - we just describe what we want
    final requestBody = {
      "model": "dall-e-3",
      "prompt": "Create a $style design for a $roomType. Make it photorealistic and detailed.",
      "n": 1,
      "size": "1024x1024"
    };
    
    print("Request payload: ${json.encode(requestBody)}");

    print("Sending request to OpenAI API...");
    
    // Send a regular JSON request instead of multipart
    late final http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AppConstants.daliApiKey}"
        },
        body: json.encode(requestBody),
      ).timeout(Duration(seconds: 180));
      print("Received response with status: ${response.statusCode}");
    } catch (e) {
      print("Request timed out or failed after ${DateTime.now().difference(startTime).inSeconds} seconds: $e");
      return null;
    }

    final endTime = DateTime.now();
    print("API call took: ${endTime.difference(startTime).inSeconds} seconds");

    final resBody = response.body;
    print("Response body length: ${resBody.length} characters");
    
    if (response.statusCode == 200) {
      final data = json.decode(resBody);
      print("Successfully parsed JSON response");
      if (data != null && data['data'] != null && data['data'].isNotEmpty) {
        print("Found image URL in response");
        return data['data'][0]['url'];
      } else {
        print("Unexpected API response: $resBody");
        return null;
      }
    } else {
      print("Error generating design: ${response.statusCode} - $resBody");
      
      // Try to parse the error for more details
      try {
        final errorData = json.decode(resBody);
        if (errorData['error'] != null) {
          print("Error details: ${errorData['error']['message']}");
        }
      } catch (e) {
        // If we can't parse the error, just continue
      }
      
      return null;
    }
  }
} 