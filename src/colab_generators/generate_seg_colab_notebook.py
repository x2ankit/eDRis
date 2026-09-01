import json

notebook = {
    "cells": [],
    "metadata": {},
    "nbformat": 4,
    "nbformat_minor": 5
}

def add_markdown(text):
    notebook["cells"].append({
        "cell_type": "markdown",
        "metadata": {},
        "source": [line + "\n" for line in text.split("\n")]
    })

def add_code(code):
    notebook["cells"].append({
        "cell_type": "code",
        "execution_count": None,
        "metadata": {},
        "outputs": [],
        "source": [line + "\n" for line in code.split("\n")]
    })

add_markdown("# eDRis Phase 3: IDRiD U-Net Segmentation (Colab)")
add_markdown("This notebook trains the U-Net architecture on the IDRiD dataset to segment critical DR lesions (Microaneurysms, Hemorrhages, Exudates).")

add_markdown("## 1. Mount Google Drive & Extract Dataset\nUpload your `idrid_segmentation.zip` to your Google Drive inside the `DatasetSIH26` folder and run this cell.")
code_mount = """from google.colab import drive
import os
drive.mount('/content/drive')

# Copy the ZIP from your specific Drive folder to Colab's fast memory
!cp /content/drive/MyDrive/DatasetSIH26/idrid_segmentation.zip /content/

# Unzip it quietly to the fast local disk
!unzip -q /content/idrid_segmentation.zip -d /content/idrid_segmentation/
# These paths will automatically hunt for the correct folder no matter how it was zipped!
import glob

print("Hunting down dataset folders...")
img_search = glob.glob('/content/idrid_segmentation/**/1. Original Images/a. Training Set', recursive=True)
mask_search = glob.glob('/content/idrid_segmentation/**/2. All Segmentation Groundtruths/a. Training Set/1. Microaneurysms', recursive=True)

if not img_search:
    raise ValueError("Could not find the Images directory inside the zip!")
if not mask_search:
    raise ValueError("Could not find the Masks directory inside the zip!")

IMG_DIR = img_search[0]
MASK_DIR = mask_search[0]
print(f"Images found at: {IMG_DIR}")
print(f"Masks found at: {MASK_DIR}")
"""
add_code(code_mount)

add_markdown("## 2. Imports and Dataset Definition")
code_imports = """import os
import glob
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
from PIL import Image
import numpy as np
from tqdm import tqdm

class IDRiDSegmentationDataset(Dataset):
    def __init__(self, img_dir, mask_dir, transform=None):
        self.img_dir = img_dir
        self.mask_dir = mask_dir
        self.transform = transform
        self.img_paths = sorted(glob.glob(os.path.join(img_dir, "*.jpg")))
        
    def __len__(self):
        return len(self.img_paths)
    
    def __getitem__(self, idx):
        img_path = self.img_paths[idx]
        filename = os.path.basename(img_path)
        base_name = os.path.splitext(filename)[0]
        
        # IDRiD Microaneurysm masks end with _MA.tif
        mask_filename = f"{base_name}_MA.tif"
        mask_path = os.path.join(self.mask_dir, mask_filename)
        
        image = Image.open(img_path).convert('RGB')
        
        if os.path.exists(mask_path):
            mask = Image.open(mask_path).convert('L')
        else:
            mask = Image.new('L', image.size, 0)
            
        if self.transform:
            image = image.resize((256, 256))
            mask = mask.resize((256, 256), Image.NEAREST)
            image = transforms.ToTensor()(image)
            mask = transforms.ToTensor()(mask)
            
        return image, mask

dataset = IDRiDSegmentationDataset(IMG_DIR, MASK_DIR, transform=True)
loader = DataLoader(dataset, batch_size=4, shuffle=True, num_workers=2)
"""
add_code(code_imports)

add_markdown("## 3. U-Net Architecture")
code_unet = """class UNet(nn.Module):
    def __init__(self, in_channels=3, out_channels=1):
        super(UNet, self).__init__()
        def conv_block(in_c, out_c):
            return nn.Sequential(
                nn.Conv2d(in_c, out_c, kernel_size=3, padding=1),
                nn.BatchNorm2d(out_c),
                nn.ReLU(inplace=True),
                nn.Conv2d(out_c, out_c, kernel_size=3, padding=1),
                nn.BatchNorm2d(out_c),
                nn.ReLU(inplace=True)
            )
        self.enc1 = conv_block(in_channels, 64)
        self.enc2 = conv_block(64, 128)
        self.enc3 = conv_block(128, 256)
        self.enc4 = conv_block(256, 512)
        self.pool = nn.MaxPool2d(2)
        self.bottleneck = conv_block(512, 1024)
        
        self.upconv4 = nn.ConvTranspose2d(1024, 512, kernel_size=2, stride=2)
        self.dec4 = conv_block(1024, 512)
        self.upconv3 = nn.ConvTranspose2d(512, 256, kernel_size=2, stride=2)
        self.dec3 = conv_block(512, 256)
        self.upconv2 = nn.ConvTranspose2d(256, 128, kernel_size=2, stride=2)
        self.dec2 = conv_block(256, 128)
        self.upconv1 = nn.ConvTranspose2d(128, 64, kernel_size=2, stride=2)
        self.dec1 = conv_block(128, 64)
        self.out = nn.Conv2d(64, out_channels, kernel_size=1)
        
    def forward(self, x):
        e1 = self.enc1(x)
        e2 = self.enc2(self.pool(e1))
        e3 = self.enc3(self.pool(e2))
        e4 = self.enc4(self.pool(e3))
        b = self.bottleneck(self.pool(e4))
        
        d4 = self.upconv4(b)
        d4 = torch.cat((d4, e4), dim=1)
        d4 = self.dec4(d4)
        d3 = self.upconv3(d4)
        d3 = torch.cat((d3, e3), dim=1)
        d3 = self.dec3(d3)
        d2 = self.upconv2(d3)
        d2 = torch.cat((d2, e2), dim=1)
        d2 = self.dec2(d2)
        d1 = self.upconv1(d2)
        d1 = torch.cat((d1, e1), dim=1)
        d1 = self.dec1(d1)
        return self.out(d1)

class DiceLoss(nn.Module):
    def forward(self, pred, target, smooth=1e-5):
        pred = torch.sigmoid(pred)
        intersection = (pred * target).sum(dim=(2,3))
        union = pred.sum(dim=(2,3)) + target.sum(dim=(2,3))
        dice = (2. * intersection + smooth) / (union + smooth)
        return 1.0 - dice.mean()
"""
add_code(code_unet)

add_markdown("## 4. Training Loop")
code_train = """device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")

model = UNet(in_channels=3, out_channels=1).to(device)
bce_criterion = nn.BCEWithLogitsLoss()
dice_criterion = DiceLoss()
optimizer = optim.Adam(model.parameters(), lr=1e-4)

EPOCHS = 10
for epoch in range(EPOCHS):
    model.train()
    running_loss = 0.0
    
    pbar = tqdm(loader, desc=f"Epoch {epoch+1}/{EPOCHS}")
    for images, masks in pbar:
        images, masks = images.to(device), masks.to(device)
        
        optimizer.zero_grad()
        outputs = model(images)
        
        loss_bce = bce_criterion(outputs, masks)
        loss_dice = dice_criterion(outputs, masks)
        loss = loss_bce + loss_dice
        
        loss.backward()
        optimizer.step()
        running_loss += loss.item()
        pbar.set_postfix({'Loss': f"{loss.item():.4f}"})

# Save the model
torch.save(model.state_dict(), '/content/drive/MyDrive/DatasetSIH26/unet_segmentation_MA.pth')
print("Model (.pth) saved to Drive!")
"""
add_code(code_train)

add_markdown("## 5. Export to ONNX (For MATLAB/Simulink Integration)")
code_onnx = """# Export to ONNX (U-Net expects 256x256 input)
dummy_input = torch.randn(1, 3, 256, 256, device=device)
onnx_path = '/content/drive/MyDrive/DatasetSIH26/unet_segmentation_MA.onnx'

torch.onnx.export(model, dummy_input, onnx_path, 
                  export_params=True, 
                  opset_version=11, 
                  do_constant_folding=True, 
                  input_names=['input'], 
                  output_names=['output'])
print(f"ONNX Model saved to {onnx_path} for MATLAB/Simulink!")
"""
add_code(code_onnx)

with open('e:/Ankit/SIH/eDRis/notebooks/train_segmentation_colab.ipynb', 'w') as f:
    json.dump(notebook, f, indent=2)

print("Created train_segmentation_colab.ipynb in notebooks directory")
