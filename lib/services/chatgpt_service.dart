import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ChatGPTService {
  static const String chatGptApiEndpoint = "https://api.openai.com/v1/chat/completions";
  static const String chatGptModel = "gpt-4o-mini";

  /// Gets product recommendations from ChatGPT.
  /// The prompt requests three Amazon product suggestions formatted as a JSON array.
  static Future<List<ProductRecommendation>> getProductRecommendations({
    required String style,
    required String roomType,
  }) async {
    final prompt = "Suggest three top Amazon products to redecorate a $roomType "
        "with a $style style. Return the answer as a JSON array of objects where each object has the keys: "
        "name, description, price, url. Return ONLY the JSON array with no other text.";

    final response = await http.post(
      Uri.parse(chatGptApiEndpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${AppConstants.daliApiKey}",
      },
      body: json.encode({
        "model": chatGptModel,
        "messages": [
          {"role": "system", "content": "You are an interior design assistant. Always respond with valid JSON only."},
          {"role": "user", "content": prompt}
        ],
        "temperature": 0.7,
        "response_format": {"type": "json_object"}, // Force JSON response format
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final choices = data['choices'];
      if (choices == null || choices.isEmpty) {
        print("No choices returned in ChatGPT response: ${response.body}");
        return [];
      }
      final message = choices[0]['message'];
      if (message == null || message['content'] == null) {
        print("No content in ChatGPT response: ${response.body}");
        return [];
      }
      final content = message['content'];
      try {
        // Clean the content in case it has markdown code blocks
        String cleanedContent = content;
        if (content.contains("```")) {
          // Extract content between code blocks if present
          final RegExp jsonBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
          final match = jsonBlockRegex.firstMatch(content);
          if (match != null && match.groupCount >= 1) {
            cleanedContent = match.group(1)!.trim();
          }
        }
        
        final recommendations = json.decode(cleanedContent);
        if (recommendations is List) {
          return recommendations.map((e) => ProductRecommendation.fromJson(e)).toList();
        } else {
          // If it's not a list but an object with a data field, try that
          if (recommendations is Map) {
            // Check for various possible structures
            if (recommendations.containsKey('data') && recommendations['data'] is List) {
              return (recommendations['data'] as List).map((e) => ProductRecommendation.fromJson(e)).toList();
            } else if (recommendations.containsKey('products') && recommendations['products'] is List) {
              return (recommendations['products'] as List).map((e) => ProductRecommendation.fromJson(e)).toList();
            }
          }
          print("Unexpected format in ChatGPT response: $cleanedContent");
          return [];
        }
      } catch (e) {
        print("Failed to parse ChatGPT response: $e\nContent was: $content");
        return [];
      }
    } else {
      print("Error calling ChatGPT API: ${response.statusCode} - ${response.body}");
      return [];
    }
  }
}

class ProductRecommendation {
  final String name;
  final String description;
  final String price;
  final String url;
  
  ProductRecommendation({
    required this.name,
    required this.description,
    required this.price,
    required this.url,
  });

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      price: json["price"] is num ? json["price"].toString() : json["price"] ?? "",
      url: json["url"] ?? "",
    );
  }
} 