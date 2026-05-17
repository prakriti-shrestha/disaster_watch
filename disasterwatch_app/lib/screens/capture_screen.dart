import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:io';
import '../services/api_service.dart';
import '../models/intelligence_card.dart';
import '../theme/eoc_theme.dart';
import '../widgets/eoc_widgets.dart';
import 'intelligence_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _transcriptController = TextEditingController();

  File? _imageFile;
  bool _isProcessing = false;
  bool _isOnline = false;
  bool _useDemoMode = false;
  String _responderId = "UNIT-01";
  Position? _gps;
  String _status = "INITIALIZING";
  List<Map<String, dynamic>> _demoCache = [];
  int _demoIdx = 0;
  Timer? _statusTimer;
  int _msgIdx = 0;

  final List<String> _processingMessages = [
    "ANALYZING SCENE WITH GEMMA 4",
    "CROSS-REFERENCING MODALITIES",
    "STRUCTURING INTELLIGENCE OUTPUT",
    "VALIDATING JSON SCHEMA",
  ];

  // Quick voice note templates (no recording needed)
  final List<String> _quickTemplates = [
    "Three-story collapse on north side. Estimated 15-20 trapped. Structure unstable.",
    "Building fire on east wing. Heavy smoke. Two civilians evacuated, one missing.",
    "Flood at intersection of Park and Fifth. Waist-deep water. Three vehicles stranded.",
    "Gas leak suspected at apartment complex. Strong odor. Two buildings evacuated.",
    "Multi-vehicle accident on highway. Three vehicles involved. Two injured, one critical.",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusTimer?.cancel();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _isOnline = await _api.isOnline();
    try {
      _demoCache = await _api.loadDemoCache();
    } catch (_) {}
    try {
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      if (p != LocationPermission.denied &&
          p != LocationPermission.deniedForever) {
        _gps = await Geolocator.getCurrentPosition();
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _status = _isOnline
          ? "LINK ESTABLISHED // GEMMA 4 ONLINE"
          : "OFFLINE // CACHE MODE ACTIVE";
      _useDemoMode = !_isOnline;
    });
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (photo != null && mounted) {
        setState(() {
          _imageFile = File(photo.path);
          _status = "PHOTO CAPTURED // ADD VOICE NOTE";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _status = "CAMERA ERROR");
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (photo != null && mounted) {
        setState(() {
          _imageFile = File(photo.path);
          _status = "PHOTO LOADED // ADD VOICE NOTE";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _status = "GALLERY ERROR");
    }
  }

  void _useTemplate(String template) {
    setState(() {
      _transcriptController.text = template;
      _status = "VOICE NOTE LOADED // READY TO ANALYZE";
    });
  }

  Future<void> _analyze() async {
    final transcript = _transcriptController.text.trim();
    if (_imageFile == null && transcript.isEmpty && !_useDemoMode) {
      setState(() => _status = "ERROR: NO CAPTURE DATA AVAILABLE");
      return;
    }

    setState(() {
      _isProcessing = true;
      _msgIdx = 0;
      _status = _processingMessages[0];
    });

    _statusTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (mounted && _isProcessing) {
        _msgIdx = (_msgIdx + 1) % _processingMessages.length;
        setState(() => _status = _processingMessages[_msgIdx]);
      }
    });

    try {
      IntelligenceCard card;
      if (_useDemoMode && _demoCache.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 3));
        final scenario = _demoCache[_demoIdx % _demoCache.length];
        card = IntelligenceCard.fromCacheJson(scenario);
        _demoIdx++;
      } else {
        card = await _api.processLive(
          imagePath: _imageFile?.path,
          transcript: transcript.isEmpty ? null : transcript,
          gpsLat: _gps?.latitude,
          gpsLng: _gps?.longitude,
          responderId: _responderId,
        );
      }
      _statusTimer?.cancel();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => IntelligenceScreen(card: card)),
      ).then((_) => _reset());
    } catch (e) {
      _statusTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _status = "ANALYSIS FAILED // ${e.toString().split(':').first}";
        _isProcessing = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _imageFile = null;
      _transcriptController.clear();
      _isProcessing = false;
      _status =
          _isOnline ? "LINK ESTABLISHED // READY" : "OFFLINE // CACHE MODE";
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (ctx) {
        final unitCtrl = TextEditingController(text: _responderId);
        final urlCtrl = TextEditingController(text: ApiService.baseUrl);
        return Dialog(
          backgroundColor: EOC.charcoal,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: EOC.borderActive),
            borderRadius: BorderRadius.zero,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectorLabel(text: "SYSTEM CONFIG"),
                const SizedBox(height: 16),
                Text("UNIT IDENTIFIER", style: EOC.label),
                const SizedBox(height: 4),
                TextField(
                  controller: unitCtrl,
                  style: EOC.body.copyWith(color: EOC.amber),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: EOC.border),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: EOC.amber),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text("BACKEND ENDPOINT (NGROK)", style: EOC.label),
                const SizedBox(height: 4),
                TextField(
                  controller: urlCtrl,
                  style: EOC.body.copyWith(fontSize: 11),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: EOC.border),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: EOC.amber),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text("CANCEL", style: EOC.label),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        setState(() => _responderId = unitCtrl.text.trim());
                        ApiService.baseUrl = urlCtrl.text.trim();
                        Navigator.pop(ctx);
                        await _init();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        color: EOC.amber,
                        child: Text(
                          "SAVE & SYNC",
                          style: EOC.label
                              .copyWith(color: Colors.black, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTemplates() {
    showModalBottomSheet(
      context: context,
      backgroundColor: EOC.charcoal,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: EOC.borderActive),
        borderRadius: BorderRadius.zero,
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectorLabel(text: "QUICK TEMPLATES // VOICE NOTES"),
            const SizedBox(height: 12),
            ..._quickTemplates.map((t) => InkWell(
                  onTap: () {
                    _useTemplate(t);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EOC.steel,
                      border: Border.all(color: EOC.border),
                    ),
                    child: Text(t, style: EOC.body.copyWith(fontSize: 12)),
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessing,
      child: Scaffold(
        backgroundColor: EOC.graphite,
        body: SafeArea(
          child: Column(
            children: [
              // === TOP BAR ===
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: EOC.charcoal,
                  border: Border(bottom: BorderSide(color: EOC.border)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      color: EOC.amber,
                      child: const Text(
                        "DW",
                        style: TextStyle(
                          fontFamily: EOC.monoFont,
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("DISASTERWATCH",
                        style: EOC.headerMedium.copyWith(fontSize: 13)),
                    const Spacer(),
                    PulseDot(
                      color: _isOnline ? EOC.terrainGreen : EOC.critical,
                      size: 6,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOnline ? "ONLINE" : "OFFLINE",
                      style: EOC.label.copyWith(
                        color: _isOnline ? EOC.terrainGreen : EOC.critical,
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _showSettings,
                      child: const Icon(Icons.tune,
                          color: EOC.textSecondary, size: 18),
                    ),
                  ],
                ),
              ),

              // === HUD STATS ===
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: EOC.graphite,
                child: Row(
                  children: [
                    Expanded(
                      child: HudStat(
                        label: "UNIT ID",
                        value: _responderId,
                        color: EOC.cyan,
                        icon: Icons.shield_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: HudStat(
                        label: "GPS LOCK",
                        value: _gps != null
                            ? "${_gps!.latitude.toStringAsFixed(3)}°"
                            : "N/A",
                        color: _gps != null ? EOC.terrainGreen : EOC.textMuted,
                        icon: Icons.gps_fixed,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: HudStat(
                        label: "MODE",
                        value: _useDemoMode ? "CACHED" : "LIVE",
                        color:
                            _useDemoMode ? EOC.hazardYellow : EOC.terrainGreen,
                        icon: Icons.bolt,
                      ),
                    ),
                  ],
                ),
              ),

              // === STATUS BAR ===
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: EOC.charcoal,
                  border: Border(
                    top: const BorderSide(color: EOC.border),
                    bottom: const BorderSide(color: EOC.border),
                    left: BorderSide(
                      color: _isProcessing ? EOC.amber : EOC.cyan,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (_isProcessing) ...[
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: EOC.amber,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        "> $_status",
                        style: EOC.code.copyWith(
                          color: _isProcessing ? EOC.amber : EOC.cyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // === MAIN CONTENT ===
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Photo capture
                      const SectorLabel(text: "SCENE CAPTURE // PHOTO"),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _isProcessing ? null : _capturePhoto,
                        child: Container(
                          width: double.infinity,
                          height: 240,
                          decoration: BoxDecoration(
                            color: EOC.charcoal,
                            border: Border.all(
                              color: _imageFile != null ? EOC.cyan : EOC.border,
                            ),
                          ),
                          child: _imageFile != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(_imageFile!, fit: BoxFit.cover),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        color: EOC.cyan,
                                        child: const Text(
                                          "CAPTURED",
                                          style: TextStyle(
                                            fontFamily: EOC.monoFont,
                                            color: Colors.black,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 56,
                                      color: EOC.textMuted,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      "TAP TO CAPTURE SCENE",
                                      style: TextStyle(
                                        fontFamily: EOC.monoFont,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: EOC.textMuted,
                                        letterSpacing: 1.8,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Gallery option
                      InkWell(
                        onTap: _isProcessing ? null : _pickFromGallery,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Text(
                            "OR TAP HERE FOR GALLERY",
                            style: EOC.label
                                .copyWith(color: EOC.cyan, fontSize: 9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Voice note (text input)
                      Row(
                        children: [
                          const Expanded(
                              child: SectorLabel(text: "VOICE NOTE // TEXT")),
                          InkWell(
                            onTap: _isProcessing ? null : _showTemplates,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: EOC.cyan),
                              ),
                              child: Text(
                                "TEMPLATES",
                                style: EOC.label
                                    .copyWith(color: EOC.cyan, fontSize: 9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: EOC.charcoal,
                          border: Border.all(
                            color: _transcriptController.text.isNotEmpty
                                ? EOC.cyan
                                : EOC.border,
                          ),
                        ),
                        child: TextField(
                          controller: _transcriptController,
                          enabled: !_isProcessing,
                          maxLines: 4,
                          style: EOC.body,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText:
                                "TYPE RESPONDER OBSERVATION...\nor use TEMPLATES button",
                            hintStyle: TextStyle(
                              fontFamily: EOC.monoFont,
                              fontSize: 11,
                              color: EOC.textMuted,
                              letterSpacing: 1,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === PRIMARY ACTION ===
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: PrimaryActionButton(
                  onPressed: _isProcessing ? null : _analyze,
                  icon: Icons.analytics_outlined,
                  label: _isProcessing
                      ? "PROCESSING"
                      : _useDemoMode
                          ? "Analyze [CACHED]"
                          : "Analyze [GEMMA 4]",
                  color: _useDemoMode ? EOC.hazardYellow : EOC.amber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
