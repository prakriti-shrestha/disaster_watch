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

  // === DEFENSIVE PARSERS ===

  static String? _asString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s == 'null') return null;
    return s;
  }

  static List<String> _asStringList(dynamic v) {
    if (v == null) return [];
    if (v is List) {
      return v
          .where((e) => e != null)
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (v is String) {
      return v
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int _asInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  // Recursively convert any Map to Map<String, dynamic>
  static Map<String, dynamic> _safeMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) {
      return v.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  factory IntelligenceCard.fromApiJson(Map<String, dynamic> rawJson) {
    if (kDebugMode) {
      print("=" * 60);
      print("RAW API JSON TYPE: ${rawJson.runtimeType}");
      print("RAW KEYS: ${rawJson.keys.toList()}");
      print("Has 'intelligence': ${rawJson.containsKey('intelligence')}");
      print("Has 'observation': ${rawJson.containsKey('observation')}");
      if (rawJson.containsKey('intelligence')) {
        print("intelligence type: ${rawJson['intelligence'].runtimeType}");
      }
      print("=" * 60);
    }

    try {
      final json = _safeMap(rawJson);

      // Get nested 'intelligence' map, or use root if flat
      final Map<String, dynamic> intel = json.containsKey('intelligence')
          ? _safeMap(json['intelligence'])
          : json;

      // Get nested 'observation' map
      final Map<String, dynamic> obs = json.containsKey('observation')
          ? _safeMap(json['observation'])
          : <String, dynamic>{};

      if (kDebugMode) {
        print("Parsed intelligence keys: ${intel.keys.toList()}");
        print("Parsed observation keys: ${obs.keys.toList()}");
        print("incident_type raw: ${intel['incident_type']}");
        print("severity raw: ${intel['severity']}");
        print(
            "hazards raw: ${intel['hazards']} (${intel['hazards']?.runtimeType})");
        print("visual_description raw: ${intel['visual_description']}");
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
        processingTimeMs: _asInt(json['processing_time_ms']),
        fromCache: false,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ PARSE ERROR: $e");
        print("Stack: $stack");
        print("Raw input was: $rawJson");
      }
      // Return a minimal card so we don't crash
      return IntelligenceCard(
        incidentType: 'unknown',
        severity: 'medium',
        hazards: [],
        responseNeeds: [],
        confidence: 0.5,
        responderId: 'parse_error',
        timestamp: DateTime.now().toIso8601String(),
        processingTimeMs: 0,
        fromCache: false,
        reasoning: 'PARSE ERROR: ${e.toString()}',
      );
    }
  }

  factory IntelligenceCard.fromCacheJson(Map<String, dynamic> rawJson) {
    try {
      final json = _safeMap(rawJson);
      final Map<String, dynamic> intel = json.containsKey('intelligence')
          ? _safeMap(json['intelligence'])
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
        processingTimeMs: _asInt(json['processing_time_ms'], 25000),
        fromCache: true,
      );
    } catch (e) {
      if (kDebugMode) print("Cache parse error: $e");
      return IntelligenceCard(
        incidentType: 'unknown',
        severity: 'medium',
        hazards: [],
        responseNeeds: [],
        confidence: 0.5,
        responderId: 'cache_error',
        timestamp: DateTime.now().toIso8601String(),
        processingTimeMs: 0,
        fromCache: true,
      );
    }
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

  @override
  String toString() {
    return 'IntelligenceCard(type=$incidentType, severity=$severity, '
        'hazards=${hazards.length}, needs=${responseNeeds.length}, '
        'visual=${visualDescription != null ? "${visualDescription!.length}chars" : "null"}, '
        'location=${locationDescription != null ? "${locationDescription!.length}chars" : "null"}, '
        'affected=${affectedEstimate ?? "null"}, '
        'reasoning=${reasoning != null ? "${reasoning!.length}chars" : "null"})';
  }
}
