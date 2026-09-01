# eDRis SIH 2026 Pitch Deck Outline

## Slide 1: Title & Hook
- **Title**: eDRis - Explainable Diabetic Retinopathy Intelligent Screening
- **Subtitle**: Bridging the 1:100,000 doctor gap in rural India with Edge-to-Cloud AI.
- **Visual**: A split screen showing a rural clinic and an urban hospital connected by a network line.

## Slide 2: The Infrastructure Problem (Bandwidth & Blur)
- **The Core Issue**: It's not just a lack of doctors; it's a severe lack of rural telemedicine infrastructure. 
- 77 million diabetic adults in India rely on Primary Health Centres (PHCs).
- **Why Standard AI Fails**: Existing AI models assume perfect conditions. In reality, rural clinics face 2G/3G internet speeds and low-quality, blurry 5MB camera inputs.
- *Asset Insertion: Include screenshots of Simulink network bandwidth orchestration blocks highlighting extreme latency scenarios.*

## Slide 3: Our Solution - The eDRis 4-Layer Architecture
- **Layer 1 (The Bouncer)**: Offline image quality check. Rejects blurry/dark images instantly at the edge without wasting precious 2G bandwidth.
- **Layer 4 (The Traffic Cop)**: Simulink-powered bandwidth controller. Automatically dynamically compresses images based on live network speeds (2G vs 4G).
- *Asset Insertion: Add the 4-step architectural flowchart showing the Edge-to-Cloud pipeline.*

## Slide 4: Dual-Branch White-Box AI
- **The Brain**: We didn't just build a standard severity classifier. We engineered a highly advanced "Dual-Branch System" (Classification + U-Net Segmentation).
- **Beyond Guessing**: It doesn't just guess severity from 0 to 4. It literally segments the biological lesions (microaneurysms, hemorrhages, exudates) pixel-by-pixel for doctor verification.

## Slide 5: The "Bouncer" in Action (Live Demo Concept)
- *Demo Script*: Show the `virtual_clinic_app.m` UI.
- Upload a blurry image -> Instant rejection (no internet needed).
- Upload a clear image -> Bandwidth check -> Successful upload.

## Slide 6: White-Box AI vs Black-Box AI (Trust & Verification)
- **Black-box**: AI says "Level 3 DR" -> Doctor ignores it because there is no proof or clinical basis.
- **White-box (eDRis)**: AI says "Level 3 DR" + Heatmap highlighting exact hemorrhages with quantified clinical metrics. Doctor verifies the segmented lesions in 5 seconds.
- *Asset Insertion: High-quality Grad-CAM heatmaps showing the "FINDINGS" and "IMPRESSION" numerical dashboard.*

## Slide 7: Auto-Triage & Doctor UI
- eDRis automatically clears and generates PDFs for the 95% of healthy patients.
- Only the severe/confusing cases are queued to the single human doctor in the city, preventing rural burnout.

## Slide 8: Market Potential & Sustainability
- Deployable on standard rural clinic laptops using INT8 Edge Quantization (no local GPU required for inference).
- Highly scalable across India's Primary Health Centres (PHCs).
- **Conclusion**: We didn't just build an AI model; we engineered a deployable, resilient telemedicine infrastructure designed specifically for rural India.
