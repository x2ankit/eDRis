<div align="center">
  <h1>👁️ eDRis: Explainable Diabetic Retinopathy Intelligent Screening</h1>
  
  <p><strong>An Adaptive Edge-to-Cloud Telemedicine Pipeline for Rural India</strong></p>

  <img src="https://img.shields.io/badge/Status-Active_Development-success?style=for-the-badge" alt="Status" />
  <img src="https://img.shields.io/badge/Platform-MATLAB_%26_Simulink-blue?style=for-the-badge&logo=mathworks" alt="MATLAB" />
  <img src="https://img.shields.io/badge/Hackathon-SIH_2026-orange?style=for-the-badge" alt="SIH 2026" />
  <img src="https://img.shields.io/badge/License-MIT-gray?style=for-the-badge" alt="License" />
</div>

<br />

**Project:** Explainable AI for Diabetic Retinopathy Screening in Rural India  
**Organization:** MathWorks (Problem Statement SIH26038)  
**Theme:** Clean & Green Technology  

---

## 🌟 Executive Summary

India is home to over 77 million diabetic adults, with approximately 18% facing Diabetic Retinopathy (DR)—a leading cause of preventable blindness. While early screening can mitigate 90% of vision loss, rural regions face a critical shortage of ophthalmologists (approx. 1 per 100,000 residents). 

**eDRis** is an advanced, MATLAB-based retinal image analysis and telemedicine pipeline designed to bridge this gap. Moving beyond generic "black box" AI, eDRis provides a clinically rigorous, **white-box explainable screening framework** capable of functioning robustly in highly variable rural infrastructure conditions (like dropping 2G/3G connections).

## 🏗️ Architectural Overview

The eDRis architecture solves both clinical and infrastructure bottlenecks through a 4-layer Edge-to-Cloud framework:

```mermaid
graph TD
    classDef edge fill:#eff6ff,stroke:#3b82f6,stroke-width:2px,color:#0f172a
    classDef network fill:#fff7ed,stroke:#f97316,stroke-width:2px,color:#0f172a
    classDef cloud fill:#faf5ff,stroke:#a855f7,stroke-width:2px,color:#0f172a
    classDef human fill:#f0fdf4,stroke:#22c55e,stroke-width:2px,color:#0f172a

    subgraph "Layer 1: Virtual Edge (Clinic App)"
        A[📸 Portable Camera] --> B[📱 Desktop Clinic App]
        B --> C{Offline Quality AI}
        C -->|Ungradeable| D[❌ Instant Recapture Alert]
        D -.-> A
        C -->|Gradeable| E[Adaptive Pre-processing]
    end

    subgraph "Layer 2: Simulink Orchestrator"
        E --> G{📡 Bandwidth Controller}
        G -->|4G Connection| H[📤 Transmit Raw HD Image]
        G -->|2G Connection| I[📤 Transmit Compressed Features]
    end

    subgraph "Layer 3: Cloud AI Engine"
        H --> J[🧠 Dual-Branch Deep Learning]
        I --> J
        J --> K[Branch 1: Segmentation]
        J --> L[Branch 2: Classification]
        K --> M[Lesion Maps]
        L --> N[Severity Level 0-4]
        M --> O[Generate Grad-CAM]
        N --> O
    end

    subgraph "Layer 4: Auto-Triage & Doctor UI"
        O --> Q{Confidence & Severity}
        Q -->|Level 0 & >95% Conf| R[✅ Auto-Generate Normal Report]
        Q -->|Level 2+ or Low Conf| S[⚠️ Flag for Doctor Queue]
        S --> T[👩‍⚕️ Final Human Review]
    end

    class A,B,C,D,E edge
    class G,H,I network
    class J,K,L,M,N,O cloud
    class Q,R,S,T human
```

## ⚙️ Core Modules

## 🔥 Core SOTA Features
- **Multi-Dataset Data Fusion**: Trained dynamically across APTOS 2019, IDRiD, and DRIVE for unparalleled real-world robustness.
- **Handling Class Imbalance**: Built-in Weighted Random Samplers and Dice Loss to ensure high recall on rare, severe (Level 4) cases.
- **Data-Driven Quality Gatekeeper (Phase 2)**: An offline Python preprocessing module that calculates Laplacian variance and mean pixel intensity. It rejects ungradeable images based on strict percentiles and automatically rescues borderline images via CLAHE.
- **Simulink Telemedicine Workflow (Phase 5)**: Dynamically evaluates rural network speeds and queue sizes, processing real metrics to simulate rural clinic scaling.
- **Explainable U-Net Dashboard (Phase 4)**: A premium "White-Box" UI that overlays precise U-Net semantic segmentation maps on microaneurysms, giving remote doctors instant trust in the AI's ResNet diagnosis without black-box guessing.

### Phase 1: Baseline Classification
A custom PyTorch-trained **ResNet-18/50** exported to ONNX format.
- **Goal:** Predict the severity of Diabetic Retinopathy (Levels 0-4).
- **Target:** Sensitivity >90% and Specificity >85% for Referable DR (Level 2+).

### Phase 2: Image Quality Gatekeeper
- Automatically evaluates image focus using Variance of Laplacian.
- Evaluates illumination using Mean Pixel Intensity.
- Applies **CLAHE (Contrast Limited Adaptive Histogram Equalization)** to salvage poorly lit but in-focus images.

### Phase 3: Lesion & Vessel Segmentation
A PyTorch-trained **U-Net** architecture.
- **Lesions:** Trained on IDRiD to isolate Microaneurysms, Hemorrhages, and Hard/Soft Exudates.
- **Vessels:** Trained on the DRIVE dataset to accurately map retinal vasculature.

### 4. White-Box Explainability (Clinical Dashboard)
Utilizes MATLAB's **Grad-CAM** mapping to highlight lesion-level evidence, allowing remote ophthalmologists to confidently validate automated results in under 30 seconds.

## 👥 Team Execution Strategy

Our team utilizes an optimized 2-2-2 parallel development structure:

- **Team 1: The ML Core (2 ML Students)**
  - *Focus:* Dataset cleaning, PyTorch Deep Learning, ONNX exporting.
- **Team 2: The UI/Edge Developers (2 ECE Students)**
  - *Focus:* MATLAB App Designer, Offline Quality AI ("The Bouncer").
- **Team 3: The Simulink Architects (2 ECE Students)**
  - *Focus:* Simulink Stateflow logic, SimEvents queuing, and final architecture wiring.

## 💻 Technology Stack

- **MATLAB R2023b+** (Image Processing, Deep Learning Toolboxes)
- **Simulink & SimEvents**
- **PyTorch (Python)** (For heavy model training & ONNX export)

## 📊 Datasets Utilized
- **[APTOS 2019 Blindness Detection](https://www.kaggle.com/c/aptos2019-blindness-detection)**
- **[IDRiD (Indian Diabetic Retinopathy Image Dataset)](https://ieee-dataport.org/open-access/indian-diabetic-retinopathy-image-dataset-idrid)**

## 📜 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
