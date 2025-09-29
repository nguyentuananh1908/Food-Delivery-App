class RealtimeLocationData {
  final String shipperId;
  final List<double> coordinates; // [longitude, latitude]
  final String address;
  final double accuracy;
  final double speed;
  final double heading;
  final DateTime timestamp;

  RealtimeLocationData({
    required this.shipperId,
    required this.coordinates,
    required this.address,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });

  factory RealtimeLocationData.fromJson(Map<String, dynamic> json) {
    return RealtimeLocationData(
      shipperId: json['shipperId'] ?? '',
      coordinates: List<double>.from(json['coordinates'] ?? []),
      address: json['address'] ?? '',
      accuracy: (json['accuracy'] ?? 10.0).toDouble(),
      speed: (json['speed'] ?? 0.0).toDouble(),
      heading: (json['heading'] ?? 0.0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shipperId': shipperId,
      'coordinates': coordinates,
      'address': address,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  double get latitude => coordinates.length >= 2 ? coordinates[1] : 0.0;
  double get longitude => coordinates.length >= 2 ? coordinates[0] : 0.0;

  bool get isValid => coordinates.length >= 2 && latitude != 0.0 && longitude != 0.0;
}
