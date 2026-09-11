import 'dart:convert';

class BagQrModel {
  final String bagId; // Format: BAG-YYYY-XXXXX
  final String ward;
  final String category; // Sharps, Infectious, Plastic, Glassware, Unknown
  final double weightKg;
  final String missionId;
  final DateTime generatedAt;
  final String generatedBy;
  final bool isDisposed;
  final DateTime? disposedAt;

  const BagQrModel({
    required this.bagId,
    required this.ward,
    required this.category,
    required this.weightKg,
    required this.missionId,
    required this.generatedAt,
    required this.generatedBy,
    this.isDisposed = false,
    this.disposedAt,
  });

  /// Serializes bag data to compact QR payload string
  String toQrString() {
    return jsonEncode({
      'id': bagId,
      'ward': ward,
      'cat': category,
      'wt': weightKg,
      'msn': missionId,
      'ts': generatedAt.toIso8601String(),
    });
  }

  /// Deserializes bag from QR payload string or standard JSON
  factory BagQrModel.fromQrString(String qrContent, {String generatedBy = 'Staff Officer'}) {
    try {
      final Map<String, dynamic> data = jsonDecode(qrContent);
      return BagQrModel(
        bagId: data['id'] ?? data['bagId'] ?? 'BAG-2026-00000',
        ward: data['ward'] ?? 'General Ward',
        category: data['cat'] ?? data['category'] ?? 'Infectious',
        weightKg: (data['wt'] ?? data['weightKg'] ?? 1.0).toDouble(),
        missionId: data['msn'] ?? data['missionId'] ?? 'M-001',
        generatedAt: data['ts'] != null
            ? DateTime.parse(data['ts'])
            : DateTime.now(),
        generatedBy: generatedBy,
      );
    } catch (_) {
      // Fallback if plain bag ID scanned
      final cleanId = qrContent.trim();
      return BagQrModel(
        bagId: cleanId.startsWith('BAG-') ? cleanId : 'BAG-2026-${cleanId.hashCode.abs() % 90000 + 10000}',
        ward: 'ICU Wing A',
        category: 'Infectious',
        weightKg: 2.4,
        missionId: 'MSN-2026-ICU',
        generatedAt: DateTime.now(),
        generatedBy: generatedBy,
      );
    }
  }

  factory BagQrModel.fromJson(Map<String, dynamic> json) {
    return BagQrModel(
      bagId: json['bagId'] as String,
      ward: json['ward'] as String,
      category: json['category'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      missionId: json['missionId'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      generatedBy: json['generatedBy'] as String? ?? 'Staff',
      isDisposed: json['isDisposed'] as bool? ?? false,
      disposedAt: json['disposedAt'] != null
          ? DateTime.parse(json['disposedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bagId': bagId,
      'ward': ward,
      'category': category,
      'weightKg': weightKg,
      'missionId': missionId,
      'generatedAt': generatedAt.toIso8601String(),
      'generatedBy': generatedBy,
      'isDisposed': isDisposed,
      if (disposedAt != null) 'disposedAt': disposedAt!.toIso8601String(),
    };
  }

  BagQrModel copyWith({
    String? bagId,
    String? ward,
    String? category,
    double? weightKg,
    String? missionId,
    DateTime? generatedAt,
    String? generatedBy,
    bool? isDisposed,
    DateTime? disposedAt,
  }) {
    return BagQrModel(
      bagId: bagId ?? this.bagId,
      ward: ward ?? this.ward,
      category: category ?? this.category,
      weightKg: weightKg ?? this.weightKg,
      missionId: missionId ?? this.missionId,
      generatedAt: generatedAt ?? this.generatedAt,
      generatedBy: generatedBy ?? this.generatedBy,
      isDisposed: isDisposed ?? this.isDisposed,
      disposedAt: disposedAt ?? this.disposedAt,
    );
  }
}
