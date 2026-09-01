import os
import glob
import cv2
import matplotlib.pyplot as plt
from image_quality_pipeline import assess_image, enhance_image

def test_pipeline(dataset_dir, num_samples=5):
    # Grab a few images from the dataset
    img_paths = glob.glob(os.path.join(dataset_dir, "*.png")) + glob.glob(os.path.join(dataset_dir, "*.jpg"))
    test_paths = img_paths[:num_samples]
    
    for i, path in enumerate(test_paths):
        filename = os.path.basename(path)
        status, metrics = assess_image(path)
        
        print(f"\n--- Image: {filename} ---")
        print(f"Blur Score: {metrics['blur_score']:.2f}")
        print(f"Mean Intensity: {metrics['mean_intensity']:.2f}")
        print(f"Gatekeeper Action: {status}")
        
        if status == "REJECT":
            print("Action: Image rejected. Instructing clinic worker to retake the photo.")
        
        elif status == "ENHANCE":
            print("Action: Image is borderline. Rescuing with CLAHE...")
            # Run CLAHE and save a comparison
            raw_img = cv2.imread(path)
            raw_img = cv2.cvtColor(raw_img, cv2.COLOR_BGR2RGB)
            
            enhanced = enhance_image(path)
            enhanced = cv2.cvtColor(enhanced, cv2.COLOR_BGR2RGB)
            
            # Plot before and after
            fig, ax = plt.subplots(1, 2, figsize=(10, 5))
            ax[0].imshow(raw_img)
            ax[0].set_title(f"Original (Status: {status})")
            ax[0].axis("off")
            
            ax[1].imshow(enhanced)
            ax[1].set_title("Rescued via CLAHE")
            ax[1].axis("off")
            
            output_file = f"iqa_test_{filename}"
            plt.savefig(output_file)
            plt.close()
            print(f"Saved Before/After comparison to {output_file}")
            
        elif status == "PASS":
            print("Action: Image is perfect. Sending directly to AI for inference.")

if __name__ == "__main__":
    aptos_dir = os.path.abspath(os.path.join("datasets", "classification", "aptos2019", "train_images"))
    
    if not os.path.exists(aptos_dir):
        print("Could not find APTOS directory for testing.")
    else:
        test_pipeline(aptos_dir, num_samples=10)
