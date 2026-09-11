class ManifestModel {
  final String manifestNumber; // e.g. BMW-2026-0891
  final String hospitalName;
  final String cpcbRegNumber;
  final DateTime generatedDate;
  final String authorizedOfficer;
  final String carrierFacility;
  final String vehicleRegNumber;
  final Map<String, double> categoryWeightsKg; // Sharps, Infectious, Plastic, Glassware, Unknown
  final double totalWeightKg;
  final int totalBags;
  final String digitalSignatureHash;
  final bool isDisposalConfirmed;
  final DateTime? confirmedAt;

  const ManifestModel({
    required this.manifestNumber,
    required this.hospitalName,
    required this.cpcbRegNumber,
    required this.generatedDate,
    required this.authorizedOfficer,
    required this.carrierFacility,
    required this.vehicleRegNumber,
    required this.categoryWeightsKg,
    required this.totalWeightKg,
    required this.totalBags,
    required this.digitalSignatureHash,
    this.isDisposalConfirmed = true,
    this.confirmedAt,
  });

  factory ManifestModel.mockDefault() {
    final now = DateTime.now();
    return ManifestModel(
      manifestNumber: 'BMW-2026-0941',
      hospitalName: 'Apollo Clinical Health Systems - Ward Complex 4',
      cpcbRegNumber: 'CPCB-BMW-2026/TN/7721',
      generatedDate: now,
      authorizedOfficer: 'Dr. Sarah Jenkins (Infection Control)',
      carrierFacility: 'EcoMed Bio-Hazard Remediation Facility Inc.',
      vehicleRegNumber: 'KA-04-MB-8821',
      categoryWeightsKg: {
        'Sharps': 14.8,
        'Infectious': 32.5,
        'Plastic': 18.2,
        'Glassware': 9.4,
        'Unknown/Others': 4.1,
      },
      totalWeightKg: 79.0,
      totalBags: 38,
      digitalSignatureHash: 'SHA256:8f9a2e3b1c5d7e6f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f',
      isDisposalConfirmed: true,
      confirmedAt: now.subtract(const Duration(minutes: 45)),
    );
  }

  factory ManifestModel.fromJson(Map<String, dynamic> json) {
    return ManifestModel(
      manifestNumber: json['manifestNumber'] as String,
      hospitalName: json['hospitalName'] as String,
      cpcbRegNumber: json['cpcbRegNumber'] as String,
      generatedDate: DateTime.parse(json['generatedDate'] as String),
      authorizedOfficer: json['authorizedOfficer'] as String,
      carrierFacility: json['carrierFacility'] as String,
      vehicleRegNumber: json['vehicleRegNumber'] as String,
      categoryWeightsKg: Map<String, double>.from(json['categoryWeightsKg'] as Map),
      totalWeightKg: (json['totalWeightKg'] as num).toDouble(),
      totalBags: json['totalBags'] as int,
      digitalSignatureHash: json['digitalSignatureHash'] as String,
      isDisposalConfirmed: json['isDisposalConfirmed'] as bool? ?? true,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manifestNumber': manifestNumber,
      'hospitalName': hospitalName,
      'cpcbRegNumber': cpcbRegNumber,
      'generatedDate': generatedDate.toIso8601String(),
      'authorizedOfficer': authorizedOfficer,
      'carrierFacility': carrierFacility,
      'vehicleRegNumber': vehicleRegNumber,
      'categoryWeightsKg': categoryWeightsKg,
      'totalWeightKg': totalWeightKg,
      'totalBags': totalBags,
      'digitalSignatureHash': digitalSignatureHash,
      'isDisposalConfirmed': isDisposalConfirmed,
      if (confirmedAt != null) 'confirmedAt': confirmedAt!.toIso8601String(),
    };
  }
}
