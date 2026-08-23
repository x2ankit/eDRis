import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler
from torchvision import transforms, models
from PIL import Image
import pandas as pd
import numpy as np
from tqdm import tqdm

# ==========================================
# Phase 1: Multi-Dataset Fusion
# ==========================================
class UnifiedDRDataset(Dataset):
    def __init__(self, aptos_csv, aptos_dir, idrid_csv, idrid_dir, transform=None):
        """
        Combines multiple datasets into a single, unified PyTorch Dataset.
        """
        self.transform = transform
        
        # 1. Load APTOS
        self.aptos_df = pd.read_csv(aptos_csv)
        self.aptos_df['image_path'] = self.aptos_df['id_code'].apply(lambda x: os.path.join(aptos_dir, f"{x}.png"))
        self.aptos_df = self.aptos_df[['image_path', 'diagnosis']]
        
        # 2. Load IDRiD
        self.idrid_df = pd.read_csv(idrid_csv)
        # IDRiD CSV uses 'Image name' and 'Retinopathy grade'
        self.idrid_df['image_path'] = self.idrid_df['Image name'].apply(lambda x: os.path.join(idrid_dir, f"{x}.jpg"))
        self.idrid_df['diagnosis'] = self.idrid_df['Retinopathy grade']
        self.idrid_df = self.idrid_df[['image_path', 'diagnosis']]
        
        # 3. Unified DataFrame
        self.df = pd.concat([self.aptos_df, self.idrid_df], ignore_index=True)
        
        # Ensure files actually exist (filter out broken paths)
        self.df = self.df[self.df['image_path'].apply(os.path.exists)]
        print(f"Total Unified Images Loaded: {len(self.df)}")
        
    def __len__(self):
        return len(self.df)
    
    def __getitem__(self, idx):
        img_path = self.df.iloc[idx]['image_path']
        label = int(self.df.iloc[idx]['diagnosis'])
        
        image = Image.open(img_path).convert('RGB')
        
        if self.transform:
            image = self.transform(image)
            
        return image, label
        
    def get_labels(self):
        return self.df['diagnosis'].values

# ==========================================
# Phase 2: Advanced SOTA Training Pipeline
# ==========================================
def train_sota_model():
    # 1. Heavy Data Augmentation (Prevents 100% Overconfidence / Overfitting)
    train_transform = transforms.Compose([
        transforms.Resize((256, 256)),
        transforms.RandomResizedCrop(224, scale=(0.8, 1.0)),
        transforms.RandomHorizontalFlip(p=0.5),
        transforms.RandomVerticalFlip(p=0.5),
        transforms.RandomRotation(degrees=45),
        transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    # 2. Dataset Paths
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'datasets'))
    aptos_csv = os.path.join(base_dir, 'classification', 'aptos2019', 'train.csv')
    aptos_dir = os.path.join(base_dir, 'classification', 'aptos2019', 'train_images')
    idrid_csv = os.path.join(base_dir, 'classification', 'idrid_grading', 'B. Disease Grading', '2. Groundtruths', 'a. IDRiD_Disease Grading_Training Labels.csv')
    idrid_dir = os.path.join(base_dir, 'classification', 'idrid_grading', 'B. Disease Grading', '1. Original Images', 'a. Training Set')
    
    # Initialize Unified Dataset
    full_dataset = UnifiedDRDataset(aptos_csv, aptos_dir, idrid_csv, idrid_dir, transform=train_transform)
    
    # 3. Handle Class Imbalance (Weighted Random Sampler)
    # Most images are "Healthy" (Level 0). This sampler forces the AI to see severe cases equally.
    labels = full_dataset.get_labels()
    class_sample_count = np.bincount(labels)
    weight = 1. / class_sample_count
    samples_weight = np.array([weight[t] for t in labels])
    samples_weight = torch.from_numpy(samples_weight).double()
    sampler = WeightedRandomSampler(samples_weight, len(samples_weight))
    
    train_loader = DataLoader(full_dataset, batch_size=32, sampler=sampler, num_workers=4)
    
    # 4. SOTA Architecture (ResNet-50 with pretrained weights, but properly tuned)
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = models.resnet50(pretrained=True)
    
    # Replace the final classification head for 5 classes
    num_ftrs = model.fc.in_features
    model.fc = nn.Sequential(
        nn.Dropout(0.5), # Add dropout to prevent overfitting
        nn.Linear(num_ftrs, 5)
    )
    model = model.to(device)
    
    # 5. Advanced Optimization Setup
    # Label Smoothing Cross Entropy helps prevent the model from becoming 100% overconfident
    criterion = nn.CrossEntropyLoss(label_smoothing=0.1)
    optimizer = optim.AdamW(model.parameters(), lr=1e-4, weight_decay=1e-4)
    scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=10)
    
    # 6. Training Loop (Simulated setup for 10-day timeline)
    EPOCHS = 10 # Ideally 50+ for real training, kept short here for demo structure
    print("Starting SOTA Training Pipeline on:", device)
    
    for epoch in range(EPOCHS):
        model.train()
        running_loss = 0.0
        correct = 0
        total = 0
        
        pbar = tqdm(train_loader, desc=f"Epoch {epoch+1}/{EPOCHS}")
        for inputs, targets in pbar:
            inputs, targets = inputs.to(device), targets.to(device)
            
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, targets)
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            _, predicted = outputs.max(1)
            total += targets.size(0)
            correct += predicted.eq(targets).sum().item()
            
            pbar.set_postfix({'Loss': f"{loss.item():.3f}", 'Acc': f"{100.*correct/total:.1f}%"})
            
        scheduler.step()
        
    # 7. Save SOTA Model
    os.makedirs('../models', exist_ok=True)
    torch.save(model.state_dict(), '../models/sota_resnet50.pth')
    print("Saved SOTA PyTorch model to models/sota_resnet50.pth")

if __name__ == '__main__':
    # Wrapping in multiprocessing check for Windows DataLoader compatibility
    import multiprocessing
    multiprocessing.freeze_support()
    train_sota_model()
