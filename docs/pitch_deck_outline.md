# eDRis SIH 2026 Pitch Deck Outline

## Slide 1: Title & Hook
- **Title**: eDRis - Explainable Diabetic Retinopathy Intelligent Screening
- **Subtitle**: Bridging the 1:100,000 doctor gap in rural India with Edge-to-Cloud AI.
- **Visual**: A split screen showing a rural clinic and an urban hospital connected by a network line.

## Slide 2: The Problem (Not just an AI problem, an Infrastructure problem)
- 77 million diabetic adults in India.
- 90% of vision loss is preventable with early screening.
- **The Bottleneck**: It's not just a lack of doctors; it's a lack of rural infrastructure. Standard AI models fail when faced with 2G internet and blurry 5MB images.

## Slide 3: Our Solution - The eDRis 4-Layer Architecture
- **Layer 1 (The Bouncer)**: Offline image quality check. Rejects blurry/dark images instantly without wasting 2G bandwidth.
- **Layer 2 (The Traffic Cop)**: Simulink-powered bandwidth controller. Automatically compresses images based on live network speeds (2G vs 4G).
- **Layer 3 (The Brain)**: Dual-Branch Medical AI. Grades severity (0-4) and segments lesions.
- **Layer 4 (The Explainer)**: Grad-CAM white-box heatmaps that highlight exact microaneurysms, gaining doctor trust.

## Slide 5: The "Bouncer" in Action (Live Demo Concept)
- *Demo Script*: Show the `virtual_clinic_app.m` UI.
- Upload a blurry image -> Instant rejection (no internet needed).
- Upload a clear image -> Bandwidth check -> Successful upload.

## Slide 6: White-Box AI vs Black-Box AI
- **Black-box**: AI says "Level 3 DR" -> Doctor ignores it because there is no proof.
- **White-box (eDRis)**: AI says "Level 3 DR" + Heatmap highlighting exact hemorrhages. Doctor verifies in 5 seconds.

## Slide 7: Auto-Triage & Doctor UI
- eDRis automatically generates PDFs for the 95% of healthy patients.
- Only the severe/confusing cases are queued to the single human doctor in the city, preventing burnout.

## Slide 8: Market Potential & Sustainability
- Deployable on standard rural clinic laptops (no local GPU required for inference).
- Highly scalable across India's Primary Health Centres (PHCs).
- **Conclusion**: We didn't just build a model; we engineered a deployable telemedicine infrastructure.
