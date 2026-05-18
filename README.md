# DisasterWatch

> **Offline-capable AI disaster intelligence for first responders.**
> Powered by Gemma 4 multimodal reasoning.

[![Hackathon](https://img.shields.io/badge/Gemma_4_Good_Hackathon-2026-FFB020)](https://www.kaggle.com/competitions/gemma-4-good-hackathon)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Built with Gemma 4](https://img.shields.io/badge/Built_with-Gemma_4_E2B-FF6B6B)](https://huggingface.co/google/gemma-4-E2B-it)

---

## The Problem

When disaster strikes, first responders face three compounding crises:

1. **Information fragmentation.** Different teams arrive at different angles of the same incident, but there's no shared awareness.
2. **Infrastructure failure.** Cell towers fall during earthquakes. Cloud-based dispatch systems fail precisely when needed most.
3. **Incomplete observations.** Field reports captured in isolation are missing critical context. Real situational awareness requires fusing partial observations from multiple sources.

## The Solution

**DisasterWatch** transforms chaotic field observations into structured emergency intelligence using Gemma 4's multimodal reasoning, then aggregates observations from multiple responders into unified incident records.

### Core Innovation: Cross-Modal Field Intelligence

| Component | What it does |
|---|---|
| **Mobile capture** | Responders snap a photo and add a voice note from their phone |
| **Gemma 4 fusion** | Vision + text reasoning produces structured JSON intelligence (incident type, severity, hazards, response needs) |
| **Spatial-temporal aggregation** | Multiple responder observations within 200m / 30 min are merged into one event |
| **Command center** | Live tactical map shows merged events with corroboration boost |

### Why Gemma 4

This isn't Gemma 4 bolted onto a generic app. The architecture **requires** Gemma 4's specific capabilities:

- **Multimodal reasoning** — fuses image (visual evidence) + transcribed audio (responder context) in a single inference
- **On-device target deployment (E2B)** — designed for Ollama / llama.cpp on field-ruggedized phones where cloud is unavailable
- **JSON-faithful output** — produces validated structured intelligence cards, not free-form text
- **Apache 2.0 license** — deployable by NGOs and emergency agencies without legal friction

### The Wow Moment

When two responders capture the same incident from different angles, Gemma 4's outputs are aggregated by a custom spatial-temporal clustering algorithm. The merged event shows:

- ✓ **Corroborated by N responders** badge
- Boosted confidence from cross-source verification
- Unified hazard map (union of both responders' observations)
- Maximum severity (escalates to worst reported)

This demonstrates what we believe is the most under-explored Gemma 4 capability: **AI as a fusion layer across distributed human observers.**

## Quick Demo (90 seconds)

[Watch the demo video](YOUR_YOUTUBE_LINK_HERE)

[Download Android APK](releases/disasterwatch-v1.0.apk)

[Try the Command Center](https://speak-wildfire-sympathy.ngrok-free.dev/command)

---

## Architecture