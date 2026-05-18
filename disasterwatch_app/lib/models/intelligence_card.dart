import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

  // Defensive string parser - handles nulls, numbers, etc.
  static String? _asString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    return v.toString();
  }

  // Defensive list parser
  static List<String> _asStringList(dynamic v) {
    if (v == null) return [];
    if (v is List) {
      return v.where((e) => e != null).map((e) => e.toString()).toList();
    }
    return [];
  }

  // Defensive double parser
  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  factory IntelligenceCard.fromApiJson(Map<String, dynamic> json) {
    // Defensive: backend may nest under 'intelligence' or return flat
    final intel =
        json.containsKey('intelligence') && json['intelligence'] is Map
            ? Map<String, dynamic>.from(json['intelligence'] as Map)
            : json;

    final obs = json.containsKey('observation') && json['observation'] is Map
        ? Map<String, dynamic>.from(json['observation'] as Map)
        : <String, dynamic>{};

    if (kDebugMode) {
      print("Parsing intelligence: ${intel.keys.toList()}");
      print("Parsing observation: ${obs.keys.toList()}");
    }

    return IntelligenceCard(
      incidentType: _asString(intel['incident_type']) ?? 'unknown',
      severity: _asString(intel['severity']) ?? 'medium',
      hazards: _asStringList(intel['hazards']),
      responseNeeds: _asStringList(intel['response_needs']),
      affectedEstimate: _asString(intel['affected_estimate']),
      locationDescription: _asString(intel['location_description']),
      visualDescription: _asString(intel['visual_description']),
      confidence: _asDouble(intel['confidence']) ?? 0.5,
      reasoning: _asString(intel['reasoning']),
      responderId: _asString(obs['responder_id']) ?? 'Unit_1',
      timestamp:
          _asString(obs['timestamp']) ?? DateTime.now().toIso8601String(),
      gpsLat: _asDouble(obs['gps_lat']),
      gpsLng: _asDouble(obs['gps_lng']),
      processingTimeMs: (json['processing_time_ms'] as int?) ?? 0,
      fromCache: false,
    );
  }

  factory IntelligenceCard.fromCacheJson(Map<String, dynamic> json) {
    final intel =
        json.containsKey('intelligence') && json['intelligence'] is Map
            ? Map<String, dynamic>.from(json['intelligence'] as Map)
            : <String, dynamic>{};

    return IntelligenceCard(
      incidentType: _asString(intel['incident_type']) ?? 'unknown',
      severity: _asString(intel['severity']) ?? 'medium',
      hazards: _asStringList(intel['hazards']),
      responseNeeds: _asStringList(intel['response_needs']),
      affectedEstimate: _asString(intel['affected_estimate']),
      locationDescription: _asString(intel['location_description']),
      visualDescription: _asString(intel['visual_description']),
      confidence: _asDouble(intel['confidence']) ?? 0.5,
      reasoning: _asString(intel['reasoning']),
      responderId: _asString(json['responder_id']) ?? 'Unit_1',
      timestamp: DateTime.now().toIso8601String(),
      gpsLat: _asDouble(json['gps_lat']),
      gpsLng: _asDouble(json['gps_lng']),
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

  String get displayType {
    if (incidentType.isEmpty) return 'Unknown';
    return incidentType
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

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

  // For debugging
  @override
  String toString() {
    return 'IntelligenceCard(type=$incidentType, severity=$severity, '
        'hazards=${hazards.length}, needs=${responseNeeds.length}, '
        'visual=${visualDescription != null}, '
        'location=${locationDescription != null}, '
        'affected=${affectedEstimate != null}, '
        'reasoning=${reasoning != null})';
  }
}
