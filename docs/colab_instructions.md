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
!pip install -q onnx onnxscript
!pip install -q kaggle
import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms, models
from PIL import Image
import pandas as pd
from tqdm.notebook import tqdm

# Your Kaggle credentials
os.environ['KAGGLE_USERNAME'] = "YOUR_KAGGLE_USERNAME"
os.environ['KAGGLE_KEY'] = "YOUR_KAGGLE_KEY"

!kaggle competitions download -c aptos2019-blindness-detection
!unzip -qo aptos2019-blindness-detection.zip -d dataset/

# --- PART 2: The Training Architecture ---
print("Setting up DataLoaders...")

class APTOSDataset(Dataset):
    def __init__(self, csv_file, root_dir, transform=None):
        self.annotations = pd.read_csv(csv_file)
        self.root_dir = root_dir
        self.transform = transform

    def __len__(self):
        return len(self.annotations)

    def __getitem__(self, index):
        img_id = self.annotations.iloc[index, 0]
        img_path = os.path.join(self.root_dir, f"{img_id}.png")
        image = Image.open(img_path).convert("RGB")
        y_label = torch.tensor(int(self.annotations.iloc[index, 1]))
        if self.transform:
            image = self.transform(image)
        return (image, y_label)

transform = transforms.Compose([
    transforms.Resize((512, 512)),
    transforms.RandomHorizontalFlip(),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

# Create Dataset and DataLoader
dataset = APTOSDataset(csv_file='dataset/train.csv', root_dir='dataset/train_images', transform=transform)
train_loader = DataLoader(dataset, batch_size=16, shuffle=True, num_workers=2)

print("Building ResNet-50 for 5-Class DR Grading...")
model = models.resnet50(weights=models.ResNet50_Weights.DEFAULT)
num_ftrs = model.fc.in_features
model.fc = nn.Linear(num_ftrs, 5)

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = model.to(device)

criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.0001)

# --- PART 3: The Actual Training Loop ---
NUM_EPOCHS = 5
print(f"Starting Training for {NUM_EPOCHS} epochs on {device}...")

for epoch in range(NUM_EPOCHS):
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0
    
    progress_bar = tqdm(train_loader, desc=f"Epoch {epoch+1}/{NUM_EPOCHS}")
    for images, labels in progress_bar:
        images, labels = images.to(device), labels.to(device)
        
        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        
        running_loss += loss.item()
        _, predicted = torch.max(outputs.data, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()
        
        progress_bar.set_postfix({'Loss': loss.item(), 'Acc': 100 * correct / total})

# --- PART 4: Export to ONNX Format ---
print("Exporting fully trained model to ONNX format...")
model.eval()
dummy_input = torch.randn(1, 3, 512, 512).to(device)

torch.onnx.export(model,               
                  dummy_input,         
                  "dr_resnet50.onnx",   
                  export_params=True,  
                  opset_version=14,    
                  do_constant_folding=True, 
                  input_names = ['input'],   
                  output_names = ['output'])

print("Export Complete! You can now download dr_resnet50.onnx and dr_resnet50.onnx.data from the Colab file browser.")
```

## Step 3: Bring it back to eDRis
1. Run that cell in Colab.
2. When it finishes, look at the folder icon on the left side of Colab.
3. Download the `dr_resnet50.onnx` file.
4. Place that downloaded file directly into your local `C:\Users\Ankit\Desktop\SIH\eDRis\models\` folder!
