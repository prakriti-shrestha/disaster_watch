import 'package:flutter/material.dart';
import '../theme/eoc_theme.dart';

class IntelligenceCard {
  final String incidentType;
  final String severity;
  final List<String> hazards;
  final List<String> responseNeeds;
  final String? affectedEstimate;
  final String? locationDescription;
  final String? visualDescription;
  final double confidence;
  final String? reasoning;
  final String responderId;
  final String timestamp;
  final double? gpsLat;
  final double? gpsLng;
  final int processingTimeMs;
  final bool fromCache;

  IntelligenceCard({
    required this.incidentType,
    required this.severity,
    required this.hazards,
    required this.responseNeeds,
    this.affectedEstimate,
    this.locationDescription,
    this.visualDescription,
    required this.confidence,
    this.reasoning,
    required this.responderId,
    required this.timestamp,
    this.gpsLat,
    this.gpsLng,
    required this.processingTimeMs,
    this.fromCache = false,
  });

  factory IntelligenceCard.fromApiJson(Map<String, dynamic> json) {
    final intel = (json['intelligence'] as Map<String, dynamic>?) ?? json;
    final obs = (json['observation'] as Map<String, dynamic>?) ?? {};
    return IntelligenceCard(
      incidentType: intel['incident_type']?.toString() ?? 'unknown',
      severity: intel['severity']?.toString() ?? 'medium',
      hazards: List<String>.from(intel['hazards'] ?? []),
      responseNeeds: List<String>.from(intel['response_needs'] ?? []),
      affectedEstimate: intel['affected_estimate']?.toString(),
      locationDescription: intel['location_description']?.toString(),
      visualDescription: intel['visual_description']?.toString(),
      confidence: (intel['confidence'] as num?)?.toDouble() ?? 0.5,
      reasoning: intel['reasoning']?.toString(),
      responderId: obs['responder_id']?.toString() ?? 'Unit_1',
      timestamp:
          obs['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      gpsLat: (obs['gps_lat'] as num?)?.toDouble(),
      gpsLng: (obs['gps_lng'] as num?)?.toDouble(),
      processingTimeMs: (json['processing_time_ms'] as int?) ?? 0,
      fromCache: false,
    );
  }

  factory IntelligenceCard.fromCacheJson(Map<String, dynamic> json) {
    final intel = (json['intelligence'] as Map<String, dynamic>?) ?? {};
    return IntelligenceCard(
      incidentType: intel['incident_type']?.toString() ?? 'unknown',
      severity: intel['severity']?.toString() ?? 'medium',
      hazards: List<String>.from(intel['hazards'] ?? []),
      responseNeeds: List<String>.from(intel['response_needs'] ?? []),
      affectedEstimate: intel['affected_estimate']?.toString(),
      locationDescription: intel['location_description']?.toString(),
      visualDescription: intel['visual_description']?.toString(),
      confidence: (intel['confidence'] as num?)?.toDouble() ?? 0.5,
      reasoning: intel['reasoning']?.toString(),
      responderId: json['responder_id']?.toString() ?? 'Unit_1',
      timestamp: DateTime.now().toIso8601String(),
      gpsLat: (json['gps_lat'] as num?)?.toDouble(),
      gpsLng: (json['gps_lng'] as num?)?.toDouble(),
      processingTimeMs: (json['processing_time_ms'] as int?) ?? 25000,
      fromCache: true,
    );
  }

  Color get severityColor => EOC.severityColor(severity);
  Color get severityGlow => EOC.severityGlow(severity);

  String get incidentIcon {
    switch (incidentType) {
      case 'fire':
        return '🔥';
      case 'flood':
        return '🌊';
      case 'earthquake':
        return '🌍';
      case 'structural_collapse':
        return '🏚️';
      case 'vehicle_accident':
        return '🚗';
      case 'gas_leak':
        return '⚠️';
      case 'hazmat':
        return '☣️';
      case 'medical_emergency':
        return '🚑';
      case 'landslide':
        return '⛰️';
      default:
        return '❓';
    }
  }

  String get displayType => incidentType
      .split('_')
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  String get severityCode {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'SEV-1';
      case 'high':
        return 'SEV-2';
      case 'medium':
        return 'SEV-3';
      case 'low':
        return 'SEV-4';
      default:
        return 'SEV-?';
    }
  }
}
