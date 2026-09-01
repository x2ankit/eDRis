import cv2
import numpy as np
import os

# ==========================================
# EVIDENCE-BASED THRESHOLDS (Calculated from APTOS Dataset)
# ==========================================
BLUR_THRESHOLD = 4.49
DARK_THRESHOLD = 37.49
BRIGHT_THRESHOLD = 92.90

def assess_image(image_path):
    """
    Acts as the 'Gatekeeper'. Evaluates if an image is suitable for AI inference.
    Returns: status (PASS, REJECT, ENHANCE), and a dictionary of metrics.
    """
    img = cv2.imread(image_path)
    if img is None:
        return "REJECT", {"error": "Image could not be read."}
    
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Calculate Blur (Variance of Laplacian)
    blur_score = cv2.Laplacian(gray, cv2.CV_64F).var()
    
    # Calculate Illumination (Mean Pixel Intensity)
    mean_intensity = np.mean(gray)
    
    metrics = {
        "blur_score": blur_score,
        "mean_intensity": mean_intensity
    }
    
    # 1. Blur Check (Strict Rejection)
    if blur_score < BLUR_THRESHOLD:
        return "REJECT", metrics
        
    # 2. Illumination Check (Enhancement Possible)
    if mean_intensity < DARK_THRESHOLD or mean_intensity > BRIGHT_THRESHOLD:
        return "ENHANCE", metrics
        
    # 3. Passed all checks
    return "PASS", metrics

def enhance_image(image_path, output_path=None):
    """
    Rescues borderline images using CLAHE (Contrast Limited Adaptive Histogram Equalization).
    Strips away shadows and glare to reveal hidden blood vessels.
    """
    img = cv2.imread(image_path)
    if img is None:
        raise ValueError(f"Could not read {image_path}")
    
    # Convert BGR to LAB color space (L = Lightness, A/B = Color Channels)
    # We only want to equalize the lightness, not distort the colors.
    lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)
    
    # Apply CLAHE to the L-channel
    # clipLimit prevents noise over-amplification
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    cl = clahe.apply(l)
    
    # Merge the CLAHE enhanced L-channel back with the A/B channels
    limg = cv2.merge((cl, a, b))
    
    # Convert back to BGR
    enhanced_img = cv2.cvtColor(limg, cv2.COLOR_LAB2BGR)
    
    if output_path:
        cv2.imwrite(output_path, enhanced_img)
        
    return enhanced_img
