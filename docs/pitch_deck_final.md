# 🎯 eDRis: Final Pitch Deck Script & Slide Guide

This document contains the EXACT content, visual layout, and speaking script for your final SIH presentation. You can copy-paste the text directly into PowerPoint or Canva.

---

## 🪧 Slide 1: Title & Hook
**Visual Layout:**
- **Background:** Clean white or subtle dark theme (MathWorks blue accents).
- **Center Text:** eDRis - Explainable Diabetic Retinopathy Intelligent Screening
- **Subtitle:** An Adaptive Edge-to-Cloud Telemedicine Pipeline for Rural India
- **Logos:** MathWorks, SIH 2026, and your college/team logo.

**🗣️ Speaking Script:**
> *"Good morning judges. We are team [Your Team Name]. Today we are tackling Problem Statement 26038 by MathWorks. 
> India has 77 million diabetic adults, and 90% of diabetic vision loss is preventable with early screening. However, there is only about 1 ophthalmologist for every 100,000 people in rural India. 
> To solve this, we didn't just build an AI model; we engineered an entire end-to-end telemedicine infrastructure called eDRis."*

---

## 🛑 Slide 2: The Core Problem (Infrastructure vs AI)
**Visual Layout:**
- **Left Side:** A standard "Black-Box AI" (Robot brain icon).
- **Right Side:** A rural clinic with a "2G network" icon and "Low Bandwidth" text.
- **Bullet Points:**
  - Standard AI fails on 2G connections.
  - Doctors don't trust "Black-Box" AI predictions.
  - Rural clinics waste time uploading blurry, ungradeable photos.

**🗣️ Speaking Script:**
> *"The bottleneck in rural healthcare isn't just a lack of doctors; it's a lack of infrastructure. If we deploy a massive AI model to a remote clinic, it will fail when the 2G network drops. Furthermore, even if the AI works, doctors don't trust 'Black-Box' predictions that just spit out a severity level without proof. Our architecture solves both the infrastructure and trust problems."*

---

## 🏗️ Slide 3: The 4-Layer Architecture (The Solution)
**Visual Layout:**
- Insert the **4-layer Mermaid Flowchart** here (you can take a screenshot of the flowchart from your README).
- Highlight the 4 layers: Edge, Simulink, Cloud, Human.

**🗣️ Speaking Script:**
> *"We designed a 4-layer Edge-to-Cloud architecture. 
> Layer 1 is the Virtual Edge, which acts as a bouncer to reject blurry images instantly offline. 
> Layer 2 is our Simulink Network Orchestrator, which adapts to dropping bandwidth. 
> Layer 3 is our Cloud AI Engine running a ResNet-50.
> Layer 4 is the Explainability UI that automatically triages patients. Let's look at these in action."*

---

## 🚦 Slide 4: Simulink Network Orchestration (Layer 2)
**Visual Layout:**
- Insert the **Screenshot of your Simulink Model** (`simulate_bandwidth_controller.slx`).
- **Text Box:** "Dynamic Bandwidth Routing"

**🗣️ Speaking Script:**
> *"Using MathWorks Simulink, we built a dynamic network orchestrator. If the rural clinic has a strong 4G connection, Simulink routes the raw, uncompressed HD image to the cloud. However, if Simulink detects the network dropping to 2G, it automatically routes the image through an adaptive compressor. This guarantees the upload never fails, no matter how bad the internet gets."*

---

## 🧠 Slide 5: The Cloud AI Engine (Layer 3)
**Visual Layout:**
- **Left Side:** PyTorch Logo + ONNX Logo + MATLAB Logo.
- **Text:** 
  - Model: ResNet-50 (Transfer Learning)
  - Accuracy Achieved: **91%** 
  - Deployment: Exported from Python via ONNX to MATLAB.

**🗣️ Speaking Script:**
> *"For the heavy lifting, we utilized Python and PyTorch to train a ResNet-50 model on the APTOS and IDRiD datasets. After just 5 epochs, we achieved a 91% accuracy rate. Crucially, we didn't leave this in Python; we exported the trained weights via ONNX and successfully deployed them natively inside MATLAB for seamless integration."*

---

## 🔍 Slide 6: White-Box Explainability (Layer 4)
**Visual Layout:**
- Insert the **Screenshot of your MATLAB Grad-CAM UI** (The split screen showing the original eye and the heatmap).
- **Text:** "Building Doctor Trust via Grad-CAM"

**🗣️ Speaking Script:**
> *"This is what the ophthalmologist sees in the city. Instead of a black-box guessing game, our MATLAB UI generates a Grad-CAM heatmap. It physically highlights the microaneurysms and hemorrhages in red. This allows the remote doctor to look at the evidence and validate the AI's 99.9% confidence prediction in under 10 seconds, drastically reducing doctor fatigue."*

---

## 🚀 Slide 7: Auto-Triage & Sustainability
**Visual Layout:**
- **Bullet Points:**
  - 95% of healthy patients get auto-generated reports.
  - Only severe/flagged cases reach the human doctor.
  - Deploys on standard clinic laptops (No GPU required at the edge).

**🗣️ Speaking Script:**
> *"By combining these layers, eDRis creates an auto-triage system. Healthy patients receive instant automated clearance. Only severe cases are queued for the human doctor. Because the heavy AI runs in the cloud and the edge runs lightweight MATLAB scripts, this entire system can be deployed on standard, low-cost laptops in Primary Health Centres across India."*

---

## 🏆 Slide 8: Conclusion
**Visual Layout:**
- **Large Text:** eDRis is ready for deployment.
- **Team Names:** [List your 6 members].
- "Thank You!"

**🗣️ Speaking Script:**
> *"We didn't just train an AI model. We built a robust, explainable, network-aware telemedicine pipeline. Thank you for your time, we are now open for questions."*
