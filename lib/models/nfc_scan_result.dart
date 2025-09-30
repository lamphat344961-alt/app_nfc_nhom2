class NFCScanResult {
  final String id;
  final String type;
  final String standard;
  final String data;
  final DateTime timestamp;

  NFCScanResult({
    required this.id,
    required this.type,
    required this.standard,
    required this.data,
    required this.timestamp,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'standard': standard,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from JSON
  factory NFCScanResult.fromJson(Map<String, dynamic> json) {
    return NFCScanResult(
      id: json['id'] as String,
      type: json['type'] as String,
      standard: json['standard'] as String? ?? 'Unknown',
      data: json['data'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // Copy with
  NFCScanResult copyWith({
    String? id,
    String? type,
    String? standard,
    String? data,
    DateTime? timestamp,
  }) {
    return NFCScanResult(
      id: id ?? this.id,
      type: type ?? this.type,
      standard: standard ?? this.standard,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'NFCScanResult(id: $id, type: $type, standard: $standard, data: $data, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NFCScanResult &&
        other.id == id &&
        other.type == type &&
        other.standard == standard &&
        other.data == data &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        standard.hashCode ^
        data.hashCode ^
        timestamp.hashCode;
  }
}
