import 'package:flutter/material.dart';
import '../theme/eoc_theme.dart';
import '../widgets/eoc_widgets.dart';
import 'capture_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = "INITIALIZING SYSTEMS";
  int _stage = 0;

  final List<String> _stages = [
    "INITIALIZING SYSTEMS",
    "LOADING GEMMA 4 MODULE",
    "ESTABLISHING SECURE LINK",
    "SYSTEM READY",
  ];

  @override
  void initState() {
    super.initState();
    _runBootSequence();
  }

  Future<void> _runBootSequence() async {
    for (int i = 0; i < _stages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _stage = i;
        _status = _stages[i];
      });
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CaptureScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EOC.graphite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header bar
              Row(
                children: [
                  Text("DW//SYS-001", style: EOC.label),
                  const Spacer(),
                  const PulseDot(color: EOC.amber, size: 6),
                  const SizedBox(width: 12),
                  Text("BOOTING", style: EOC.label.copyWith(color: EOC.amber)),
                ],
              ),
              const SizedBox(height: 80),

              // Center insignia
              Stack(
                alignment: Alignment.center,
                children: [
                  const RadarSweep(size: 160, color: EOC.amber),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: EOC.graphite,
                      border: Border.all(color: EOC.amber, width: 2),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: EOC.amber,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Text("DISASTERWATCH",
                  style: EOC.headerLarge.copyWith(fontSize: 26)),
              const SizedBox(height: 6),
              Text("AI-AUGMENTED FIELD INTELLIGENCE", style: EOC.label),

              const SizedBox(height: 60),

              // Boot log
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: EOC.panel(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < _stages.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Text(
                              i <= _stage ? "[OK] " : "[..] ",
                              style: EOC.mono.copyWith(
                                color: i <= _stage
                                    ? EOC.terrainGreen
                                    : EOC.textMuted,
                              ),
                            ),
                            Text(
                              _stages[i],
                              style: EOC.mono.copyWith(
                                color: i <= _stage
                                    ? EOC.textPrimary
                                    : EOC.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              Text(
                "POWERED BY GEMMA 4  //  ON-DEVICE INFERENCE",
                style: EOC.label.copyWith(color: EOC.textMuted),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
