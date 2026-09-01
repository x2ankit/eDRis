import os
import glob
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
from PIL import Image
import numpy as np
from tqdm import tqdm

# ==========================================
# 1. Custom Dataset for Image-to-Mask Loading
# ==========================================
class IDRiDSegmentationDataset(Dataset):
    def __init__(self, img_dir, mask_dir, transform=None):
        """
        Loads the raw fundus image and its corresponding pixel-perfect binary mask.
        """
        self.img_dir = img_dir
        self.mask_dir = mask_dir
        self.transform = transform
        
        # IDRiD images are named like "IDRiD_01.jpg" and masks like "IDRiD_01_MA.tif"
        self.img_paths = sorted(glob.glob(os.path.join(img_dir, "*.jpg")))
        
    def __len__(self):
        return len(self.img_paths)
    
    def __getitem__(self, idx):
        img_path = self.img_paths[idx]
        filename = os.path.basename(img_path)
        base_name = os.path.splitext(filename)[0]
        
        # Microaneurysms (MA) mask path mapping
        mask_filename = f"{base_name}_MA.tif"
        mask_path = os.path.join(self.mask_dir, mask_filename)
        
        # Load Image and Mask
        image = Image.open(img_path).convert('RGB')
        
        if os.path.exists(mask_path):
            mask = Image.open(mask_path).convert('L') # Grayscale binary mask
        else:
            # If a patient has no microaneurysms, the mask file might not exist.
            # Return a blank black mask in this case.
            mask = Image.new('L', image.size, 0)
            
        if self.transform:
            # We must apply the exact same random transforms to BOTH image and mask
            # For simplicity in this script, we resize them deterministically
            image = image.resize((256, 256))
            mask = mask.resize((256, 256), Image.NEAREST)
            
            image = transforms.ToTensor()(image)
            mask = transforms.ToTensor()(mask)
            
        return image, mask

# ==========================================
# 2. State-of-the-Art U-Net Architecture
# ==========================================
class UNet(nn.Module):
    """
    A classic U-Net architecture for Medical Image Segmentation.
    Encoder (Downsampling) -> Bottleneck -> Decoder (Upsampling)
    """
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
            
        # Encoder
        self.enc1 = conv_block(in_channels, 64)
        self.enc2 = conv_block(64, 128)
        self.enc3 = conv_block(128, 256)
        self.enc4 = conv_block(256, 512)
        self.pool = nn.MaxPool2d(2)
        
        # Bottleneck
        self.bottleneck = conv_block(512, 1024)
        
        # Decoder
        self.upconv4 = nn.ConvTranspose2d(1024, 512, kernel_size=2, stride=2)
        self.dec4 = conv_block(1024, 512)
        self.upconv3 = nn.ConvTranspose2d(512, 256, kernel_size=2, stride=2)
        self.dec3 = conv_block(512, 256)
        self.upconv2 = nn.ConvTranspose2d(256, 128, kernel_size=2, stride=2)
        self.dec2 = conv_block(256, 128)
        self.upconv1 = nn.ConvTranspose2d(128, 64, kernel_size=2, stride=2)
        self.dec1 = conv_block(128, 64)
        
        # Final Output (1 channel for binary lesion mask)
        self.out = nn.Conv2d(64, out_channels, kernel_size=1)
        
    def forward(self, x):
        # Down
        e1 = self.enc1(x)
        e2 = self.enc2(self.pool(e1))
        e3 = self.enc3(self.pool(e2))
        e4 = self.enc4(self.pool(e3))
        
        # Bottleneck
        b = self.bottleneck(self.pool(e4))
        
        # Up (with Skip Connections to preserve spatial details)
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

# ==========================================
# 3. Dice Loss (Standard for Imbalanced Masks)
# ==========================================
class DiceLoss(nn.Module):
    def __init__(self):
        super(DiceLoss, self).__init__()
        
    def forward(self, pred, target, smooth=1e-5):
        pred = torch.sigmoid(pred)
        intersection = (pred * target).sum(dim=(2,3))
        union = pred.sum(dim=(2,3)) + target.sum(dim=(2,3))
        dice = (2. * intersection + smooth) / (union + smooth)
        return 1.0 - dice.mean()

# ==========================================
# 4. Training Pipeline
# ==========================================
def train_unet():
    print("Initializing U-Net Segmentation Pipeline...")
    
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'datasets'))
    img_dir = os.path.join(base_dir, 'segmentation', 'idrid_segmentation', 'A. Segmentation', '1. Original Images', 'a. Training Set')
    mask_dir = os.path.join(base_dir, 'segmentation', 'idrid_segmentation', 'A. Segmentation', '2. All Segmentation Groundtruths', 'a. Training Set', '1. Microaneurysms')
    
    dataset = IDRiDSegmentationDataset(img_dir, mask_dir, transform=True)
    loader = DataLoader(dataset, batch_size=4, shuffle=True, num_workers=2)
    
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = UNet(in_channels=3, out_channels=1).to(device)
    
    # We combine BCE (Pixel-level accuracy) with Dice Loss (Object-level accuracy)
    bce_criterion = nn.BCEWithLogitsLoss()
    dice_criterion = DiceLoss()
    
    optimizer = optim.Adam(model.parameters(), lr=1e-4)
    
    EPOCHS = 10
    for epoch in range(EPOCHS):
        model.train()
        running_loss = 0.0
        
        pbar = tqdm(loader, desc=f"U-Net Epoch {epoch+1}/{EPOCHS}")
        for images, masks in pbar:
            images, masks = images.to(device), masks.to(device)
            
            optimizer.zero_grad()
            outputs = model(images)
            
            # Combined Loss
            loss_bce = bce_criterion(outputs, masks)
            loss_dice = dice_criterion(outputs, masks)
            loss = loss_bce + loss_dice
            
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            pbar.set_postfix({'Loss': f"{loss.item():.4f}"})
            
    # Save the segmentation model
    os.makedirs('../models', exist_ok=True)
    torch.save(model.state_dict(), '../models/unet_segmentation_MA.pth')
    print("Saved SOTA U-Net Model to models/unet_segmentation_MA.pth")
    
    # Export to ONNX for MATLAB
    dummy_input = torch.randn(1, 3, 256, 256, device=device)
    onnx_path = '../models/unet_segmentation_MA.onnx'
    torch.onnx.export(model, dummy_input, onnx_path, 
                      export_params=True, 
                      opset_version=11, 
                      do_constant_folding=True, 
                      input_names=['input'], 
                      output_names=['output'])
    print(f"ONNX Model saved to {onnx_path} for MATLAB/Simulink!")

if __name__ == '__main__':
    import multiprocessing
    multiprocessing.freeze_support()
    train_unet()
