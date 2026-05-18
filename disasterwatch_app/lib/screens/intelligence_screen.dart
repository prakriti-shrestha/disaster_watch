import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/intelligence_card.dart';
import '../theme/eoc_theme.dart';
import '../widgets/eoc_widgets.dart';

class IntelligenceScreen extends StatelessWidget {
  final IntelligenceCard card;
  const IntelligenceScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    // DEBUG: print what we received
    if (kDebugMode) {
      print("=" * 60);
      print("INTEL SCREEN RECEIVED:");
      print(card.toString());
      print("  visualDescription: ${card.visualDescription}");
      print("  locationDescription: ${card.locationDescription}");
      print("  affectedEstimate: ${card.affectedEstimate}");
      print("  hazards: ${card.hazards}");
      print("  responseNeeds: ${card.responseNeeds}");
      print("  reasoning: ${card.reasoning}");
      print("=" * 60);
    }

    final sevColor = card.severityColor;
    return Scaffold(
      backgroundColor: EOC.graphite,
      body: SafeArea(
        child: Column(
          children: [
            // === TOP BAR ===
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: EOC.charcoal,
                border: Border(
                  bottom: const BorderSide(color: EOC.border),
                  left: BorderSide(color: sevColor, width: 3),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: EOC.textPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "INTEL REPORT // ${card.severityCode}",
                    style: EOC.headerMedium.copyWith(fontSize: 13),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    color: sevColor,
                    child: Text(
                      card.severity.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: EOC.monoFont,
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // === INCIDENT HEADER ===
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: EOC.charcoal,
                      border: Border.all(color: sevColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: sevColor.withOpacity(0.2),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectorLabel(
                          text: "INCIDENT CLASSIFICATION",
                          color: sevColor,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              card.incidentIcon,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.displayType.toUpperCase(),
                                    style: EOC.headerLarge.copyWith(
                                      fontSize: 18,
                                      color: sevColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${card.severityCode} // ${card.severity.toUpperCase()}",
                                    style: EOC.mono,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // === CONFIDENCE METER ===
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: EOC.panel(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SectorLabel(text: "MODEL CONFIDENCE"),
                            const Spacer(),
                            Text(
                              "${(card.confidence * 100).toInt()}%",
                              style: TextStyle(
                                fontFamily: EOC.monoFont,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: card.confidence > 0.7
                                    ? EOC.terrainGreen
                                    : EOC.hazardYellow,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRect(
                          child: LinearProgressIndicator(
                            value: card.confidence,
                            backgroundColor: EOC.steel,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              card.confidence > 0.7
                                  ? EOC.terrainGreen
                                  : EOC.hazardYellow,
                            ),
                            minHeight: 6,
                          ),
                        ),
                        if (card.reasoning != null &&
                            card.reasoning!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: EOC.graphite,
                              border: Border(
                                  left: BorderSide(color: EOC.cyan, width: 2)),
                            ),
                            child: Text(
                              "// ${card.reasoning}",
                              style: EOC.body.copyWith(
                                fontSize: 12,
                                color: EOC.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // === SCENE INTELLIGENCE - WITH DEFENSIVE CHECKS ===
                  if (card.visualDescription != null &&
                      card.visualDescription!.isNotEmpty)
                    _DataPanel(
                      label: "VISUAL ANALYSIS",
                      content: card.visualDescription!,
                      icon: Icons.visibility_outlined,
                      accent: EOC.cyan,
                    ),

                  if (card.locationDescription != null &&
                      card.locationDescription!.isNotEmpty)
                    _DataPanel(
                      label: "LOCATION DATA",
                      content: card.locationDescription!,
                      icon: Icons.location_on_outlined,
                      accent: EOC.terrainGreen,
                    ),

                  if (card.affectedEstimate != null &&
                      card.affectedEstimate!.isNotEmpty)
                    _DataPanel(
                      label: "CASUALTY ESTIMATE",
                      content: card.affectedEstimate!,
                      icon: Icons.people_outline,
                      accent: EOC.amber,
                    ),

                  if (card.hazards.isNotEmpty)
                    _ChipPanel(
                      label: "ACTIVE HAZARDS",
                      items: card.hazards,
                      accent: EOC.critical,
                      icon: Icons.warning_amber_rounded,
                    ),

                  if (card.responseNeeds.isNotEmpty)
                    _ChipPanel(
                      label: "RESPONSE PROTOCOL",
                      items: card.responseNeeds,
                      accent: EOC.amber,
                      icon: Icons.local_fire_department_outlined,
                    ),

                  // FALLBACK: if we have nothing else, show debug info
                  if (card.visualDescription == null &&
                      card.locationDescription == null &&
                      card.affectedEstimate == null &&
                      card.hazards.isEmpty &&
                      card.responseNeeds.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: EOC.charcoal,
                        border: Border.all(color: EOC.hazardYellow),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning,
                                  color: EOC.hazardYellow, size: 16),
                              const SizedBox(width: 8),
                              Text("PARSE WARNING",
                                  style: EOC.label
                                      .copyWith(color: EOC.hazardYellow)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Intelligence data was received but no fields parsed. "
                            "Check the debug console for the raw API response.",
                            style: EOC.body.copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Raw fields detected:\n"
                            "- incident_type: ${card.incidentType}\n"
                            "- severity: ${card.severity}\n"
                            "- confidence: ${card.confidence}",
                            style: EOC.mono.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                  // === METADATA FOOTER ===
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: EOC.panel(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectorLabel(text: "TELEMETRY"),
                        const SizedBox(height: 10),
                        _meta("RESPONDER", card.responderId, EOC.cyan),
                        _meta(
                            "PROCESSED",
                            "${card.processingTimeMs}ms via Gemma 4",
                            EOC.amber),
                        if (card.gpsLat != null)
                          _meta(
                            "COORDINATES",
                            "${card.gpsLat!.toStringAsFixed(5)}°, ${card.gpsLng!.toStringAsFixed(5)}°",
                            EOC.terrainGreen,
                          ),
                        _meta(
                          "MODE",
                          card.fromCache ? "DEMO // CACHED" : "LIVE // GEMMA 4",
                          card.fromCache ? EOC.hazardYellow : EOC.terrainGreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // === BOTTOM ACTION ===
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: EOC.charcoal,
                border: Border(top: BorderSide(color: EOC.border)),
              ),
              child: PrimaryActionButton(
                onPressed: () => Navigator.pop(context),
                icon: Icons.arrow_forward,
                label: "Next Observation",
                color: EOC.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: EOC.label.copyWith(fontSize: 10)),
          ),
          Expanded(
            child: Text(
              value,
              style: EOC.body.copyWith(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataPanel extends StatelessWidget {
  final String label;
  final String content;
  final IconData icon;
  final Color accent;
  const _DataPanel({
    required this.label,
    required this.content,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EOC.charcoal,
        border: Border(
          left: BorderSide(color: accent, width: 2),
          top: const BorderSide(color: EOC.border),
          right: const BorderSide(color: EOC.border),
          bottom: const BorderSide(color: EOC.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: accent),
              const SizedBox(width: 6),
              Text(label, style: EOC.label.copyWith(color: accent)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: EOC.body),
        ],
      ),
    );
  }
}

class _ChipPanel extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color accent;
  final IconData icon;
  const _ChipPanel({
    required this.label,
    required this.items,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EOC.charcoal,
        border: Border(
          left: BorderSide(color: accent, width: 2),
          top: const BorderSide(color: EOC.border),
          right: const BorderSide(color: EOC.border),
          bottom: const BorderSide(color: EOC.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: accent),
              const SizedBox(width: 6),
              Text(label, style: EOC.label.copyWith(color: accent)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        border: Border.all(color: accent.withOpacity(0.4)),
                      ),
                      child: Text(
                        item.toString().toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(
                          fontFamily: EOC.monoFont,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: accent,
                          letterSpacing: 1,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
