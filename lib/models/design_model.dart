class DesignModel {
  final String id;
  final String deviceId;
  final String? roomType;
  final String? style;
  final String imageUrl;
  final String? featureType;
  final String? prompt;
  final DateTime createdAt;

  DesignModel({
    required this.id,
    required this.deviceId,
    this.roomType,
    this.style,
    required this.imageUrl,
    this.featureType,
    this.prompt,
    required this.createdAt,
  });

  factory DesignModel.fromJson(Map<String, dynamic> json) {
    return DesignModel(
      id: json['id'],
      deviceId: json['device_id'],
      roomType: json['room_type'],
      style: json['style'],
      imageUrl: json['image_url'],
      featureType: json['feature_type'],
      prompt: json['prompt'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'room_type': roomType,
      'style': style,
      'image_url': imageUrl,
      'feature_type': featureType,
      'prompt': prompt,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 