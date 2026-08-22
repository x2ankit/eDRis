# Problem Statement Details: SIH 26038

## Overview
- **Problem Statement ID:** 26038
- **Problem Statement Title:** Explainable AI for Diabetic Retinopathy Screening in Rural India
- **Organization:** MathWorks
- **Department:** MathWorks
- **Category:** Software
- **Theme:** Clean & Green Technology
- **PS Number:** SIH26038
- **Deadline for Idea Submission:** 20 September 2026

## Description

### Background
India has over 77 million diabetic adults - the second highest globally. Diabetic Retinopathy (DR) affects ~18% of this population and is a leading cause of preventable blindness. Early screening can prevent 90% of vision loss, but India has only ~1 ophthalmologist per 100,000 rural population, making mass manual screening infeasible. Existing AI solutions function as black boxes, lack clinical validation rigor, and fail with variable image quality from portable fundus cameras in field conditions. A robust, explainable, and validated screening system is essential for deployment in primary healthcare centres across rural India.

### Objective
Design a MATLAB-based retinal image analysis pipeline for automated DR screening addressing real-world deployment challenges:

1. **Image Quality Assessment and Enhancement:** Automatically evaluate fundus images for adequacy (focus, illumination, field of view). Apply adaptive enhancement (CLAHE, illumination normalization, denoising) for borderline images; reject ungradeable ones with recapture feedback.
2. **Retinal Structure Segmentation:** Extract clinically relevant structures - optic disc/fovea localization, vessel segmentation, microaneurysm detection, exudate segmentation, hemorrhage classification, and neovascularization detection.
3. **DR Severity Grading:** Classify using the International Clinical DR severity scale (Levels 0-4, from no DR to proliferative DR) with clinically acceptable sensitivity (>90%) and specificity (>85%) for referable DR (Level 2+).
4. **Explainability Module:** Implement Grad-CAM attention maps, lesion-level evidence correlated with clinical criteria, calibrated confidence scores, and automated annotated reports - enabling ophthalmologist validation in under 30 seconds for a human-in-the-loop workflow.
5. **Simulink Workflow Simulation:** Model the telemedicine screening pipeline in Simulink - image acquisition rates, bandwidth constraints, processing throughput, and review capacity - to optimize resource allocation for district-level programs serving 100,000+ patients annually.

This problem demands clinical validation rigor, sub-pixel microaneurysm detection, and clinically meaningful explainability.

### Tools Allowed / Expected
Image Processing Toolbox, Computer Vision Toolbox, Deep Learning Toolbox, Medical Imaging Toolbox, Simulink, Statistics and Machine Learning Toolbox

### Expected Solution
A working prototype demonstrating: 
- DR classification with >90% sensitivity and >85% specificity for referable DR.
- Explainable Grad-CAM outputs rated as clinically useful.
- A Simulink model optimizing screening resource allocation.
- Validation against published benchmarks showing the integrated pipeline outperforms any single technique approach.

## Dataset Links
- **APTOS 2019 Blindness Detection:** https://www.kaggle.com/c/aptos2019-blindness-detection
- **IDRiD (Indian Diabetic Retinopathy Image Dataset):** https://ieeedataport.org/open-access/indian-diabetic-retinopathy-image-dataset-idrid
- **DRIVE (Vessel Extraction):** https://drive.grand-challenge.org/
- **Messidor-2:** https://www.adcis.net/en/third-party/messidor2/
