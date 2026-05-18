import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/intelligence_card.dart';

class ApiService {
  static String _baseUrl = "https://speak-wildfire-sympathy.ngrok-free.dev";

  static String get baseUrl => _baseUrl;
  static set baseUrl(String v) {
    _baseUrl = v;
    SharedPreferences.getInstance().then((p) => p.setString('baseUrl', v));
  }

  static Future<void> loadSavedUrl() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString('baseUrl');
    if (saved != null && saved.isNotEmpty) _baseUrl = saved;
  }

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 120),
    headers: {"ngrok-skip-browser-warning": "true"},
  ));

  Future<bool> isOnline() async {
    try {
      final r = await _dio.get('$_baseUrl/');
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<IntelligenceCard> processLive({
    String? imagePath,
    String? audioPath,
    String? transcript,
    double? gpsLat,
    double? gpsLng,
    String responderId = "Unit_1",
  }) async {
    final formData = FormData();

    if (imagePath != null) {
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(imagePath, filename: 'photo.jpg'),
      ));
    }
    if (audioPath != null) {
      formData.files.add(MapEntry(
        'audio',
        await MultipartFile.fromFile(audioPath, filename: 'voice.wav'),
      ));
    }
    if (transcript != null) {
      formData.fields.add(MapEntry('transcript', transcript));
    }
    if (gpsLat != null) {
      formData.fields.add(MapEntry('gps_lat', gpsLat.toString()));
    }
    if (gpsLng != null) {
      formData.fields.add(MapEntry('gps_lng', gpsLng.toString()));
    }
    formData.fields.add(MapEntry('responder_id', responderId));

    final response = await _dio.post('$_baseUrl/process', data: formData);

    // DEBUG: Print the full response
    if (kDebugMode) {
      print("=" * 60);
      print("API RESPONSE FROM GEMMA:");
      print(const JsonEncoder.withIndent('  ').convert(response.data));
      print("=" * 60);
    }

    return IntelligenceCard.fromApiJson(response.data as Map<String, dynamic>);
  }

  Future<List<IntelligenceCard>> getAllObservations() async {
    final r = await _dio.get('$_baseUrl/observations');
    final obs = r.data['observations'] as List;
    return obs
        .map((j) => IntelligenceCard.fromApiJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> loadDemoCache() async {
    try {
      final str = await rootBundle.loadString('assets/demo_cache.json');
      final decoded = json.decode(str);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
