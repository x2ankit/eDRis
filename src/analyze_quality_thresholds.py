import os
import cv2
import numpy as np
import glob
from tqdm import tqdm

def evaluate_quality(img_path):
    img = cv2.imread(img_path)
    if img is None:
        return None, None
    
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # 1. Blur (Variance of Laplacian)
    laplacian_var = cv2.Laplacian(gray, cv2.CV_64F).var()
    
    # 2. Illumination (Mean Intensity)
    mean_intensity = np.mean(gray)
    
    return laplacian_var, mean_intensity

def run_analysis(dataset_dir, sample_size=1000):
    print(f"Analyzing {dataset_dir}...")
    img_paths = glob.glob(os.path.join(dataset_dir, "*.png")) + glob.glob(os.path.join(dataset_dir, "*.jpg"))
    img_paths = img_paths[:sample_size]
    
    blur_scores = []
    illumination_scores = []
    
    for path in tqdm(img_paths):
        blur, illum = evaluate_quality(path)
        if blur is not None:
            blur_scores.append(blur)
            illumination_scores.append(illum)
            
    blur_scores = np.array(blur_scores)
    illumination_scores = np.array(illumination_scores)
    
    print("\n--- RESULTS ---")
    print(f"Blur (Variance of Laplacian) - Mean: {blur_scores.mean():.2f}, 5th Percentile (Too Blurry): {np.percentile(blur_scores, 5):.2f}")
    print(f"Illumination (Mean Intensity) - Mean: {illumination_scores.mean():.2f}")
    print(f"   5th Percentile (Too Dark): {np.percentile(illumination_scores, 5):.2f}")
    print(f"   95th Percentile (Too Bright): {np.percentile(illumination_scores, 95):.2f}")
    return np.percentile(blur_scores, 5), np.percentile(illumination_scores, 5), np.percentile(illumination_scores, 95)

if __name__ == "__main__":
    aptos_dir = os.path.abspath(os.path.join("datasets", "classification", "aptos2019", "train_images"))
    if os.path.exists(aptos_dir):
        run_analysis(aptos_dir)
    else:
        print("APTOS directory not found at", aptos_dir)
