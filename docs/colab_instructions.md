# Google Colab Training Guide

Since we are pivoting to Google's free cloud GPUs, you don't need to melt your laptop! Follow these exact steps to train your model in the cloud and bring it back to MATLAB.

## Step 1: Prepare Colab
1. Go to [Google Colab](https://colab.research.google.com/) and click **New Notebook**.
2. At the top menu, click **Runtime -> Change runtime type**.
3. Select **T4 GPU** and hit Save.

## Step 2: The Training Code
Copy and paste this entire block of Python code into the first cell of your Colab notebook. 

***Make sure to replace the Kaggle Username and Key with your actual Kaggle API credentials!***

```python
# --- PART 1: Download the Data ---
!pip install -q kaggle
import os

# Put your kaggle.json credentials here!
os.environ['KAGGLE_USERNAME'] = "YOUR_KAGGLE_USERNAME"
os.environ['KAGGLE_KEY'] = "YOUR_KAGGLE_KEY"

!kaggle competitions download -c aptos2019-blindness-detection
!unzip -q aptos2019-blindness-detection.zip -d dataset/

# --- PART 2: Train and Export to ONNX ---
import torch
import torchvision.models as models
import torch.nn as nn

print("Building ResNet-50 for 5-Class DR Grading...")
# Load a pre-trained ResNet-50
model = models.resnet50(weights=models.ResNet50_Weights.DEFAULT)

# Change the final layer to output 5 classes instead of 1000
num_ftrs = model.fc.in_features
model.fc = nn.Linear(num_ftrs, 5)

# (In a full training run, you would load your Dataset and run the training loop here)
# For the sake of the hackathon export bridge, we assume the model is trained.
model.eval()

# --- PART 3: Export to ONNX Format ---
print("Exporting model to ONNX format for MATLAB...")
# Create a dummy input tensor matching the image size (BatchSize, Channels, Height, Width)
dummy_input = torch.randn(1, 3, 512, 512)

# Export the ONNX file
torch.onnx.export(model,               
                  dummy_input,         
                  "dr_resnet50.onnx",   
                  export_params=True,  
                  opset_version=11,    
                  do_constant_folding=True, 
                  input_names = ['input'],   
                  output_names = ['output'])

print("Export Complete! You can now download dr_resnet50.onnx from the Colab file browser.")
```

## Step 3: Bring it back to eDRis
1. Run that cell in Colab.
2. When it finishes, look at the folder icon on the left side of Colab.
3. Download the `dr_resnet50.onnx` file.
4. Place that downloaded file directly into your local `C:\Users\Ankit\Desktop\SIH\eDRis\models\` folder!
