# Honest Limitations and Ethical Considerations

This document is a transparent acknowledgement of what DisasterWatch is and is not. We believe radical transparency is essential when proposing AI tools for high-stakes domains.

## What This Is

A 5-day research prototype demonstrating **technical feasibility** of multimodal AI fusion for distributed field intelligence. It demonstrates that:

1. Gemma 4 can produce structured, validated JSON disaster intelligence from multimodal input
2. Cross-observation aggregation can boost confidence through corroboration
3. A mobile-first capture flow is realistic for field operators

## What This Is Not

- **Not a production system.** No emergency responder should depend on this prototype in a real incident.
- **Not field-tested.** No real responders have used this in real disasters.
- **Not validated by domain experts.** The output vocabulary (hazards, response needs) was designed by the developer, not by emergency management professionals.
- **Not a replacement for human judgment.** AI outputs must be verified by trained responders.

## Specific Risks We're Aware Of

### False Confidence
Gemma 4 produces confidence scores, but these are calibration artifacts of the model, not statistical guarantees. A 90% confidence does not mean 90% probability of being correct. Real deployment would require empirical calibration on disaster-specific evaluation sets.

### Hallucination in High-Stakes Output
LLMs can hallucinate. If Gemma 4 misclassifies a "fire" as "structural collapse", responders dispatched on that basis could go to the wrong scene with wrong equipment. Production deployment must include human-in-the-loop verification before any dispatch action.

### Privacy
Field photos may contain identifiable civilians, including casualties. Production deployment must include:
- Local-only processing (no cloud upload of raw images)
- Automatic blurring of faces and identifying features
- Chain-of-custody logging
- Consent frameworks aligned with the deployment jurisdiction

### Bias in Training Data
Gemma 4 was trained predominantly on Western, English-language content. Visual recognition of disaster scenes may be biased toward:
- Built environments common in North America/Europe
- English-language signage and context cues
- Disaster types common in developed-nation media coverage

Production deployment for international response would require additional fine-tuning on regionally-diverse imagery.

### Displacement of Existing Workflows
Existing emergency response has decades of refined protocols (Incident Command System, NIMS, etc). An AI tool that doesn't integrate with these protocols can create parallel-track confusion. Production deployment must be designed in partnership with responder agencies, not imposed on them.

## What Would Be Needed for Real Deployment

1. **Domain expert validation** — controlled studies with emergency management professionals
2. **Empirical calibration** — measure actual accuracy across diverse disaster types
3. **Integration design** — work with existing CAD/RMS systems, not against them
4. **Liability framework** — clear allocation of responsibility for AI-influenced decisions
5. **Field hardware** — ruggedized devices, sustained battery, mesh networking
6. **Privacy infrastructure** — on-device inference, no raw data egress
7. **Multi-language support** — fine-tuning for international deployment
8. **Failure mode testing** — adversarial inputs, edge cases, equipment failures

## Why We Built This Anyway

Despite these limitations, we believe demonstrating the **technical possibility** of multimodal AI fusion for emergency response is valuable. It creates a starting point for the harder conversations: how should AI augment (not replace) responder judgment? What does responsible deployment look like? Who needs to be at the table?

We submit this as a **research prototype open to critique**, not as a finished product. Pull requests, criticisms, and partnership inquiries are welcome.