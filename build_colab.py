import nbformat as nbf
import os

nb = nbf.v4.new_notebook()

markdown_1 = '''
# APTOS 2019 DR Classification - Colab Training (Kaggle Direct)
This notebook connects directly to Kaggle to download the dataset, splits it into train/val, trains a ResNet-18, and exports the ONNX model and validation metrics for the MATLAB dashboard.

## 1. Setup Kaggle API
Please upload your `kaggle.json` file when prompted.
'''

code_1 = '''
import os
import getpass

print("Enter your Kaggle API Token (KGAT_...):")
kaggle_token = getpass.getpass()
os.environ['KAGGLE_API_TOKEN'] = kaggle_token

print("Downloading APTOS 2019 Dataset...")
!kaggle competitions download -c aptos2019-blindness-detection
!unzip -q aptos2019-blindness-detection.zip -d /content/aptos_dataset
print("Dataset ready!")
'''

markdown_2 = '''
## 2. Imports and Data Preparation
'''

code_2 = '''
import time
import pandas as pd
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler
from torchvision import models, transforms
from PIL import Image
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix, classification_report
import torch.nn.functional as F
import warnings
warnings.filterwarnings('ignore')

IMG_DIR = '/content/aptos_dataset/train_images/'
CSV_FILE = '/content/aptos_dataset/train.csv'

# Load and Split
df = pd.read_csv(CSV_FILE)
train_df, val_df = train_test_split(df, test_size=0.15, stratify=df['diagnosis'], random_state=42)

print(f"Training images: {len(train_df)}")
print(f"Validation images: {len(val_df)}")

class APTOSDataset(Dataset):
    def __init__(self, df, img_dir, transform=None):
        self.df = df.reset_index(drop=True)
        self.img_dir = img_dir
        self.transform = transform

    def __len__(self):
        return len(self.df)

    def __getitem__(self, idx):
        row = self.df.iloc[idx]
        img_name = os.path.join(self.img_dir, f"{row['id_code']}.png")
        image = Image.open(img_name).convert('RGB')
        label = row['diagnosis']
        
        if self.transform:
            image = self.transform(image)
            
        return image, label
'''

code_3 = '''
train_transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.RandomHorizontalFlip(),
    transforms.RandomRotation(15),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])
val_transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

train_dataset = APTOSDataset(train_df, IMG_DIR, transform=train_transform)
val_dataset = APTOSDataset(val_df, IMG_DIR, transform=val_transform)

# Handle Class Imbalance
class_counts = train_df['diagnosis'].value_counts().sort_index().values
class_weights = 1.0 / class_counts
sample_weights = [class_weights[label] for label in train_df['diagnosis']]
sampler = WeightedRandomSampler(sample_weights, num_samples=len(sample_weights), replacement=True)

train_loader = DataLoader(train_dataset, batch_size=32, sampler=sampler, num_workers=2)
val_loader = DataLoader(val_dataset, batch_size=32, shuffle=False, num_workers=2)
'''

markdown_4 = '''
## 3. Training the Model
'''

code_4 = '''
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {device}")

model = models.resnet18(weights='DEFAULT')
num_ftrs = model.fc.in_features
model.fc = nn.Linear(num_ftrs, 5)
model = model.to(device)

criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=1e-4)
num_epochs = 20 # Train for 15-20 epochs for optimal transfer learning

for epoch in range(num_epochs):
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0
    
    start_time = time.time()
    for images, labels in train_loader:
        images, labels = images.to(device), labels.to(device)
        
        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        
        running_loss += loss.item() * images.size(0)
        _, preds = torch.max(outputs, 1)
        correct += torch.sum(preds == labels.data)
        total += labels.size(0)
        
    epoch_loss = running_loss / total
    epoch_acc = correct.double() / total
    print(f"Epoch {epoch+1}/{num_epochs} - Loss: {epoch_loss:.4f}, Acc: {epoch_acc:.4f} - Time: {time.time()-start_time:.1f}s")
'''

markdown_5 = '''
## 4. Exporting for MATLAB (ONNX & Validation CSV)
Mount your Google Drive to save the exported files so you can download them to your PC.
'''

code_5 = '''
from google.colab import drive
drive.mount('/content/drive')
SAVE_DIR = '/content/drive/MyDrive/eDRis_Exports/'
os.makedirs(SAVE_DIR, exist_ok=True)

# 1. Export ONNX
print("Exporting ONNX Model...")
dummy_input = torch.randn(1, 3, 224, 224).to(device)
onnx_path = os.path.join(SAVE_DIR, 'dr_resnet18.onnx')

torch.onnx.export(model, dummy_input, onnx_path, 
                  export_params=True, opset_version=11, 
                  do_constant_folding=True, 
                  input_names = ['input'], output_names = ['output'], 
                  dynamic_axes={'input' : {0 : 'batch_size'}, 'output' : {0 : 'batch_size'}})
print(f'ONNX saved to: {onnx_path}')

# 2. Extract Validation Probabilities for ROC Curve
print("Generating Validation CSV...")
model.eval()
all_probs = []
all_true = []
all_preds_cls = []

with torch.no_grad():
    for images, labels in val_loader:
        images = images.to(device)
        outputs = model(images)
        probs = F.softmax(outputs, dim=1)
        _, preds = torch.max(outputs, 1)
        
        # Prob of Referable DR (Level 2, 3, 4)
        referable_probs = torch.sum(probs[:, 2:], dim=1).cpu().numpy()
        all_probs.extend(referable_probs)
        all_true.extend(labels.numpy())
        all_preds_cls.extend(preds.cpu().numpy())

csv_path = os.path.join(SAVE_DIR, 'validation_results.csv')
df_results = pd.DataFrame({'True_Label': all_true, 'Predicted_Prob_Level_2_Plus': all_probs})
df_results.to_csv(csv_path, index=False)
print(f'CSV saved to: {csv_path}')

# 3. Print Quick Metrics
binary_labels = [1 if x >= 2 else 0 for x in all_true]
binary_preds = [1 if x >= 2 else 0 for x in all_preds_cls]
tn, fp, fn, tp = confusion_matrix(binary_labels, binary_preds).ravel()
sens = tp / (tp + fn) if (tp + fn) > 0 else 0
spec = tn / (tn + fp) if (tn + fp) > 0 else 0
print(f"\\nQuick Check - Sensitivity: {sens:.4f}, Specificity: {spec:.4f}")
print("\\nYou can now download both files from your Google Drive and plug them into MATLAB!")
'''

nb['cells'] = [
    nbf.v4.new_markdown_cell(markdown_1),
    nbf.v4.new_code_cell(code_1),
    nbf.v4.new_markdown_cell(markdown_2),
    nbf.v4.new_code_cell(code_2),
    nbf.v4.new_code_cell(code_3),
    nbf.v4.new_markdown_cell(markdown_4),
    nbf.v4.new_code_cell(code_4),
    nbf.v4.new_markdown_cell(markdown_5),
    nbf.v4.new_code_cell(code_5)
]

with open('notebooks/train_baseline_colab.ipynb', 'w') as f:
    nbf.write(nb, f)
