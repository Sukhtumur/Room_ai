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
    final uri = Uri.parse(AppConstants.apiEndpoint);
    final request = http.MultipartRequest('POST', uri)
      ..fields['prompt'] = 'A $style design for a $roomType'
      ..files.add(await http.MultipartFile.fromPath('image', image.path))
      ..headers['Authorization'] = 'Bearer ${AppConstants.daliApiKey}';

    final response = await request.send();
    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);
      return data['data'][0]['url'];
    }
    return null;
  }
} 