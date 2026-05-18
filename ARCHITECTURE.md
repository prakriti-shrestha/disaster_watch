# DisasterWatch Architecture

## System Overview

DisasterWatch operates as a three-tier architecture:

1. **Edge clients** — mobile devices held by responders
2. **Inference layer** — Gemma 4 + Whisper + aggregator (can run on-device, cloud, or local server)
3. **Command center** — web dashboard for incident commanders

In the demo configuration, the inference layer runs on Google Colab (free T4 GPU). The architecture is designed so this layer can be swapped to Ollama-on-phone, on-prem servers, or commercial cloud without changes elsewhere.

![Architecture](docs/arch.jpg)

## Inference Pipeline

### 1. Capture
Mobile app captures three signals:
- **Image** (1280×1280 max, JPEG compressed)
- **Voice/text** (either Whisper-transcribed audio or direct text input)
- **GPS coordinates** (latitude/longitude/timestamp)

### 2. Multimodal Fusion
A single Gemma 4 inference combines image + transcript:

```python
prompt = f"""
The responder provided a photo (attached) and a voice note: "{transcript}"

CROSS-REFERENCE BOTH SOURCES. The image shows what is visible.
The voice note adds context: location, urgency, what's not visible.

Output unified intelligence card as JSON...
"""

response = model.generate(
    image=image,
    text=prompt,
    max_new_tokens=400,
    temperature=0.1
)
```

The model performs:
- **Vision classification** — incident type, severity from visible damage
- **Text extraction** — affected count, location names, urgency signals
- **Cross-modal reasoning** — e.g., voice says "trapped people" not visible → boosts search_rescue need confidence
- **Confidence calibration** — lowered when voice and image contradict

### 3. Validation
Output is validated against a Pydantic schema:
- Incident type ∈ controlled vocabulary
- Severity ∈ {low, medium, high, critical}
- Hazards/needs ∈ controlled vocabularies
- Confidence ∈ [0, 1]

## Aggregation Algorithm

When multiple observations exist, the aggregator clusters them into events:
For each new observation O_new:
For each existing cluster C:
if any(same_event(O_new, O_other) for O_other in C):
C.append(O_new)
break
else:
clusters.append(new_cluster(O_new))
same_event(o1, o2):
- incident_type matches
- haversine_distance(o1.gps, o2.gps) <= 200m
- abs(o1.timestamp - o2.timestamp) <= 30 minutes

When a cluster contains >1 observations, merge logic:
- **Severity** = max() over severity order
- **Hazards** = set union
- **Response needs** = set union
- **GPS center** = arithmetic mean of coordinates
- **Confidence** = mean + corroboration_boost = min(0.2, 0.05 × (n−1))

## Performance

Measured on Colab T4 GPU:
- Whisper transcription: ~2 sec (CPU)
- Gemma 4 multimodal inference: ~25 sec (T4, bf16)
- JSON parse rate: 3/3 in test corpus
- End-to-end mobile→display: ~28 sec live

For target on-device deployment via Ollama Q4 quantization, expected latency: 5-8 sec on Pixel 7-class hardware.

## Failure Modes

| Failure | Mitigation |
|---|---|
| Whisper mis-transcribes critical word | Confidence reduced; raw audio preserved |
| Gemma outputs invalid JSON | Pydantic validation + auto-retry + fallback to "unknown" |
| GPS unavailable indoors | Voice-described location accepted; aggregation uses type+time only |
| Backend offline | Mobile app loads cached demo outputs (graceful degradation) |
| Duplicate same-named responders | Responder ID is user-entered; production would bind to device cert |

## Scalability Path

Beyond the prototype:
1. **On-device inference** — port to Ollama / llama.cpp for true offline operation
2. **Multi-device mesh** — replace HTTP with libp2p or Bluetooth mesh for infrastructure-free operation
3. **Model distillation** — fine-tune Gemma 4 E2B on disaster-specific corpora via Unsloth
4. **Multilingual** — extend Whisper config for 20+ international response languages
5. **CAD integration** — output intelligence to existing Computer-Aided Dispatch systems